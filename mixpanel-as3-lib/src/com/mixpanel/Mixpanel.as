package com.mixpanel
{
	import com.mixpanel.Storage;
	import com.mixpanel.Util;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	/**
	 * Mixpanel AS3 API
	 * <p>Version 2.0.2</p>
	 */
	
	public class Mixpanel
	{
		private var _:Util;
		private var token:String;
		private var disableAllEvents:Boolean = false;
		private var disabledEvents:Array = [];
		
		/**
		 * @private 
		 */		
		internal var storage:Storage;
		
		/**
		 * @private 
		 */
		internal var config:Object;
		
		private var defaultConfig:Object = {
			crossSubdomainStorage: true,
			test: false
		};
		
		/**
		 * Create an instance of the Mixpanel library 
		 * 
		 * @param token your Mixpanel API token
		 * 
		 */		
		public function Mixpanel(token:String)
		{
			_ = new Util();
			token = token;
			var protocol:String = _.browserProtocol();
			
			config = _.extend({}, defaultConfig, {
				apiHost: protocol + '//api.mixpanel.com/track/',
				storageName: "mp_" + token,
				token: token
			});
			
			storage = new Storage(config);
		}
		
		private function sendRequest(data:*, callback:Function=null):void {			
			var request:URLRequest = new URLRequest(config.apiHost);
			request.method = URLRequestMethod.GET;
			var params:URLVariables = new URLVariables();
			
			params = _.extend(params, data, {
				_: new Date().time.toString()
			});
			if (config["test"]) { params["test"] = 1; }
			
			request.data = params;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE,
				function(e:Event):void {
					if(callback != null) {
						callback(loader.data);
					}
				});
			loader.addEventListener(IOErrorEvent.IO_ERROR,
				function(e:IOErrorEvent):void {
					if(callback != null) {
						callback(0);
					}
				});
			
			loader.load(request);
		}
		
		
		/**
		 * Track an event.  This is the most important Mixpanel function and
		 * the one you will be using the most
		 *  
		 * @param event the name of the event
		 * @param args if the first arg in args is an object, it will be used
		 * as the properties object.  The last argument is a callback function.
		 * The callback and properties arguments are both optional.
		 * @return the data sent to the server
		 * 
		 */
		public function track(event:String, ...args):Object
		{
			var properties:Object = null, callback:Function = null;
			
			if (args.length == 2) {
				properties = args[0];
				callback = args[1];
			} else {
				if (args[0] is Function) {
					callback = args[0];
				} else {
					properties = args[0];
				}
			}
			
			if (disableAllEvents || disabledEvents.indexOf(event) != -1) {
				if (callback != null) { return callback(0); }
			}

			properties = properties ? _.extend({}, properties) : {};

			if (!properties["token"]) { properties.token = config.token; }
			properties["time"] = _.getUnixTime();
			properties["mp_lib"] = "as3";

			this.register_once({ 'distinct_id': _.UUID() }, "");

			properties = storage.safeMerge(properties);

			var data:Object = {
				"event": event,
				"properties": properties
			};
			
			var truncatedData:Object = _.truncate(data, 255),
				jsonData:String = _.jsonEncode(truncatedData),
				encodedData:String = _.base64Encode(jsonData);
			
			sendRequest(
				{
					"data": encodedData,
					"ip": 1
				},
				callback
			);
			
			return truncatedData;
		}
		
		/**
		 * Disable events on the Mixpanel object.  If passed no arguments,
	     * this function disables tracking of any event.  If passed an
	     * array of event names, those events will be disabled, but other
	     * events will continue to be tracked.
	     *
	     * <p>Note: this function doesn't stop regular mixpanel functions from
	     * firing such as register and name_tag.</p> 
		 *
		 * @param events A array of event names to disable 
		 */		
		public function disable(events:Array = null):void
		{
			if (events == null) {
				disableAllEvents = true;
			} else {
				disabledEvents = disabledEvents.concat(events);
			}
		}
		
		/**
  		 * Register a set of super properties, which are included with all
	     * events/funnels.  This will overwrite previous super property
	     * values.  It is mutable unlike register_once.
		 * 
		 * @param properties Associative array of properties to store about the user
		 */		
		public function register(properties:Object):void
		{
			storage.register(properties);			
		}
		
		/**
		 * Register a set of super properties only once.  This will not
		 * overwrite previous super property values, unlike register().
		 * It's basically immutable.
		 *  
		 * @param properties Associative array of properties to store about the user
		 * @param defaultValue Value to override if already set in super properties (ex: "False")
		 * 
		 */		
		public function register_once(properties:Object, defaultValue:* = null):void
		{
			storage.registerOnce(properties, defaultValue);
		}
		
		/**
		 * Delete a super property stored with the current user.
		 *  
		 * @param property the name of the super property to remove
		 * 
		 */		
		public function unregister(property:String):void
		{
			storage.unregister(property);
		}
		
		/**
		 * Identify a user with a unique id.  All subsequent
	     * actions caused by this user will be tied to this identity.  This
	     * property is used to track unique visitors.  If the method is
	     * never called, then unique visitors will be identified by a UUID
	     * generated the first time they visit the site.
		 * 
		 * @param uniqueID A string that uniquely identifies the user
		 * 
		 */		
		public function identify(uniqueID:String):void
		{
			storage.register({ "distinct_id": uniqueID });
		}
		
		/**
		 * Provide a string to recognize the user by.  The string passed to
	     * this method will appear in the Mixpanel Streams product rather
	     * than an automatically generated name.  Name tags do not have to
	     * be unique.
		 *  
		 * @param name A human readable name for the user
		 * 
		 */		
		public function name_tag(name:String):void
		{
			storage.register({ "mp_name_tag": name });
		} 
		
		/**
		 * Set properties on a user record
		 * 
		 * <p>Usage:</p>
		 * 
		 * <pre>
		 * 		mixpanel.people_set('gender', 'm');
		 * 
		 * 		mixpanel.people.set({
		 * 			'company': 'Acme',
		 * 			'plan': 'free'
		 * 		});
		 * 
		 * 		// properties can be strings, integers or dates
		 * </pre>
		 */
		public function people_set(...args):Object
		{
			if (!storage.has("distinct_id")) {
				trace("Error: identify() must be called before people_set can be used");
				return { "error": "identify() must be called before people_set can be used" };
			}
			
			var $set:Object = {}, callback:Function = null;
			
			if (args[0] is String) {
				$set[args[0]] = args[1];
			} else {
				$set = args[0];
			}
			
			if (args[args.length-1] is Function) {
				callback = args[args.length-1];
			}
			
			$set = $set ? _.extend({}, $set) : {};
			
			var data:Object = {
				"$set": $set,
				"$token": config.token,
				"$distinct_id": storage.get("distinct_id")
			};
			
			var truncatedData:Object = _.truncate(data, 255),
				jsonData:String = _.jsonEncode(truncatedData),
				encodedData:String = _.base64Encode(jsonData);
			
			sendRequest(
				{
					"data": encodedData,
					"ip": 1
				},
				callback
			);
			
			return truncatedData;
		}
		
		/**
		 * Increment/decrement properties on a user record
		 * 
		 * <p>Usage:</p>
		 * 
		 * <pre>
		 * 		mixpanel.people_increment('page_views', 1);
		 * 
		 * 		// or, for convienience, if you're just incrementing a counter by 1, you can
		 * 		// simply do
		 * 		mixpanel.people_increment('page_views');
		 * 
		 * 		// to decrement a counter, pass a negative number
		 * 		mixpanel.people.increment('credits_left', -1);
		 * 
		 * 		// like mixpanel.people_set(), you can increment multiple properties at once:
		 * 		mixpanel.people.increment({
		 * 			'counter1': '1',
		 * 			'counter2': '3'
		 * 		});
		 * </pre>
		 */
		public function people_increment(...args):Object
		{
			if (!storage.has("distinct_id")) {
				trace("Error: identify() must be called before people_increment can be used");
				return { "error": "identify() must be called before people_increment can be used" };
			}
			
			var props:Object = {}, callback:Function = null;
			
			if (args[0] is String) {
				props[args[0]] = args[1];
			} else {
				props = args[0];
			}
			
			if (args[args.length-1] is Function) {
				callback = args[args.length-1];
			}
			
			var $add:Object = {};
			for (var key:String in props) {
				if (props[key] is Number) { $add[key] = props[key]; }
			}
			
			var data:Object = {
				"$add": $add,
				"$token": config.token,
				"$distinct_id": storage.get("distinct_id")
			};
			
			var truncatedData:Object = _.truncate(data, 255),
				jsonData:String = _.jsonEncode(truncatedData),
				encodedData:String = _.base64Encode(jsonData);
			
			sendRequest(
				{
					"data": encodedData,
					"ip": 1
				},
				callback
			);
			
			return truncatedData;
		}
		
		/**
		 * delete the current user record (using current distinct_id)
		 * 
		 * <p>Usage:</p>
		 * 		
		 * <pre>
		 * 		mixpanel.people_delete();
		 * </pre>
		 */
		public function people_delete(...args):Object
		{
			if (!storage.has("distinct_id")) {
				trace("Error: identify() must be called before people_delete can be used");
				return { "error": "identify() must be called before people_delete can be used" };
			}
			
			var callback:Function = null;
			if (args[0] is Function) {
				callback = args[0];
			}
			
			var data:Object = {
				"$delete": storage.get("distinct_id"),
				"$token": config.token,
				"$distinct_id": storage.get("distinct_id")
			};
			
			var truncatedData:Object = _.truncate(data, 255),
				jsonData:String = _.jsonEncode(truncatedData),
				encodedData:String = _.base64Encode(jsonData);
			
			sendRequest(
				{
					"data": encodedData,
					"ip": 1
				},
				callback
			);
			
			return truncatedData;
		}

		/**
		 * Update the configuration of a mixpanel library instance.
		 * 
		 * <p>The default config is:</p>
		 * <pre>
		 * {
		 *     // super properties span subdomains
		 *     crossSubdomainStorage: true,
		 * 
		 *     // enable test in development mode
		 *     test: false
		 * };
		 * </pre>
		 *  
		 * @param config A dictionary of new configuration values to update
		 * 
		 */		
		public function set_config(config:Object):void
		{
			if (config["crossSubdomainStorage"] && config.crossSubdomainStorage != this.config.crossSubdomainStorage) {
				storage.updateCrossDomain(config.crossSubdomainStorage);
			}
			_.extend(this.config, config);
		}
	}
}