import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;

class TestPackage extends TestRepository {
	var pack(default, never):String = "test_package";

	override function test():Void {
		createRepository();
		createPackage();
		deletePackage();
		deleteRepository();
	}

	function createPackage():Void {
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

	function deletePackage():Void {
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
	}
}