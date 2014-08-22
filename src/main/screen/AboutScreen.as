package main.screen
{
    import feathers.controls.Button;
    import feathers.controls.Label;
    import feathers.controls.PanelScreen;
    import feathers.layout.VerticalLayout;

    import starling.display.DisplayObject;

    import starling.events.Event;

    public class AboutScreen extends PanelScreen
    {
        public static const EVENT_BACK:String = "eventBack";

        private var _text:Label;
        private var _backButton:Button;

        public override function dispose():void
        {
            if (_isInitialized)
            {
                _backButton.removeEventListener(Event.TRIGGERED, backButton_triggeredHandler);
            }
            super.dispose();
        }

        protected override function initialize():void
        {
            super.initialize();

            headerProperties.title = "About";
            var verticalLayout:VerticalLayout = new VerticalLayout();
            verticalLayout.padding = 20 * this.dpiScale;
            layout = verticalLayout;

            _text = new Label();
            _text.text = "Animation State Splitter v1.0 created by Vladimir Atamanov";
            addChild(_text);

            _backButton = new Button();
            _backButton.nameList.add(Button.ALTERNATE_NAME_BACK_BUTTON);
            _backButton.label = "Back";
            _backButton.addEventListener(Event.TRIGGERED, backButton_triggeredHandler);
            headerProperties.leftItems = new <DisplayObject> [
                _backButton
            ];
        }

        private function backButton_triggeredHandler(event:Event):void
        {
            dispatchEventWith(EVENT_BACK);
        }
    }
}