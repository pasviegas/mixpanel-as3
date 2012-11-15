package com.mixpanel
{
	import com.adobe.serialization.json.JSONDecoder;
	import com.adobe.serialization.json.JSONEncoder;
	import com.mixpanel.Base64Encoder;
	
	import flash.external.ExternalInterface;
	import flash.system.System;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	internal class Util
	{
		private var base64Instance:Base64Encoder;
		
		public function Util()
		{
			base64Instance = new Base64Encoder();
		}
		
		public function jsonEncode(o:Object):String
		{
			return new JSONEncoder(o).getString();
		}
		
		public function jsonDecode(s:String):Object {
			return new JSONDecoder(s, true).getValue();
		}
		
		public function base64Encode(data:String):String
		{
			base64Instance.encode(data);
			return base64Instance.toString();
		}
		
		public function browserProtocol():String
		{
			var ret:String = "https:";
			if (ExternalInterface.available) {
				try {
					var extProtocol:String = ExternalInterface.call("document.location.protocol.toString");
					ret = (extProtocol && extProtocol.search("file") == -1) ? extProtocol : ret; 
				} catch (err:Error) {}
			}
			return ret;
		}
		
		public function extend(obj1:*, ...args):*
		{
			for (var i:String in args) {
				for (var param:String in args[i]) {
					obj1[param] = args[i][param];
				}
			}
			
			return obj1;
		}
		
		public function truncate(obj:*, length:int = 255):* {
			var ret:*,
				className:String = getQualifiedClassName(obj),
				len:int, i:int;
			
			if (className == "String") {
				ret = (obj as String).slice(0, length);
			} else if (className == "Array") {
				ret = [], len = obj.length;
				for (i = 0; i < len; i++) {
					ret.push(truncate(obj[i], length));
				}
			} else if (className == "Object") {
				ret = {};
				for (var key:String in obj) {
					ret[key] = truncate(obj[key], length);
				}
			} else {
				ret = obj;
			}
			
			return ret;
		}
		
		// Char codes for 0123456789ABCDEF
		private static const ALPHA_CHAR_CODES:Array = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];

		// From http://code.google.com/p/actionscript-uuid/
		// MIT License
		public function UUID():String {
			var buff:ByteArray = new ByteArray(),
				r:uint = uint(new Date().time);					
			buff.writeUnsignedInt(System.totalMemory ^ r);
			buff.writeInt(getTimer() ^ r);
			buff.writeDouble(Math.random() * r);
			
			buff.position = 0;
			var chars:Array = new Array(36);
			var index:uint = 0;
			for (var i:uint = 0; i < 16; i++)
			{
				if (i == 4 || i == 6 || i == 8 || i == 10)
				{
					chars[index++] = 45; // Hyphen char code
				}
				var b:int = buff.readByte();
				chars[index++] = ALPHA_CHAR_CODES[(b & 0xF0) >>> 4];
				chars[index++] = ALPHA_CHAR_CODES[(b & 0x0F)];
			}
			return String.fromCharCode.apply(null, chars);
		}
	}
}









