import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;

class TestVersion extends TestPackage {
	public var version(default, never):String = "0.1.0";

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

	override function middleTest():Void {
		super.middleTest();

		getVersion();
		updateVersion();
	}

	function getVersion():Void {
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.getVersion(subject, repo, pack, version)
			.handle(function(out){
				var info = out.sure();
				equals(version, info.name);
				equals(repo, info.repo);
				equals(pack, info.pack);
				equals(auth.user, info.owner);
				done();
			});
	}

	function updateVersion():Void {
		var done = createAsync();
		var newInfo = {
			desc: "This is updated version desc."
		};
		var bintray = new Bintray(auth);
		bintray.updateVersion(subject, repo, pack, version, newInfo)
			.handle(function(out){
				isTrue(out.match(Success(_)));
				done();
			});
	}
}