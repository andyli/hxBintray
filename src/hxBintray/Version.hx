package hxBintray;

typedef Version = {
	@:optional var name:String;
	@:optional var desc:String;
	@:optional @:native("package") var pack:String;
	@:optional var repo:String;
	@:optional var owner:String;
	@:optional var labels:Array<String>;
	@:optional var attribute_names:Array<String>;
	@:optional var created:String;
	@:optional var updated:String;
	@:optional var released:String;
	@:optional var github_release_notes_file:String;
	@:optional var github_use_tag_release_notes:String;
	@:optional var vcs_tag:String;
	@:optional var ordinal:Int;
};