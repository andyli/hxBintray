import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;
using Lambda;

class TestRepository extends Test {
	public var repo(get, null):String;
	function get_repo() return repo != null ? repo : repo = "hxBintray_test_repo_" + Std.random(1000);
	public var subject(get, never):String;
	function get_subject() return auth.user;

	override function firstTest():Void {
		super.firstTest();

		// call api without user/key
		var done = createAsync();
		var bintray = new Bintray();
		bintray.createRepository(subject, repo)
			.handle(function(out){
				isTrue(out.match(Failure(_)));
				done();
			});

		// should success
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.createRepository(subject, repo)
			.handle(function(out){
				var r = out.sure();
				equals(repo, r.name);
				equals(auth.user, r.owner);
				done();
			});
	}

	override function lastTest():Void {
		// call api without user/key
		var done = createAsync();
		var bintray = new Bintray();
		bintray.deleteRepository(subject, repo)
			.handle(function(out){
				isTrue(out.match(Failure(_)));
				done();
			});

		// should success
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.deleteRepository(subject, repo)
			.handle(function(out){
				isTrue(out.match(Success(_)));
				done();
			});

		super.lastTest();
	}

	override function middleTest():Void {
		super.middleTest();

		getRepositories();
		getRepository();
		updateRepository();
	}

	function getRepositories():Void {
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.getRepositories(subject)
			.handle(function(out){
				var repos = out.sure();
				isTrue(repos.length > 0);
				var info = repos.find(function(info) {
					return info.name == repo;
				});
				notNull(info);
				equals(auth.user, info.owner);
				done();
			});
	}

	function getRepository():Void {
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.getRepository(subject, repo)
			.handle(function(out){
				var info = out.sure();
				equals(repo, info.name);
				equals(auth.user, info.owner);
				done();
			});
	}

	function updateRepository():Void {
		var done = createAsync();
		var newInfo = {
			desc: "This is just a test."
		};
		var bintray = new Bintray(auth);
		bintray.updateRepository(subject, repo, newInfo)
			.handle(function(out){
				isTrue(out.match(Success(_)));
				done();
			});
	}
}