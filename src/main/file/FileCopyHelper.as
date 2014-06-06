package main.file {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	
	import starling.events.EventDispatcher;
	
	public class FileCopyHelper extends EventDispatcher {
		
		public static const EVENT_COMPLETE:String = "eventComplete";
		public static const EVENT_ERROR:String = "eventError";
		
		private var _file:File;
		
		public function FileCopyHelper(file:File) {
			
			super();
			
			_file = file;
			_file.addEventListener(Event.COMPLETE, onFileComplete);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onFileIOError);
			
		}
		
		public function copyTo(newLocation:FileReference, overwrite:Boolean = false):void {
			
			_file.copyToAsync(newLocation, overwrite);
			
		}
		
		public function dispose():void {
			
			_file.removeEventListener(Event.COMPLETE, onFileComplete);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, onFileIOError);
			
		}
		
		private function onFileComplete(event:Event):void {
			
			dispatchEventWith(EVENT_COMPLETE);
			
		}
		
		private function onFileIOError(event:IOErrorEvent):void {
			
			dispatchEventWith(EVENT_ERROR);
			
		}
		
	}
	
}