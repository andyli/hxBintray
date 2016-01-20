import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;

class TestRepository extends Test {
	var repo(get, null):String;
	function get_repo() return repo != null ? repo : repo = "hxBintray_test_repo_" + Std.random(1000);
	var subject(get, never):String;
	function get_subject() return auth.user;

	function test():Void {
		createRepository();
		deleteRepository();
	}

	function createRepository():Void {
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
				done();
			});
	}

	function deleteRepository():Void {
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
				notNull(out.sure());
				done();
			});
	}
}