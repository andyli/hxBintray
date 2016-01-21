import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;

class TestVersion extends TestPackage {
	public var version(default, never):String = "0.1.0";

	override function firstTest() {
		var versionOpt = {
			name: version
		}
		return super.firstTest().concat([
			function(){
				// call api without user/key
				var done = createAsync();
				var bintray = new Bintray();
				return bintray.createVersion(subject, repo, pack, versionOpt)
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
				return bintray.createVersion(subject, repo, pack, versionOpt)
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
				return bintray.deleteVersion(subject, repo, pack, version)
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
				return bintray.deleteVersion(subject, repo, pack, version)
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
			getVersion,
			updateVersion,
		]);
	}

	function getVersion() {
		var done = createAsync();
		var bintray = new Bintray(auth);
		return bintray.getVersion(subject, repo, pack, version)
			.map(function(out):Noise {
				var info = out.sure();
				equals(version, info.name);
				equals(repo, info.repo);
				equals(pack, info.pack);
				equals(auth.user, info.owner);
				done();
				return Noise;
			});
	}

	function updateVersion() {
		var done = createAsync();
		var newInfo = {
			desc: "This is updated version desc."
		};
		var bintray = new Bintray(auth);
		return bintray.updateVersion(subject, repo, pack, version, newInfo)
			.map(function(out):Noise {
				isTrue(out.match(Success(_)));
				done();
				return Noise;
			});
	}
}