package main.screen
{
    import com.rokannon.core.utils.string.intToString;
    import com.rokannon.math.utils.getMax;
    import com.rokannon.math.utils.getMin;

    import feathers.controls.Button;
    import feathers.controls.Header;
    import feathers.controls.List;

    import feathers.controls.PanelScreen;
    import feathers.core.IFeathersControl;
    import feathers.data.ListCollection;
    import feathers.layout.AnchorLayout;
    import feathers.layout.AnchorLayoutData;

    import main.data.SplitData;
    import main.data.StateData;

    import starling.display.DisplayObject;

    import starling.events.Event;

    public class SplitLayoutScreen extends PanelScreen
    {
        public static const EVENT_SETTINGS:String = "eventSettings";
        public static const EVENT_CONTINUE:String = "eventContinue";
        public static const EVENT_EDIT:String = "eventEdit";

        public var splitData:SplitData;
        public var stateEditProperties:Object;

        private var _settingsButton:Button;
        private var _continueButton:Button;
        private var _editButton:Button;
        private var _newStateButton:Button;
        private var _list:List;
        private var _moveUpButton:Button;
        private var _moveDownButton:Button;

        public override function dispose():void
        {
            if (_isInitialized)
            {
                _settingsButton.removeEventListener(Event.TRIGGERED, settingsButton_triggeredHandler);
                _continueButton.removeEventListener(Event.TRIGGERED, continueButton_triggeredHandler);
                _editButton.removeEventListener(Event.TRIGGERED, continueButton_triggeredHandler);
                _newStateButton.removeEventListener(Event.TRIGGERED, newStateButton_triggeredHandler);
                _list.removeEventListener(Event.CHANGE, list_changeHandler);
            }
            super.dispose();
        }

        protected override function initialize():void
        {
            super.initialize();

            headerProperties.title = "Split Layout";
            layout = new AnchorLayout();
            footerFactory = function ():IFeathersControl
            {
                return new Header();
            };

            _settingsButton = new Button();
            _settingsButton.nameList.add(Button.ALTERNATE_NAME_BACK_BUTTON);
            _settingsButton.label = "Settings";
            _settingsButton.addEventListener(Event.TRIGGERED, settingsButton_triggeredHandler);
            headerProperties.leftItems = new <DisplayObject> [
                _settingsButton
            ];

            _continueButton = new Button();
            _continueButton.nameList.add(Button.ALTERNATE_NAME_FORWARD_BUTTON);
            _continueButton.label = "Continue";
            _continueButton.addEventListener(Event.TRIGGERED, continueButton_triggeredHandler);
            headerProperties.rightItems = new <DisplayObject> [
                _continueButton
            ];

            _editButton = new Button();
            _editButton.label = "Edit";
            _editButton.addEventListener(Event.TRIGGERED, editButton_triggeredHandler);

            _newStateButton = new Button();
            _newStateButton.label = "New State";
            _newStateButton.addEventListener(Event.TRIGGERED, newStateButton_triggeredHandler);

            footerProperties.rightItems = new <DisplayObject> [
                _editButton, _newStateButton
            ];

            _list = new List();
            _list.itemRendererProperties.labelField = "text";
            _list.itemRendererProperties.accessoryLabelField = "accessoryText";
            _list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
            _list.isSelectable = true;
            _list.clipContent = false;
            _list.autoHideBackground = true;
            _list.hasElasticEdges = false;
            _list.addEventListener(Event.CHANGE, list_changeHandler);
            updateList();
            addChild(_list);

            _moveUpButton = new Button();
            _moveUpButton.label = "Move Up";
            _moveUpButton.addEventListener(Event.TRIGGERED, moveUpButton_triggeredHandler);

            _moveDownButton = new Button();
            _moveDownButton.label = "Move Down";
            _moveDownButton.addEventListener(Event.TRIGGERED, moveDownButton_triggeredHandler);

            footerProperties.leftItems = new <DisplayObject> [
                _moveUpButton, _moveDownButton
            ];

            updateButtons();
        }

        private function list_changeHandler(event:Event):void
        {
            updateButtons();
        }

        private function settingsButton_triggeredHandler(event:Event):void
        {
            dispatchEventWith(EVENT_SETTINGS);
        }

        private function continueButton_triggeredHandler(event:Event):void
        {
            dispatchEventWith(EVENT_CONTINUE);
        }

        private function editButton_triggeredHandler(event:Event):void
        {
            stateEditProperties.stateData = splitData.stateDatas[_list.selectedIndex];
            stateEditProperties.isNewState = false;
            dispatchEventWith(EVENT_EDIT);
        }

        private function newStateButton_triggeredHandler(event:Event):void
        {
            var stateData:StateData = new StateData();
            stateData.name = "";
            splitData.stateDatas.push(stateData);
            stateEditProperties.stateData = stateData;
            stateEditProperties.isNewState = true;
            dispatchEventWith(EVENT_EDIT);
        }

        private function moveUpButton_triggeredHandler(event:Event):void
        {
            var newIndex:int = getMax(0, _list.selectedIndex - 1);
            var stateData:StateData = splitData.stateDatas[newIndex];
            splitData.stateDatas[newIndex] = splitData.stateDatas[_list.selectedIndex];
            splitData.stateDatas[_list.selectedIndex] = stateData;
            updateList();
            _list.selectedIndex = newIndex;
        }

        private function moveDownButton_triggeredHandler(event:Event):void
        {
            var newIndex:int = getMin(splitData.stateDatas.length - 1, _list.selectedIndex + 1);
            var stateData:StateData = splitData.stateDatas[newIndex];
            splitData.stateDatas[newIndex] = splitData.stateDatas[_list.selectedIndex];
            splitData.stateDatas[_list.selectedIndex] = stateData;
            updateList();
            _list.selectedIndex = newIndex;
        }

        [Inline]
        private final function updateButtons():void
        {
            _continueButton.isEnabled = splitData.stateDatas.length > 0;
            _editButton.isEnabled = _list.selectedIndex >= 0;
            _moveUpButton.isEnabled = _list.selectedIndex > 0;
            _moveDownButton.isEnabled = _list.selectedIndex >= 0 && splitData.stateDatas.length > 1 && _list.selectedIndex < splitData.stateDatas.length - 1;
        }

        [Inline]
        private final function updateList():void
        {
            var items:Array = new Array();
            var length:uint = splitData.stateDatas.length;
            for (var i:uint = 0; i < length; ++i)
            {
                var stateData:StateData = splitData.stateDatas[i];
                var item:Object = new Object();
                item.text = (splitData.addStatePrefix ? "state_" + intToString(i + 1, 2) + "_" : "") + stateData.name;
                item.accessoryText = stateData.startFrame + "-" + stateData.endFrame;
                items.push(item);
            }
            _list.dataProvider = new ListCollection(items);
        }
    }
}