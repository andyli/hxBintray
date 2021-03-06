import hxBintray.*;
import tink.CoreApi;
import utest.*;
import utest.ui.*;
import utest.Assert.*;

class Test {
	public var auth(default, null):Authentication;
	public function new(auth:Authentication):Void {
		this.auth = auth;
	}

	function isSuccess<T,E>(s:Outcome<T,E>, ?pos:haxe.PosInfos){
		return switch (s) {
			case Success(_):
				pass(null, pos);
			case Failure(f):
				fail('Got Failure: $f', pos);
		}
	}

	@:final function test():Void {
		firstTestDone = createAsync();
		middleTestDone = createAsync();
		lastTestDone = createAsync();

		seq(firstTest())
			.flatMap(function(_) return seq(middleTest()))
			.flatMap(function(_) return seq(lastTest()))
			.handle(function(_){});

		// avoid no assertion
		pass();
	}

	static function seq(fs:Array<Void->Future<Noise>>):Future<Noise> {
		switch (fs.length) {
			case 0:
				return Future.sync(Noise);
			case _:
				return fs[0]().flatMap(function(_){
					return seq(fs.slice(1));
				});
		}
	}

	var firstTestDone:Void->Void;
	var middleTestDone:Void->Void;
	var lastTestDone:Void->Void;
	function firstTest():Array<Void->Future<Noise>> {
		return [function() return Future.async(function(ret){
			firstTestDone();
			ret(Noise);
		})];
	}

	function middleTest():Array<Void->Future<Noise>> {
		return [function() return Future.async(function(ret){
			middleTestDone();
			ret(Noise);
		})];
	}

	function lastTest():Array<Void->Future<Noise>> {
		return [function() return Future.async(function(ret){
			lastTestDone();
			ret(Noise);
		})];
	}

	static function main():Void {
		var auth = switch ([Sys.getEnv("BINTRAY_USER"), Sys.getEnv("BINTRAY_APIKEY")]) {
			case [null, _] | [_, null]:
				throw "Please provide BINTRAY_USER and BINTRAY_APIKEY.";
			case [user, apiKey]:
				new Authentication(user, apiKey);
		}

		switch (Sys.args()) {
			case ["clean"]:
				new TestContent(auth).clean()
					.handle(function(_){
						Sys.println("done");
					});
			case _:
				var runner = new Runner();
				runner.addCase(new TestContent(auth));
				runner.addCase(new TestDownload(auth));
				Report.create(runner);
				runner.run();
		}
	}
}