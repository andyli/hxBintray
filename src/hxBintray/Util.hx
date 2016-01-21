package hxBintray;

import tink.CoreApi;
using tink.core.Outcome;

class Util {
	static public function ignoreResponse<T,E>(r:Surprise<T,E>):Surprise<Noise,E> {
		return r.map(function(out) return out.map(function(_) return Noise));
	}

	static public function toNative(obj:Dynamic):Dynamic {
		var array = Std.instance(obj, Array);
		if (array != null) {
			return [for (e in array) toNative(e)];
		} else {
			var ret = {};
			for (f in Reflect.fields(obj)) {
				var _f = switch (f) {
					case "priv": "private";
					case "pack": "package";
					case _: f;
				}
				Reflect.setField(ret, _f, Reflect.field(obj, f));
			}
			return ret;
		}
	}

	static public function toHaxe(obj:Dynamic):Dynamic {
		var array = Std.instance(obj, Array);
		if (array != null) {
			return [for (e in array) toHaxe(e)];
		} else {
			var ret = {};
			for (f in Reflect.fields(obj)) {
				var _f = switch (f) {
					case "private": "priv";
					case "package": "pack";
					case _: f;
				}
				Reflect.setField(ret, _f, Reflect.field(obj, f));
			}
			return ret;
		}
	}
}