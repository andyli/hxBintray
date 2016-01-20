package hxBintray;

typedef Repository = {
	@:optional var name:String;
	@:optional var owner:String;
	@:optional var type:String;
	@:optional @:native("private") var priv:Bool;
	@:optional var premium:Bool;
	@:optional var desc:String;
	@:optional var labels:Array<String>;
	@:optional var created:String;
	@:optional var package_count:Int;
}