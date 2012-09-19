package com.mixpanel
{
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	
	public class StorageBackendTest
	{
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[Test(description="test SharedObjectBackend")]
		public function test_shared_object_backend():void {
			backendTest(SharedObjectBackend);
			backendTestPersistence(SharedObjectBackend);
		}
		
		[Test(description="test CookieBackend")]
		public function test_cookie_backend():void {
			backendTest(CookieBackend);
			backendTestPersistence(CookieBackend);
		}
		
		[Test(description="test NonPersistentBackend")]
		public function test_non_persistent_backend():void {
			backendTest(NonPersistentBackend);
		}
		
		public function backendTest(type:Class):void {
			var backend:IStorageBackend = new type("test") as IStorageBackend;
			
			Assert.assertTrue("Backend initializes successfully", backend.initialize());
			
			Assert.assertFalse(backend.has("test"));
			Assert.assertEquals(backend.get("test"), undefined);
			backend.set("test", "testval");
			Assert.assertTrue(backend.has("test"));
			Assert.assertEquals(backend.get("test"), "testval");
			backend.del("test");
			Assert.assertFalse(backend.has("test"));
			
			Assert.assertFalse(backend.data.hasOwnProperty("test"));
		}
		
		public function backendTestPersistence(type:Class):void {
			var b1:IStorageBackend = new type("testpers") as IStorageBackend;
			b1.initialize();
			b1.set("loadme", "val");
			
			var b2:IStorageBackend = new type("testpers") as IStorageBackend;
			b2.initialize();
			Assert.assertEquals("val", b2.get("loadme"));
		}
	}
}