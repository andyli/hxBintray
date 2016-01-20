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

	function test():Void {
		firstTestDone = createAsync();
		middleTestDone = createAsync();
		lastTestDone = createAsync();
		firstTest();
		middleTest();
		lastTest();

		// avoid no assertion
		isTrue(true);
	}

	var firstTestDone:Void->Void;
	var middleTestDone:Void->Void;
	var lastTestDone:Void->Void;
	function firstTest():Void {
		firstTestDone();
	}

	function middleTest():Void {
		middleTestDone();
	}

	function lastTest():Void {
		lastTestDone();
	}

	static function main():Void {
		var auth = switch ([Sys.getEnv("BINTRAY_USER"), Sys.getEnv("BINTRAY_APIKEY")]) {
			case [null, _] | [_, null]:
				throw "Please provide BINTRAY_USER and BINTRAY_APIKEY.";
			case [user, apiKey]:
				new Authentication(user, apiKey);
		}
		var runner = new Runner();
		runner.addCase(new TestContent(auth));
		runner.addCase(new TestDownload(auth));
		Report.create(runner);
		runner.run();
	}
}