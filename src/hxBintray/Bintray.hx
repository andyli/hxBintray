package hxBintray;

import haxe.*;
import haxe.io.*;
import tink.CoreApi;
using StringTools;

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

	function get(http:Http) {
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
				return get(createHttp(url));
			case Success({status: 200, response: response}):
				return Future.sync(Success(response));
			case Success({status: status, response: response}):
				return Future.sync(Failure(failMsg(response.toString())));
			case Failure(f):
				return Future.sync(Failure(f));
		});
	}

	function post<T>(http:Http, ?postData:Dynamic):Surprise<T, String> {
		return Future.async(function(ret){
			if (postData != null)
				http.setPostData(Json.stringify(postData));
			http.onData = function(data) {
				ret(Success(Json.parse(data)));
			}
			http.onError = function(err) ret(Failure(failMsg(http.responseData)));
			http.request(true);
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
		return get(createHttp(url));
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
		return get(http);
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
			if (publish)
				http.addParameter("publish", "1");
			if (_override)
				http.addParameter("override", "1");
			if (explode)
				http.addParameter("explode", "1");
			http.fileTransfer(fileName, fileName, file, fileSize);
			http.onStatus = function(status) switch (status) {
				case 200:
					ret(Success(Noise));
				case _:
					// pass
			}
			http.onError = function(err) ret(Failure(failMsg(http.responseData)));
			http.request(false);
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

	public function createRepository(
		subject:String,
		repo:String,
		?options:{
			@:optional var type:String;
			@:optional @:native("private") var _private:Bool;
			@:optional var premium:Bool;
			@:optional var desc:String;
			@:optional var labels:Array<String>;
		}
	):Surprise<{
		var name:String;
		var owner:String;
		var type:String;
		@:native("private")
		var _private:Bool;
		var premium:Bool;
		var desc:String;
		var labels:Array<String>;
		var created:String;
		var package_count:Int;
	}, String>
	{
		var url = api + '/repos/$subject/$repo';
		var http = createHttp(url);
		return post(http, options);
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
	):Surprise<Dynamic, String>
	{
		var url = api + '/packages/$subject/$repo';
		var http = createHttp(url);
		return post(http, options);
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