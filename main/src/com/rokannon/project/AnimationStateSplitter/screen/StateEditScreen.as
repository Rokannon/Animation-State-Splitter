package com.rokannon.project.AnimationStateSplitter.screen
{
    import com.rokannon.project.AnimationStateSplitter.data.SplitData;
    import com.rokannon.project.AnimationStateSplitter.data.StateData;

    import feathers.controls.Button;
    import feathers.controls.Header;
    import feathers.controls.List;
    import feathers.controls.PanelScreen;
    import feathers.controls.TextInput;
    import feathers.core.IFeathersControl;
    import feathers.data.ListCollection;
    import feathers.layout.AnchorLayout;
    import feathers.layout.AnchorLayoutData;

    import starling.display.DisplayObject;
    import starling.events.Event;

    public class StateEditScreen extends PanelScreen
    {
        public static const EVENT_RETURN:String = "eventReturn";

        public var stateData:StateData;
        public var splitData:SplitData;
        public var isNewState:Boolean;

        private var _stateData:StateData;
        private var _discardButton:Button;
        private var _applyButton:Button;
        private var _nameInput:TextInput;
        private var _startFrameInput:TextInput;
        private var _endFrameInput:TextInput;
        private var _list:List;
        private var _deleteButton:Button;

        override public function dispose():void
        {
            if (_isInitialized)
            {
                _discardButton.removeEventListener(Event.TRIGGERED, discardButton_triggeredHandler);
                _applyButton.removeEventListener(Event.TRIGGERED, applyButton_triggeredHandler);
                _nameInput.removeEventListener(Event.CHANGE, nameInput_changeHandler);
                _startFrameInput.removeEventListener(Event.CHANGE, startFrameInput_changeHandler);
                _endFrameInput.removeEventListener(Event.CHANGE, endFrameInput_changeHandler);
                _deleteButton.removeEventListener(Event.CHANGE, deleteButton_triggeredHandler);
            }
            super.dispose();
        }

        override protected function initialize():void
        {
            super.initialize();

            _stateData = new StateData();
            _stateData.copyFrom(stateData);

            headerProperties.title = "State Edit";
            layout = new AnchorLayout();
            footerFactory = function ():IFeathersControl
            {
                return new Header();
            };

            _discardButton = new Button();
            _discardButton.nameList.add(Button.ALTERNATE_NAME_BACK_BUTTON);
            _discardButton.label = "Discard";
            _discardButton.addEventListener(Event.TRIGGERED, discardButton_triggeredHandler);
            headerProperties.leftItems = new <DisplayObject> [
                _discardButton
            ];

            _applyButton = new Button();
            _applyButton.nameList.add(Button.ALTERNATE_NAME_FORWARD_BUTTON);
            _applyButton.label = "Apply";
            _applyButton.addEventListener(Event.TRIGGERED, applyButton_triggeredHandler);
            headerProperties.rightItems = new <DisplayObject> [
                _applyButton
            ];

            _nameInput = new TextInput();
            _nameInput.restrict = "a-zA-Z0-9_";
            _nameInput.text = _stateData.name;
            _nameInput.addEventListener(Event.CHANGE, nameInput_changeHandler);

            _startFrameInput = new TextInput();
            _startFrameInput.restrict = "0-9";
            _startFrameInput.text = _stateData.startFrame.toString();
            _startFrameInput.addEventListener(Event.CHANGE, startFrameInput_changeHandler);
            _startFrameInput.width = 100;

            _endFrameInput = new TextInput();
            _endFrameInput.restrict = "0-9";
            _endFrameInput.text = _stateData.endFrame.toString();
            _endFrameInput.addEventListener(Event.CHANGE, endFrameInput_changeHandler);
            _endFrameInput.width = 100;

            _list = new List();
            _list.itemRendererProperties.labelField = "text";
            _list.dataProvider = new ListCollection([
                                                        {
                                                            text: "Name",
                                                            accessory: _nameInput
                                                        },
                                                        {
                                                            text: "Start Frame",
                                                            accessory: _startFrameInput
                                                        },
                                                        {
                                                            text: "End Frame",
                                                            accessory: _endFrameInput
                                                        }
                                                    ]);
            _list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
            _list.isSelectable = false;
            _list.clipContent = false;
            _list.autoHideBackground = true;
            _list.hasElasticEdges = false;
            addChild(_list);

            _deleteButton = new Button();
            _deleteButton.styleNameList.add(Button.ALTERNATE_NAME_DANGER_BUTTON);
            _deleteButton.label = "Delete";
            _deleteButton.addEventListener(Event.TRIGGERED, deleteButton_triggeredHandler);
            footerProperties.leftItems = new <DisplayObject> [
                _deleteButton
            ];

            validateName();
        }

        private function nameInput_changeHandler(event:Event):void
        {
            _stateData.name = _nameInput.text;
            validateName();
        }

        private function startFrameInput_changeHandler(event:Event):void
        {
            _stateData.startFrame = parseInt(_startFrameInput.text);
        }

        private function endFrameInput_changeHandler(event:Event):void
        {
            _stateData.endFrame = parseInt(_endFrameInput.text);
        }

        private function discardButton_triggeredHandler(event:Event):void
        {
            if (isNewState)
            {
                var index:int = splitData.stateDatas.indexOf(stateData);
                splitData.stateDatas.splice(index, 1);
            }
            dispatchEventWith(EVENT_RETURN);
        }

        private function applyButton_triggeredHandler(event:Event):void
        {
            stateData.copyFrom(_stateData);
            dispatchEventWith(EVENT_RETURN);
        }

        private function deleteButton_triggeredHandler(event:Event):void
        {
            var index:int = splitData.stateDatas.indexOf(stateData);
            splitData.stateDatas.splice(index, 1);
            dispatchEventWith(EVENT_RETURN);
        }

        private function validateName():void
        {
            _applyButton.isEnabled = _stateData.name.length != 0;
        }
    }
}