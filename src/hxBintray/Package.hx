package hxBintray;

typedef Package = {
	@:optional var name:String;
	@:optional var repo:String;
	@:optional var owner:String;
	@:optional var desc:String;
	@:optional var labels:Array<String>;
	@:optional var attribute_names:Array<String>;
	@:optional var rating:Float;
	@:optional var rating_count:Int;
	@:optional var followers_count:Int;
	@:optional var created:String;
	@:optional var website_url:String;
	@:optional var issue_tracker_url:String;
	@:optional var github_repo:String;
	@:optional var github_release_notes_file:String;
	@:optional var public_download_numbers:Bool;
	@:optional var public_stats:Bool;
	@:optional var linked_to_repos:Array<Dynamic>;
	@:optional var versions:Array<String>;
	@:optional var latest_version:String;
	@:optional var updated:String;
	@:optional var vcs_url:String;
};