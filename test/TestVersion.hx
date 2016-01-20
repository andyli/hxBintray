import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;

class TestVersion extends TestPackage {
	var version(default, never):String = "0.1.0";

	override function firstTest():Void {
		super.firstTest();

		var versionOpt = {
			name: version
		}

		// call api without user/key
		var done = createAsync();
		var bintray = new Bintray();
		bintray.createVersion(subject, repo, pack, versionOpt)
			.handle(function(out){
				isTrue(out.match(Failure(_)));
				done();
			});

		// should success
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.createVersion(subject, repo, pack, versionOpt)
			.handle(function(out){
				isTrue(out.match(Success(_)));
				done();
			});
	}

	override function lastTest():Void {
		// call api without user/key
		var done = createAsync();
		var bintray = new Bintray();
		bintray.deleteVersion(subject, repo, pack, version)
			.handle(function(out){
				isTrue(out.match(Failure(_)));
				done();
			});

		// should success
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.deleteVersion(subject, repo, pack, version)
			.handle(function(out){
				isTrue(out.match(Success(_)));
				done();
			});

		super.lastTest();
	}
}