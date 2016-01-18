package hxBintray;

import haxe.*;
import haxe.io.*;
import tink.CoreApi;
using StringTools;

class Bintray {
	public var api:String = "https://bintray.com/api/v1";
	public var Authentication(default, null):Authentication;

	public function new(?Authentication:Authentication):Void {
		this.Authentication = Authentication;
	}

	function get(http:Http) {
		return Future.async(function(ret){
			var out = new BytesOutput();
			var error = null;
			if (Authentication != null)
				http.addHeader("Authenticationorization", Authentication.AuthenticationHeader);
			http.noShutdown = true;
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
				var http = new Http(url);
				return get(http);
			case Success({status: 200, response: response}):
				return Future.sync(Success(response));
			case Success({status: status, response: response}):
				return Future.sync(Failure({error: 'Unknown HTTP status: $status', response: response.toString()}));
			case Failure(f):
				return Future.sync(Failure(f));
		});
	}

	public function download(subject:String, repo:String, file_path:String, isProAccount = false):Surprise<Bytes, {error:String, response:String}> {
		var url = if (isProAccount)
			'https://dl.bintray.com/$subject/$repo/$file_path';
		else
			'https://$subject.bintray.com/$repo/$file_path';
		var http = new Http(url);
		return get(http);
	}

	public function dynamicDownload(subject:String, repo:String, file_path:String, pack:String):Surprise<Bytes, {error:String, response:String}> {
		file_path = [
		for (part in file_path.split("/"))
			part.urlEncode()
		].join("/");
		var url = api + '/content/$subject/$repo/$file_path';
		var http = new Http(url);
		http.addParameter("bt_package", pack);
		return get(http);
	}
}