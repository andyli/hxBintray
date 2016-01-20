package hxBintray;

typedef File = {
	@:optional var name:String;
	@:optional var path:String;
	@:optional @:native("package") var pack:String;
	@:optional var version:String;
	@:optional var repo:String;
	@:optional var owner:String;
	@:optional var created:String;
	@:optional var size:Int;
	@:optional var sha1:String;
};