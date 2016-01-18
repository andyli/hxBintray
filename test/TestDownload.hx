import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;

class TestDownload extends Test {
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
}