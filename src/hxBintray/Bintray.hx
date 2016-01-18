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
			http.addHeader("Authentication", auth.httpHeader);
		http.noShutdown = true;
		return http;
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
				ret(Failure({
					error: error,
					response: out.getBytes().toString()
				}));
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
				return Future.sync(Failure({error: 'Unknown HTTP status: $status', response: response.toString()}));
			case Failure(f):
				return Future.sync(Failure(f));
		});
	}

	public function download(
		subject:String,
		repo:String,
		file_path:String,
		isProAccount = false
	):Surprise<Bytes, {error:String, response:String}>
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
	):Surprise<Bytes, {error:String, response:String}>
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

	public function upload(
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
			if (auth != null)
				http.addHeader("Authentication", auth.httpHeader);
			http.noShutdown = true;
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
					ret(Failure('Unknown HTTP status: $status'));
			}
			http.onError = function(err) ret(Failure(err));
			http.request(false);
		});
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
		return Future.async(function(ret){
			var url = api + '/repos/$subject/$repo';
			var http = createHttp(url);
			if (options != null)
				http.setPostData(Json.stringify(options));
			// http.onStatus = function(status) switch (status) {
			// 	case 201:
			// 		//pass
			// 	case _:
			// 		ret(Failure('Unknown HTTP status: $status'));
			// }
			http.onData = function(data) {
				ret(Success(Json.parse(data)));
			}
			http.onError = function(err) ret(Failure(http.responseData));
			http.request(true);
		});
	}
}