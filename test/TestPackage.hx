import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;

class TestPackage extends TestRepository {
	var pack(default, never):String = "test_package";

	override function firstTest():Void {
		super.firstTest();

		var packOpt = {
			name: pack,
			licenses: ["MIT"],
			vcs_url: "https://github.com/andyli/hxBintray.git"
		}

		// call api without user/key
		var done = createAsync();
		var bintray = new Bintray();
		bintray.createPackage(subject, repo, packOpt)
			.handle(function(out){
				isTrue(out.match(Failure(_)));
				done();
			});

		// should success
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.createPackage(subject, repo, packOpt)
			.handle(function(out){
				isTrue(out.match(Success(_)));
				done();
			});
	}

	override function lastTest():Void {
		// call api without user/key
		var done = createAsync();
		var bintray = new Bintray();
		bintray.deletePackage(subject, repo, pack)
			.handle(function(out){
				isTrue(out.match(Failure(_)));
				done();
			});

		// should success
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.deletePackage(subject, repo, pack)
			.handle(function(out){
				isTrue(out.match(Success(_)));
				done();
			});

		super.lastTest();
	}

	override function middleTest():Void {
		super.middleTest();

		getPackage();
		updatePackage();
	}

	function getPackage():Void {
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.getPackage(subject, repo, pack)
			.handle(function(out){
				var info = out.sure();
				equals(pack, info.name);
				equals(repo, info.repo);
				equals(auth.user, info.owner);
				done();
			});
	}

	function updatePackage():Void {
		var done = createAsync();
		var newInfo = {
			desc: "This updated."
		};
		var bintray = new Bintray(auth);
		bintray.updatePackage(subject, repo, pack, newInfo)
			.handle(function(out){
				isTrue(out.match(Success(_)));
				done();
			});
	}
}