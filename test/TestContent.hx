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

	override function firstTest() {
		return super.firstTest().concat([
			function(){
				// call api without user/key
				var file = new BytesInput(fileBytes);
				var done = createAsync();
				var bintray = new Bintray();
				return bintray.uploadContent(file, file.length, subject, repo, pack, version, file_path.toString())
					.map(function(out):Noise {
						isTrue(out.match(Failure(_)));
						done();
						return Noise;
					});
			},
			function(){
				// should success
				var file = new BytesInput(fileBytes);
				var done = createAsync();
				var bintray = new Bintray(auth);
				return bintray.uploadContent(file, file.length, subject, repo, pack, version, file_path.toString())
					.map(function(out):Noise {
						isSuccess(out);
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
				return bintray.deleteContent(subject, repo, file_path.toString())
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
				return bintray.deleteContent(subject, repo, file_path.toString())
					.map(function(out):Noise {
						isSuccess(out);
						done();
						return Noise;
					});
			},
		].concat(super.lastTest());
	}

	override function middleTest() {
		return super.middleTest().concat([
			publishUploadedContent,
			getPackageFiles,
			getVersionFiles,
			fileSearchByName,
			fileSearchByChecksum,
			fileInDownloadList,
		]);
	}

	function publishUploadedContent() {
		var done = createAsync();
		var bintray = new Bintray(auth);
		return bintray.publishUploadedContent(subject, repo, pack, version, -1)
			.map(function(out):Noise {
				isSuccess(out);
				var num = out.sure();
				equals(1, num);
				done();
				return Noise;
			});
	}

	function getPackageFiles() {
		var done = createAsync();
		var bintray = new Bintray(auth);
		return bintray.getPackageFiles(subject, repo, pack, true)
			.map(function(out):Noise {
				var files = out.sure();
				equals(1, files.length);
				var file = files[0];
				equals(file_path.toString(), file.path);
				equals(repo, file.repo);
				equals(pack, file.pack);
				equals(auth.user, file.owner);
				equals(fileSha1, file.sha1);
				done();
				return Noise;
			});
	}

	function getVersionFiles() {
		var done = createAsync();
		var bintray = new Bintray(auth);
		return bintray.getVersionFiles(subject, repo, pack, version, true)
			.map(function(out):Noise {
				var files = out.sure();
				equals(1, files.length);
				var file = files[0];
				equals(file_path.toString(), file.path);
				equals(repo, file.repo);
				equals(pack, file.pack);
				equals(auth.user, file.owner);
				equals(fileSha1, file.sha1);
				done();
				return Noise;
			});
	}

	function fileSearchByName() {
		var done = createAsync();
		var bintray = new Bintray(auth);
		return bintray.fileSearchByName(file_path.file, subject, repo)
			.map(function(out):Noise {
				var files = out.sure();
				equals(1, files.length);
				var file = files[0];
				equals(file_path.toString(), file.path);
				equals(repo, file.repo);
				equals(pack, file.pack);
				equals(auth.user, file.owner);
				equals(fileSha1, file.sha1);
				done();
				return Noise;
			});
	}

	function fileSearchByChecksum() {
		var done = createAsync();
		var bintray = new Bintray(auth);
		return bintray.fileSearchByChecksum(fileSha1, subject, repo)
			.map(function(out):Noise {
				var files = out.sure();
				equals(1, files.length);
				var file = files[0];
				equals(file_path.toString(), file.path);
				equals(repo, file.repo);
				equals(pack, file.pack);
				equals(auth.user, file.owner);
				done();
				return Noise;
			});
	}

	function fileInDownloadList() {
		var done = createAsync();
		var bintray = new Bintray(auth);
		return bintray.fileInDownloadList(subject, repo, file_path.toString(), true)
			.map(function(out):Noise {
				isSuccess(out);
				done();
				return Noise;
			});
	}
}