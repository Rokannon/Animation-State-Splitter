package com.rokannon.project.AnimationStateSplitter.file
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.FileReference;

    import starling.events.EventDispatcher;

    public class FileSaveHelper extends EventDispatcher
    {
        public static const EVENT_END:String = "eventEnd";

        private const _fileReference:FileReference = new FileReference();

        public function FileSaveHelper()
        {
            super();

            _fileReference.addEventListener(Event.COMPLETE, onFileReferenceComplete);
            _fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFileReferenceIOError);
            _fileReference.addEventListener(Event.CANCEL, onFileReferenceCancel);
        }

        public function save(data:*, defaultFileName:String = null):void
        {
            _fileReference.save(data, defaultFileName);
        }

        public function dispose():void
        {
            _fileReference.removeEventListener(Event.COMPLETE, onFileReferenceComplete);
            _fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onFileReferenceIOError);
            _fileReference.removeEventListener(Event.CANCEL, onFileReferenceCancel);
        }

        private function onFileReferenceComplete(event:Event):void
        {
            dispatchEventWith(EVENT_END);
        }

        private function onFileReferenceIOError(event:IOErrorEvent):void
        {
            dispatchEventWith(EVENT_END);
        }

        private function onFileReferenceCancel(event:Event):void
        {
            dispatchEventWith(EVENT_END);
        }
    }
}