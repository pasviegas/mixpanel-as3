package com.mixpanel
{
	import flash.net.SharedObject;
	import flash.system.Security;

	internal class SharedObjectBackend implements IStorageBackend
	{	
		private var name:String;
		private var sharedObject:SharedObject;
		
		public function SharedObjectBackend(name:String)
		{
			this.name = name;
		}
		
		public function initialize():IStorageBackend {
			return load();
		}
		
		private function load():IStorageBackend {
			try {
				sharedObject = SharedObject.getLocal("mixpanel/" + name, "/");
			} catch (e:Error) {
				return null;
			}
			
			return this;
		}
		
		public function save():void
		{
			sharedObject.flush();
		}
		
		public function updateCrossDomain(crossDomainStorage:Boolean):void {
			try {
				Security.exactSettings = !crossDomainStorage;
			} catch(e:Error) {}
			
			load();
		}
		
		public function has(key:String):Boolean
		{
			return sharedObject.data.hasOwnProperty(key);
		}
		
		public function get(key:String):*
		{
			return sharedObject.data[key];
		}
		
		public function set(key:String, val:*, save:Boolean=true):void
		{
			sharedObject.data[key] = val;
			if (save) { this.save(); }
		}
		
		public function del(key:String):void {
			delete sharedObject.data[key];
			save();
		}
		
		public function clear():void {
			sharedObject.clear();
			save();
		}
		
		public function get data():Object {
			return sharedObject.data;
		}
	}
}