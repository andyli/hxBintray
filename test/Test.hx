import hxBintray.*;
import tink.CoreApi;
using tink.core.Outcome;
import utest.*;
import utest.ui.*;
import utest.Assert.*;

class Test {
	public var auth(default, null):Authentication;
	public function new(auth:Authentication):Void {
		this.auth = auth;
	}

	function test_download():Void {
		var done = createAsync();
		var bt = new Bintray();
		bt.download("homebrew", "bottles", "haxe-3.2.1.el_capitan.bottle.tar.gz")
			.handle(function(out) {
				var bytes = out.sure();
				isTrue(bytes.length > 0);
				done();
			});
	}

	function test_dynamicDownload():Void {
		var done = createAsync();
		var bt = new Bintray(auth);
		bt.dynamicDownload("homebrew", "bottles", "haxe-3.2.1.el_capitan.bottle.tar.gz", "haxe")
			.handle(function(out) {
				var bytes = out.sure();
				isTrue(bytes.length > 0);
				done();
			});
	}

	static function main():Void {
		var auth = switch ([Sys.getEnv("BINTRAY_USER"), Sys.getEnv("BINTRAY_APIKEY")]) {
			case [null, _] | [_, null]:
				throw "Please provide BINTRAY_USER and BINTRAY_APIKEY.";
			case [user, apiKey]:
				new Authentication(user, apiKey);
		}
		var runner = new Runner();
		runner.addCase(new Test(auth));
		Report.create(runner);
		runner.run();
	}
}