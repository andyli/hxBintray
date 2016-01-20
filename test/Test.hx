import hxBintray.*;
import tink.core.*;
import utest.*;
import utest.ui.*;

class Test {
	public var auth(default, null):Authentication;
	public function new(auth:Authentication):Void {
		this.auth = auth;
	}

	static function main():Void {
		var auth = switch ([Sys.getEnv("BINTRAY_USER"), Sys.getEnv("BINTRAY_APIKEY")]) {
			case [null, _] | [_, null]:
				throw "Please provide BINTRAY_USER and BINTRAY_APIKEY.";
			case [user, apiKey]:
				new Authentication(user, apiKey);
		}
		var runner = new Runner();
		runner.addCase(new TestRepository(auth));
		runner.addCase(new TestDownload(auth));
		Report.create(runner);
		runner.run();
	}
}