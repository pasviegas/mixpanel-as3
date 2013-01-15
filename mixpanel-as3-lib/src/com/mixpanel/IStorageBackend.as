package com.mixpanel
{
	internal interface IStorageBackend
	{
		function IStorageBackend(name:String);
		function initialize():IStorageBackend;
		function save():void;
		
		function updateCrossDomain(crossDomainStorage:Boolean):void;
		
		function has(key:String):Boolean;
		function get(key:String):*;
		function set(key:String, val:*, save:Boolean=true):void;
		function del(key:String):void;
		function clear():void;
		
		function get data():Object;
	}
}