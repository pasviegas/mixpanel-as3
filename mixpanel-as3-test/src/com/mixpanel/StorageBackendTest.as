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
			backendTestClear(SharedObjectBackend);
			backendTestClearPersistence(SharedObjectBackend);
		}
		
		[Test(description="test CookieBackend")]
		public function test_cookie_backend():void {
			backendTest(CookieBackend);
			backendTestPersistence(CookieBackend);
			backendTestClear(SharedObjectBackend);
			backendTestClearPersistence(SharedObjectBackend);
		}
		
		[Test(description="test NonPersistentBackend")]
		public function test_non_persistent_backend():void {
			backendTest(NonPersistentBackend);
			backendTestClear(SharedObjectBackend);
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
		
		public function backendTestClear(type:Class):void {
			var b1:IStorageBackend = new type("testclear") as IStorageBackend;
			b1.initialize();
			b1.set("test", "val");
			b1.set("test2", "val");
			
			Assert.assertTrue(b1.has('test') && b1.has('test2'));
			b1.clear();
			Assert.assertFalse(b1.has('test') || b1.has('test2'));
		}
		
		public function backendTestClearPersistence(type:Class):void {
			var b1:IStorageBackend = new type("testclearpers") as IStorageBackend;
			b1.initialize();
			b1.set("test", "val");
			
			Assert.assertEquals(b1.get('test'), 'val');
			b1.clear();
			Assert.assertFalse(b1.has('test'));
			
			b1.set("test2", 'val');
			b1.clear();
			
			var b2:IStorageBackend = new type("testclearpers") as IStorageBackend;
			b2.initialize();
			Assert.assertFalse(b2.has('test'));
			Assert.assertFalse(b2.has('test2'));
		}
	}
}