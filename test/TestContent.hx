import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;
import haxe.io.*;

class TestContent extends TestVersion {
	var file_path(default, never):String = "path/to/something.txt";
	var fileContent(default, never):String = "something here";

	override function firstTest():Void {
		super.firstTest();

		var fileBytes = Bytes.ofString(fileContent);
		var file = new BytesInput(fileBytes);

		// call api without user/key
		var done = createAsync();
		var bintray = new Bintray();
		bintray.uploadContent(file, file.length, subject, repo, pack, version, file_path)
			.handle(function(out){
				isTrue(out.match(Failure(_)));
				done();
			});

		// should success
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.uploadContent(file, file.length, subject, repo, pack, version, file_path)
			.handle(function(out){
				isTrue(out.match(Success(_)));
				done();
			});
	}

	override function lastTest():Void {
		// call api without user/key
		var done = createAsync();
		var bintray = new Bintray();
		bintray.deleteContent(subject, repo, file_path)
			.handle(function(out){
				isTrue(out.match(Failure(_)));
				done();
			});

		// should success
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.deleteContent(subject, repo, file_path)
			.handle(function(out){
				isTrue(out.match(Success(_)));
				done();
			});

		super.lastTest();
	}
}