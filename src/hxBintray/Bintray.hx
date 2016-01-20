package hxBintray;

import haxe.*;
import haxe.io.*;
import tink.CoreApi;
using tink.core.Outcome;
using StringTools;
using hxBintray.Bintray;

class Bintray {
	public var api:String = "https://bintray.com/api/v1";
	public var auth(default, null):Authentication;

	public function new(?auth:Authentication):Void {
		this.auth = auth;
	}

	function createHttp(url:String):Http {
		var http = new Http(url);
		if (auth != null)
			http.addHeader("Authorization", auth.httpHeader);
		http.noShutdown = true;
		return http;
	}

	function failMsg(response:String):String {
		return try {
			Json.parse(response).message;
		} catch (e:Dynamic) {
			response;
		}
	}

	static function ignoreResponse<T,E>(r:Surprise<T,E>):Surprise<Noise,E> {
		return r.map(function(out) return out.map(function(_) return Noise));
	}

	static function toNative(obj:Dynamic):Dynamic {
		var array = Std.instance(obj, Array);
		if (array != null) {
			return [for (e in array) toNative(e)];
		} else {
			var ret = {};
			for (f in Reflect.fields(obj)) {
				var _f = switch (f) {
					case "priv": "private";
					case "pack": "package";
					case _: f;
				}
				Reflect.setField(ret, _f, Reflect.field(obj, f));
			}
			return ret;
		}
	}

	static function toHaxe(obj:Dynamic):Dynamic {
		var array = Std.instance(obj, Array);
		if (array != null) {
			return [for (e in array) toHaxe(e)];
		} else {
			var ret = {};
			for (f in Reflect.fields(obj)) {
				var _f = switch (f) {
					case "private": "priv";
					case "package": "pack";
					case _: f;
				}
				Reflect.setField(ret, _f, Reflect.field(obj, f));
			}
			return ret;
		}
	}

	function getBytes(http:Http) {
		return Future.async(function(ret){
			var out = new BytesOutput();
			var error = null;
			http.onError = function(msg) {
				error = msg;
			}
			var status = -1;
			http.onStatus = function(s) {
				status = s;
			}
			http.customRequest(false, out);
			if (error != null) {
				ret(Failure(failMsg(out.getBytes().toString())));
				return;
			}
			ret(Success({
				http: http,
				status: status,
				response: out.getBytes(),
			}));
		}).flatMap(function(out) switch (out) {
			case Success({status: 302}):
				var url = http.responseHeaders["Location"];
				// trace(url);
				return getBytes(createHttp(url));
			case Success({status: 200, response: response}):
				return Future.sync(Success(response));
			case Success({status: status, response: response}):
				return Future.sync(Failure(failMsg(response.toString())));
			case Failure(f):
				return Future.sync(Failure(f));
		});
	}

	function getObj<T>(http:Http):Surprise<T,String> {
		return getBytes(http)
			.map(function(out) return out.map(function(bytes)
				return Json.parse(bytes.toString()).toHaxe()
			));
	}

	function post<T>(http:Http, ?postData:Dynamic):Surprise<T, String> {
		return Future.async(function(ret){
			if (postData != null)
				http.setPostData(Json.stringify(postData.toNative()));
			http.onData = function(data) {
				ret(Success(Json.parse(data)));
			}
			http.onError = function(err) ret(Failure(failMsg(http.responseData)));
			http.request(true);
		});
	}

	function patch<T>(http:Http, ?postData:Dynamic):Surprise<T, String> {
		return Future.async(function(ret){
			var out = new BytesOutput();
			if (postData != null)
				http.setPostData(Json.stringify(postData.toNative()));
			var error = null;
			http.onError = function(err) {
				error = err;
			};
			http.customRequest(false, out, null, "PATCH");
			var response = out.getBytes().toString();
			if (error != null)
				ret(Failure(failMsg(response)));
			else
				ret(Success(Json.parse(response)));
		});
	}

	function delete(http:Http):Surprise<Noise, String> {
		return Future.async(function(ret){
			var out = new BytesOutput();
			http.onStatus = function(status) switch (status) {
				case 200:
					ret(Success(Noise));
				case _:
					// pass
			}
			http.onError = function(err) ret(Failure(failMsg(out.getBytes().toString())));
			http.customRequest(false, out, null, "DELETE");
		});
	}

	public function downloadContent(
		subject:String,
		repo:String,
		file_path:String,
		isProAccount = false
	):Surprise<Bytes, String>
	{
		var url = if (isProAccount)
			'https://dl.bintray.com/$subject/$repo/$file_path';
		else
			'https://$subject.bintray.com/$repo/$file_path';
		return getBytes(createHttp(url));
	}

	public function dynamicDownload(
		subject:String,
		repo:String,
		file_path:String,
		pack:String
	):Surprise<Bytes, String>
	{
		file_path = [
		for (part in file_path.split("/"))
			part.urlEncode()
		].join("/");
		var url = api + '/content/$subject/$repo/$file_path';
		var http = createHttp(url);
		http.addParameter("bt_package", pack);
		return getBytes(http);
	}

