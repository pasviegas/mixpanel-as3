package com.mixpanel
{
	import flash.net.SharedObject;

	internal class Storage
	{
		private var name:String;
		private var backend:IStorageBackend;
		
		public function Storage(config:Object)
		{
			name = config.storageName;
			
			// initialize backend
			backend =
				   new SharedObjectBackend(name).initialize()
				|| new CookieBackend(name).initialize()
				|| new NonPersistentBackend(name).initialize();
			
			updateCrossDomain(config.crossSubdomainStorage);
			upgrade(config.token);
		}
		
		public function updateCrossDomain(crossDomainStorage:Boolean):void {
			backend.updateCrossDomain(crossDomainStorage);
		}
		
		private function upgrade(token:String):void {
			var oldStorage:SharedObject = SharedObject.getLocal("mixpanel");
			if (!oldStorage.data[token]) { return; }
			
			var oldData:Object = oldStorage.data[token];
			
			if (oldData["all"]) { register(oldData.all); }
			if (oldData["events"]) { register(oldData.events); }
			
			delete oldStorage.data[token];
			oldStorage.flush();
		}
		
		public function has(key:String):Boolean {
			return backend.has(key);
		}
		
		public function get(key:String):* {
			return backend.get(key);
		}
		
		public function set(key:String, value:*):void {
			backend.set(key, value);
		}
		
		public function register(obj:Object):void {
			for (var key:String in obj) {
				backend.set(key, obj[key], false);
			}
			
			backend.save();
		}
		
		public function registerOnce(obj:Object, defaultValue:* = "None"):void {
			for (var key:String in obj) {
				if (!backend.has(key) || backend.get(key) == defaultValue) {
					backend.set(key, obj[key], false);
				}
			}
			
			backend.save();
		}
		
		public function unregister(property:String):void {
			backend.del(property);
		}
		
		public function unregister_all():void {
			backend.clear();
		}
		
		public function safeMerge(properties:Object):Object {
			for (var key:String in backend.data) {
				if (!properties[key]) { properties[key] = backend.get(key); }
			}
			return properties;
		}
	}
}