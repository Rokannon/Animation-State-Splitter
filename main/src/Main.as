package
{
    import feathers.system.DeviceCapabilities;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;

    import main.StarlingApplication;

    import starling.core.Starling;
    import starling.events.Event;

    [SWF(width="640", height="480", frameRate="60")]
    public class Main extends Sprite
    {
        private var _starling:Starling;

        public function Main()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            DeviceCapabilities.dpi = 450;

            _starling = new Starling(StarlingApplication, stage);
            _starling.addEventListener(Event.ROOT_CREATED, onRootCreated);
            _starling.start();
        }

        private function onRootCreated(event:Event):void
        {
            var starlingApplication:StarlingApplication = _starling.root as StarlingApplication;
            starlingApplication.launch();
        }
    }
}