package com.mixpanel
{
	import com.adobe.serialization.json.JSONParseError;
	
	import flash.external.ExternalInterface;
	
	internal class CookieBackend implements IStorageBackend
	{
		private static var inserted_js:Boolean = false;
		
		private static const getCookie:String = "mp_get_cookie";
		private static var functionGetCookie:String = ( <![CDATA[
			function () {
				if (!window.mp_get_cookie) {
					window.mp_get_cookie = function (name) {
						var nameEQ = name + "=";
						var ca = document.cookie.split(';');
						for(var i=0;i < ca.length;i++) {
							var c = ca[i];
							while (c.charAt(0)==' ') c = c.substring(1,c.length);
							if (c.indexOf(nameEQ) == 0) return decodeURIComponent(c.substring(nameEQ.length,c.length));
						}
						return null;
					}
				}
			}
		]]> ).toString();
		
		private static const setCookie:String = "mp_set_cookie";
		private static var functionSetCookie:String = ( <![CDATA[
					function () {
						if (!window.mp_set_cookie) {
							window.mp_set_cookie = function (name, value) {
								var date = new Date();
								date.setTime(date.getTime()+(364*24*60*60*1000));
								var expires = "; expires=" + date.toGMTString();
								document.cookie = name+"="+encodeURIComponent(value)+expires+";";
							}
						}
					}
				]]> ).toString();
		
		private var util:Util = new Util();
		private var name:String;
		private var o:Object;
		
		public function CookieBackend(name:String)
		{
			this.name = name;
		}
		
		public function initialize():IStorageBackend {
			if (ExternalInterface.available) {
				try {
					ExternalInterface.addCallback("test_external_iface", null);					
				} catch (error:SecurityError) {
					return null;
				}
			} else {
				return null;
			}
			
			if (!CookieBackend.inserted_js) {
				ExternalInterface.call(functionGetCookie);
				ExternalInterface.call(functionSetCookie);
				CookieBackend.inserted_js = true;
			}
		
			this.o = load();
			
			return this;
		}

		private function load():Object {
			var data:String = ExternalInterface.call(getCookie, name) as String;
			try {
				if (data) { return util.jsonDecode(data); }
			} catch (err:JSONParseError) {
				// ignore json parse errors
			}
			
			return {};
		}
		
		public function save():void
		{
			ExternalInterface.call(setCookie, name, util.jsonEncode(o));
		}
		
		public function updateCrossDomain(crossDomainStorage:Boolean):void {
			//nop
		}
		
		public function has(key:String):Boolean
		{
			return o.hasOwnProperty(key);
		}
		
		public function get(key:String):*
		{
			return o[key];
		}
		
		public function set(key:String, val:*, save:Boolean=true):void
		{
			o[key] = val;
			if (save) { this.save(); }
		}
		
		public function del(key:String):void {
			delete o[key];
			save();
		}
		
		public function clear():void {
			this.o = {};
			save();
		}
		
		public function get data():Object {
			return o;
		}
	}
}