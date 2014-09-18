package com.rokannon.project.AnimationStateSplitter
{
    import feathers.system.DeviceCapabilities;

    import flash.desktop.NativeApplication;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.InvokeEvent;

    import starling.core.Starling;
    import starling.events.Event;

    [SWF(width="640", height="480", frameRate="60")]
    public class Main extends Sprite
    {
        private var _starling:Starling;
        private var _invokeArguments:Array;

        public function Main()
        {
            NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);

            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            DeviceCapabilities.dpi = 450;

            _starling = new Starling(StarlingApplication, stage);
            _starling.addEventListener(Event.ROOT_CREATED, onRootCreated);
            _starling.start();
        }

        private function onInvoke(event:InvokeEvent):void
        {
            NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvoke);
            _invokeArguments = event.arguments;
        }

        private function onRootCreated(event:Event):void
        {
            var starlingApplication:StarlingApplication = _starling.root as StarlingApplication;
            starlingApplication.launch(_invokeArguments[0]);
        }
    }
}