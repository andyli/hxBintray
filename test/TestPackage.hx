import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;

class TestPackage extends TestRepository {
	public var pack(default, never):String = "test_package";

	override function firstTest() {
		var packOpt = {
			name: pack,
			licenses: ["MIT"],
			vcs_url: "https://github.com/andyli/hxBintray.git"
		}
		return super.firstTest()
			.concat([
				function(){
					// call api without user/key
					var done = createAsync();
					var bintray = new Bintray();
					return bintray.createPackage(subject, repo, packOpt)
						.map(function(out):Noise {
							isTrue(out.match(Failure(_)));
							done();
							return Noise;
						});
				},
				function(){				
					// should success
					var done = createAsync();
					var bintray = new Bintray(auth);
					return bintray.createPackage(subject, repo, packOpt)
						.map(function(out):Noise {
							isTrue(out.match(Success(_)));
							done();
							return Noise;
						});
				},
			]);
	}

	override function lastTest() {
		return [
			function(){
				// call api without user/key
				var done = createAsync();
				var bintray = new Bintray();
				return bintray.deletePackage(subject, repo, pack)
					.map(function(out):Noise {
						isTrue(out.match(Failure(_)));
						done();
						return Noise;
					});
			},
			function(){
				// should success
				var done = createAsync();
				var bintray = new Bintray(auth);
				return bintray.deletePackage(subject, repo, pack)
					.map(function(out):Noise {
						isTrue(out.match(Success(_)));
						done();
						return Noise;
					});
			},
		].concat(super.lastTest());
	}

	override function middleTest() {
		return super.middleTest().concat([
			getPackage,
			updatePackage,
		]);
	}

	function getPackage() {
		var done = createAsync();
		var bintray = new Bintray(auth);
		return bintray.getPackage(subject, repo, pack)
			.map(function(out):Noise {
				var info = out.sure();
				equals(pack, info.name);
				equals(repo, info.repo);
				equals(auth.user, info.owner);
				done();
				return Noise;
			});
	}

	function updatePackage() {
		var done = createAsync();
		var newInfo = {
			desc: "This updated."
		};
		var bintray = new Bintray(auth);
		return bintray.updatePackage(subject, repo, pack, newInfo)
			.map(function(out):Noise {
				isTrue(out.match(Success(_)));
				done();
				return Noise;
			});
	}
}