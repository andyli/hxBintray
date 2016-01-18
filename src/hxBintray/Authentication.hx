package hxBintray;

import haxe.io.*;

@:allow(hxBintray)
class Authentication {
	public var user(default, null):String;
	var AuthenticationHeader:String;
	public function new(user:String, apiKey:String):Void {
		this.user = user;
		this.AuthenticationHeader = "Basic " + haxe.crypto.Base64.encode(Bytes.ofString('$user:$apiKey'));
	}
}