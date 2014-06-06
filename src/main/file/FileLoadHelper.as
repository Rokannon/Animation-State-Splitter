package main.file {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	
	import starling.events.EventDispatcher;
	
	public class FileLoadHelper extends EventDispatcher {
		
		public static const EVENT_COMPLETE:String = "eventComplete";
		public static const EVENT_ABORT:String = "eventAbort";
		
		private const _fileReference:FileReference = new FileReference();
		
		public function FileLoadHelper() {
			
			super();
			
			_fileReference.addEventListener(Event.COMPLETE, onFileReferenceComplete);
			_fileReference.addEventListener(Event.SELECT, onFileReferenceSelect);
			_fileReference.addEventListener(Event.CANCEL, onFileReferenceCancel);
			_fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFileReferenceIOError);
			
		}
		
		public function getContent():String {
			
			return _fileReference.data.readUTFBytes(_fileReference.data.bytesAvailable);
			
		}
		
		public function browse():void {
			
			_fileReference.browse();
			
		}
		
		public function dispose():void {
			
			_fileReference.removeEventListener(Event.COMPLETE, onFileReferenceComplete);
			_fileReference.removeEventListener(Event.SELECT, onFileReferenceSelect);
			_fileReference.removeEventListener(Event.CANCEL, onFileReferenceCancel);
			_fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onFileReferenceIOError);
			
		}
		
		private function onFileReferenceComplete(event:Event):void {
			
			dispatchEventWith(EVENT_COMPLETE);
			
		}
		
		private function onFileReferenceSelect(event:Event):void {
			
			_fileReference.load();
			
		}
		
		private function onFileReferenceCancel(event:Event):void {
			
			dispatchEventWith(EVENT_ABORT);
			
		}
		
		private function onFileReferenceIOError(event:IOErrorEvent):void {
			
			dispatchEventWith(EVENT_ABORT);
			
		}
		
	}
	
}