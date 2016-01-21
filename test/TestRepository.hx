import hxBintray.*;
import tink.CoreApi;
using tink.core.Outcome;
import utest.Assert.*;
using Lambda;
using hxBintray.Util;

class TestRepository extends Test {
	public var repoPrefix(default, never):String = "hxBintray_test_repo_";
	public var repo(get, null):String;
	function get_repo() return repo != null ? repo : repo = repoPrefix + Std.random(1000);
	public var subject(get, never):String;
	function get_subject() return auth.user;

	public function clean():Future<Noise> {
		var bintray = new Bintray(auth);
		return bintray.getRepositories(subject)
			.flatMap(function(out){
				var repos = out.sure();
				return Future.ofMany([
					for (r in repos)
					if (r.owner == auth.user && StringTools.startsWith(r.name, repoPrefix))
					bintray.deleteRepository(subject, r.name)
				]);
			})
			.map(function(_) return Noise);
	}

	override function firstTest() {
		return super.firstTest()
			.concat([
				function(){
					// call api without user/key
					var done = createAsync();
					var bintray = new Bintray();
					return bintray.createRepository(subject, repo)
						.map(function(out){
							isTrue(out.match(Failure(_)));
							done();
							return Noise;
						});
				},
				function(){
					// should success
					var done = createAsync();
					var bintray = new Bintray(auth);
					return bintray.createRepository(subject, repo)
						.map(function(out){
							var r = out.sure();
							equals(repo, r.name);
							equals(auth.user, r.owner);
							done();
							return Noise;
						});
				}
			]);
	}

	override function lastTest() {
		return [
			function(){
				// call api without user/key
				var done = createAsync();
				var bintray = new Bintray();
				return bintray.deleteRepository(subject, repo)
					.map(function(out){
						isTrue(out.match(Failure(_)));
						done();
						return Noise;
					});
			},
			function(){
				// should success
				var done = createAsync();
				var bintray = new Bintray(auth);
				return bintray.deleteRepository(subject, repo)
					.map(function(out){
						isTrue(out.match(Success(_)));
						done();
						return Noise;
					});
			},
		].concat(super.lastTest());
	}

	override function middleTest() {
		return super.middleTest().concat([
			getRepositories,
			getRepository,
			updateRepository,
		]);
	}

	function getRepositories() {
		var done = createAsync();
		var bintray = new Bintray(auth);
		return bintray.getRepositories(subject)
			.map(function(out){
				var repos = out.sure();
				isTrue(repos.length > 0);
				var info = repos.find(function(info) {
					return info.name == repo;
				});
				notNull(info);
				equals(auth.user, info.owner);
				done();
				return Noise;
			});
	}

	function getRepository() {
		var done = createAsync();
		var bintray = new Bintray(auth);
		return bintray.getRepository(subject, repo)
			.map(function(out){
				var info = out.sure();
				equals(repo, info.name);
				equals(auth.user, info.owner);
				done();
				return Noise;
			});
	}

	function updateRepository() {
		var done = createAsync();
		var newInfo = {
			desc: "This is just a test."
		};
		var bintray = new Bintray(auth);
		return bintray.updateRepository(subject, repo, newInfo)
			.map(function(out){
				isTrue(out.match(Success(_)));
				done();
				return Noise;
			});
	}
}