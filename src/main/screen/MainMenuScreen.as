package main.screen
{
    import feathers.controls.ButtonGroup;
    import feathers.controls.PanelScreen;
    import feathers.data.ListCollection;
    import feathers.layout.AnchorLayout;
    import feathers.layout.AnchorLayoutData;

    import starling.events.Event;

    public class MainMenuScreen extends PanelScreen
    {
        public static const EVENT_SHOW_NEW_SPLIT:String = "eventShowNewSplit";
        public static const EVENT_SHOW_LOAD_SPLIT:String = "eventShowLoadSplit";
        public static const EVENT_SHOW_ABOUT:String = "eventShowAbout";

        private var _buttonGroup:ButtonGroup;

        public override function dispose():void
        {
            if (_isInitialized)
            {
                _buttonGroup.removeEventListener(Event.TRIGGERED, buttonGroup_triggeredHandler);
            }
            super.dispose();
        }

        protected override function initialize():void
        {
            super.initialize();

            headerProperties.title = "Main Menu";
            layout = new AnchorLayout();

            _buttonGroup = new ButtonGroup();
            _buttonGroup.dataProvider = new ListCollection([
                                                               { label: "New Split", event: EVENT_SHOW_NEW_SPLIT },
                                                               { label: "Load Split", event: EVENT_SHOW_LOAD_SPLIT },
                                                               { label: "About", event: EVENT_SHOW_ABOUT }
                                                           ]);
            _buttonGroup.addEventListener(Event.TRIGGERED, buttonGroup_triggeredHandler);
            var buttonGroupLayoutData:AnchorLayoutData = new AnchorLayoutData();
            buttonGroupLayoutData.horizontalCenter = 0;
            buttonGroupLayoutData.verticalCenter = 0;
            _buttonGroup.layoutData = buttonGroupLayoutData;
            addChild(_buttonGroup);
        }

        private function buttonGroup_triggeredHandler(event:Event, data:Object):void
        {
            dispatchEventWith(data.event);
        }
    }
}