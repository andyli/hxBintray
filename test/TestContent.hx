import hxBintray.*;
import tink.core.*;
using tink.core.Outcome;
import utest.Assert.*;
import haxe.io.*;

class TestContent extends TestVersion {
	public var file_path(default, never):Path = new Path("path/to/something.txt");
	public var fileContent(default, never):String = "something here";
	public var fileBytes(get, null):Bytes = null;
	function get_fileBytes() return fileBytes != null ? fileBytes : fileBytes = Bytes.ofString(fileContent);
	public var fileSha1(get, null):String = null;
	function get_fileSha1() return fileSha1 != null ? fileSha1 : fileSha1 = haxe.crypto.Sha1.make(fileBytes).toHex();

	override function firstTest():Void {
		super.firstTest();

		// call api without user/key
		var file = new BytesInput(fileBytes);
		var done = createAsync();
		var bintray = new Bintray();
		bintray.uploadContent(file, file.length, subject, repo, pack, version, file_path.toString())
			.handle(function(out){
				isTrue(out.match(Failure(_)));
				done();
			});

		// should success
		var file = new BytesInput(fileBytes);
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.uploadContent(file, file.length, subject, repo, pack, version, file_path.toString())
			.handle(function(out){
				isSuccess(out);
				done();
			});
	}

	override function lastTest():Void {
		// call api without user/key
		var done = createAsync();
		var bintray = new Bintray();
		bintray.deleteContent(subject, repo, file_path.toString())
			.handle(function(out){
				isTrue(out.match(Failure(_)));
				done();
			});

		// should success
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.deleteContent(subject, repo, file_path.toString())
			.handle(function(out){
				isSuccess(out);
				done();
			});

		super.lastTest();
	}

	override function middleTest():Void {
		super.middleTest();

		publishUploadedContent();
		getPackageFiles();
		getVersionFiles();
		fileSearchByName();
		fileSearchByChecksum();
		fileInDownloadList();
	}

	function publishUploadedContent():Void {
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.publishUploadedContent(subject, repo, pack, version, -1)
			.handle(function(out){
				isSuccess(out);
				var num = out.sure();
				equals(1, num);
				done();
			});
	}

	function getPackageFiles():Void {
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.getPackageFiles(subject, repo, pack, true)
			.handle(function(out){
				var files = out.sure();
				equals(1, files.length);
				var file = files[0];
				equals(file_path.toString(), file.path);
				equals(repo, file.repo);
				equals(pack, file.pack);
				equals(auth.user, file.owner);
				equals(fileSha1, file.sha1);
				done();
			});
	}

	function getVersionFiles():Void {
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.getVersionFiles(subject, repo, pack, version, true)
			.handle(function(out){
				var files = out.sure();
				equals(1, files.length);
				var file = files[0];
				equals(file_path.toString(), file.path);
				equals(repo, file.repo);
				equals(pack, file.pack);
				equals(auth.user, file.owner);
				equals(fileSha1, file.sha1);
				done();
			});
	}

	function fileSearchByName():Void {
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.fileSearchByName(file_path.file, subject, repo)
			.handle(function(out){
				var files = out.sure();
				equals(1, files.length);
				var file = files[0];
				equals(file_path.toString(), file.path);
				equals(repo, file.repo);
				equals(pack, file.pack);
				equals(auth.user, file.owner);
				equals(fileSha1, file.sha1);
				done();
			});
	}

	function fileSearchByChecksum():Void {
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.fileSearchByChecksum(fileSha1, subject, repo)
			.handle(function(out){
				var files = out.sure();
				equals(1, files.length);
				var file = files[0];
				equals(file_path.toString(), file.path);
				equals(repo, file.repo);
				equals(pack, file.pack);
				equals(auth.user, file.owner);
				done();
			});
	}

	function fileInDownloadList():Void {
		var done = createAsync();
		var bintray = new Bintray(auth);
		bintray.fileInDownloadList(subject, repo, file_path.toString(), true)
			.handle(function(out){
				isSuccess(out);
				done();
			});
	}
}