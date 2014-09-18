package com.rokannon.project.AnimationStateSplitter.file
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;

    import starling.events.EventDispatcher;

    public class FileLoadHelper extends EventDispatcher
    {
        public static const EVENT_COMPLETE:String = "eventComplete";
        public static const EVENT_ERROR:String = "eventError";

        private var _file:File;

        public function FileLoadHelper(file:File)
        {
            super();

            _file = file;
            _file.addEventListener(Event.COMPLETE, onComplete);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onError);
        }

        public function load():void
        {
            _file.load();
        }

        public function getContent():String
        {
            return _file.data.toString();
        }

        private function onComplete(event:Event):void
        {
            _file.removeEventListener(Event.COMPLETE, onComplete);
            _file.removeEventListener(IOErrorEvent.IO_ERROR, onError);
            dispatchEventWith(EVENT_COMPLETE);
        }

        private function onError(event:IOErrorEvent):void
        {
            _file.removeEventListener(Event.COMPLETE, onComplete);
            _file.removeEventListener(IOErrorEvent.IO_ERROR, onError);
            dispatchEventWith(EVENT_ERROR);
        }
    }
}