package com.mixpanel
{
	internal class NonPersistentBackend implements IStorageBackend
	{
		private var o:Object;
		
		public function NonPersistentBackend(name:String)
		{}
		
		public function initialize():IStorageBackend {
			o = {};
			
			return this;
		}
		
		public function save():void
		{
			//nop
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
		}
		
		public function del(key:String):void {
			delete o[key];
		}
		
		public function clear():void {
			this.o = {};
		}
		
		public function get data():Object {
			return o;
		}
	}
}