	public function uploadContent(
		file:Input,
		fileSize:Int,
		subject:String,
		repo:String,
		pack:String,
		version:String,
		file_path:String,
		publish:Bool = false,
		_override:Bool = false,
		explode:Bool = false
	):Surprise<Noise, String>
	{
		return Future.async(function(ret){
			var url = api + '/content/$subject/$repo/$pack/$version/$file_path';
			var fileName = new Path(file_path).file;
			var http = createHttp(url);
			var out = new BytesOutput();
			if (publish)
				http.addParameter("publish", "1");
			if (_override)
				http.addParameter("override", "1");
			if (explode)
				http.addParameter("explode", "1");
			http.setPostData(file.readAll(fileSize).toString());
			var error = null;
			http.onError = function(err) error = err;
			http.customRequest(false, out, null, "PUT");
			if (error != null)
				ret(Failure(failMsg(out.getBytes().toString())));
			else
				ret(Success(Noise));
		});
	}

	public function deleteContent(
		subject:String,
		repo:String,
		file_path:String
	):Surprise<Noise, String>
	{
		var url = api + '/content/$subject/$repo/$file_path';
		var http = createHttp(url);
		return delete(http);
	}

	public function getRepositories(
		subject:String
	):Surprise<Array<{name:String, owner:String}>, String>
	{
		var url = api + '/repos/$subject';
		var http = createHttp(url);
		return getObj(http);
	}

	public function getRepository(
		subject:String,
		repo:String
	):Surprise<Repository, String>
	{
		var url = api + '/repos/$subject/$repo';
		var http = createHttp(url);
		return getObj(http);
	}

	public function createRepository(
		subject:String,
		repo:String,
		?options:{
			@:optional var type:String;
			@:optional @:native("private") var priv:Bool;
			@:optional var premium:Bool;
			@:optional var desc:String;
			@:optional var labels:Array<String>;
		}
	):Surprise<Repository, String>
	{
		var url = api + '/repos/$subject/$repo';
		var http = createHttp(url);
		return post(http, options);
	}

	public function updateRepository(
		subject:String,
		repo:String,
		info:Repository
	):Surprise<Noise, String>
	{
		var url = api + '/repos/$subject/$repo';
		var http = createHttp(url);
		return patch(http, info).ignoreResponse();
	}

	public function deleteRepository(
		subject:String,
		repo:String
	):Surprise<Noise, String>
	{
		var url = api + '/repos/$subject/$repo';
		var http = createHttp(url);
		return delete(http);
	}

	public function getPackage(
		subject:String,
		repo:String,
		pack:String
	):Surprise<Package, String>
	{
		var url = api + '/packages/$subject/$repo/$pack';
		var http = createHttp(url);
		return getObj(http);
	}

	public function createPackage(
		subject:String,
		repo:String,
		?options:{
			@:optional var name:String;
			@:optional var desc:String;
			@:optional var labels:Array<String>;
			@:optional var licenses:Array<String>;
			@:optional var custom_licenses:Array<String>;
			@:optional var vcs_url:String;
			@:optional var website_url:String;
			@:optional var issue_tracker_url:String;
			@:optional var github_repo:String;
			@:optional var github_release_notes_file:String;
			@:optional var public_download_numbers:Bool;
			@:optional var public_stats:Bool;
		}
	):Surprise<Package, String>
	{
		var url = api + '/packages/$subject/$repo';
		var http = createHttp(url);
		return post(http, options);
	}

	public function updatePackage(
		subject:String,
		repo:String,
		pack:String,
		info:Package
	):Surprise<Noise, String>
	{
		var url = api + '/packages/$subject/$repo/$pack';
		var http = createHttp(url);
		return patch(http, info).ignoreResponse();
	}

	public function deletePackage(
		subject:String,
		repo:String,
		pack:String
	):Surprise<Noise, String>
	{
		var url = api + '/packages/$subject/$repo/$pack';
		var http = createHttp(url);
		return delete(http);
	}

	public function getVersion(
		subject:String,
		repo:String,
		pack:String,
		version:String = "_latest"
	):Surprise<Version, String>
	{
		var url = api + '/packages/$subject/$repo/$pack/versions/$version';
		var http = createHttp(url);
		return getObj(http);
	}

	public function createVersion(
		subject:String,
		repo:String,
		pack:String,
		?options:{
			@:optional var name:String;
			@:optional var released:String;
			@:optional var desc:String;
			@:optional var github_release_notes_file:String;
			@:optional var github_use_tag_release_notes:String;
			@:optional var vcs_tag:String;
		}
	):Surprise<Dynamic, String>
	{
		var url = api + '/packages/$subject/$repo/$pack/versions';
		var http = createHttp(url);
		return post(http, options);
	}

	public function updateVersion(
		subject:String,
		repo:String,
		pack:String,
		version:String,
		info:Version
	):Surprise<Noise, String>
	{
		var url = api + '/packages/$subject/$repo/$pack/versions/$version';
		var http = createHttp(url);
		return patch(http, info).ignoreResponse();
	}

	public function deleteVersion(
		subject:String,
		repo:String,
		pack:String,
		version:String
	):Surprise<Noise, String>
	{
		var url = api + '/packages/$subject/$repo/$pack/versions/$version';
		var http = createHttp(url);
		return delete(http);
	}
}