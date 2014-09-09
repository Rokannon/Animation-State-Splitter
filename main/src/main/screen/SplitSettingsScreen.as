package main.screen
{
    import feathers.controls.Alert;
    import feathers.controls.Button;
    import feathers.controls.Label;
    import feathers.controls.List;
    import feathers.controls.PanelScreen;
    import feathers.controls.TextInput;
    import feathers.controls.ToggleSwitch;
    import feathers.core.PopUpManager;
    import feathers.data.ListCollection;
    import feathers.layout.AnchorLayout;
    import feathers.layout.AnchorLayoutData;

    import flash.events.FileListEvent;
    import flash.filesystem.File;

    import main.data.SplitData;

    import starling.display.DisplayObject;
    import starling.events.Event;

    public class SplitSettingsScreen extends PanelScreen
    {
        public static const EVENT_MAIN_MENU:String = "eventMainMenu";
        public static const EVENT_CONTINUE:String = "eventContinue";

        private static const ALERT_MESSAGE_1:String = "Are you sure you want to exit to main menu?\n" + "All unsaved data will be lost.";
        private static const ALERT_MESSAGE_2:String = "Unable to resolve path:\n";
        private static const ALERT_MESSAGE_3:String = "Path leads to a file - not a directory:\n";
        private static const ALERT_MESSAGE_4:String = "Directory does not contain any valid images.";
        private static const ALERT_LABEL_CANCEL:String = "Cancel";
        private static const ALERT_LABEL_OK:String = "OK";

        public var splitData:SplitData;
        public var files:Vector.<File>;

        private var _mainMenuButton:Button;
        private var _continueButton:Button;
        private var _list:List;
        private var _imagesPathInput:TextInput;
        private var _addStatePrefixSwitch:ToggleSwitch;
        private var _suffixFilterInput:TextInput;
        private var _verifyingLabel:Label;

        override public function dispose():void
        {
            if (_isInitialized)
            {
                _mainMenuButton.removeEventListener(Event.TRIGGERED, mainMenuButton_triggeredHandler);
                _continueButton.removeEventListener(Event.TRIGGERED, continueButton_triggeredHandler);
                _imagesPathInput.removeEventListener(Event.CHANGE, imagesPathInput_changeHandler);
                _addStatePrefixSwitch.removeEventListener(Event.CHANGE, addStatePrefixSwitch_changeHandler);
                _suffixFilterInput.removeEventListener(Event.CHANGE, suffixFilterInput_changeHandler);
            }
            super.dispose();
        }

        override protected function initialize():void
        {
            super.initialize();

            headerProperties.title = "Split Settings";
            layout = new AnchorLayout();

            _mainMenuButton = new Button();
            _mainMenuButton.nameList.add(Button.ALTERNATE_NAME_BACK_BUTTON);
            _mainMenuButton.label = "Main Menu";
            _mainMenuButton.addEventListener(Event.TRIGGERED, mainMenuButton_triggeredHandler);
            headerProperties.leftItems = new <DisplayObject> [
                _mainMenuButton
            ];

            _continueButton = new Button();
            _continueButton.nameList.add(Button.ALTERNATE_NAME_FORWARD_BUTTON);
            _continueButton.label = "Continue";
            _continueButton.addEventListener(Event.TRIGGERED, continueButton_triggeredHandler);
            checkContinueButton();
            headerProperties.rightItems = new <DisplayObject> [
                _continueButton
            ];

            _imagesPathInput = new TextInput();
            _imagesPathInput.text = splitData.imagesPath;
            _imagesPathInput.width = 500;
            _imagesPathInput.addEventListener(Event.CHANGE, imagesPathInput_changeHandler);

            _addStatePrefixSwitch = new ToggleSwitch();
            _addStatePrefixSwitch.isSelected = splitData.addStatePrefix;
            _addStatePrefixSwitch.addEventListener(Event.CHANGE, addStatePrefixSwitch_changeHandler);

            _suffixFilterInput = new TextInput();
            _suffixFilterInput.text = splitData.suffixFilter;
            _suffixFilterInput.addEventListener(Event.CHANGE, suffixFilterInput_changeHandler);

            _list = new List();
            _list.itemRendererProperties.labelField = "text";
            _list.dataProvider = new ListCollection([
                                                        {
                                                            text: "Images Path",
                                                            accessory: _imagesPathInput
                                                        },
                                                        {
                                                            text: "Add State Prefix",
                                                            accessory: _addStatePrefixSwitch
                                                        },
                                                        {
                                                            text: "Suffix Filter",
                                                            accessory: _suffixFilterInput
                                                        }
                                                    ]);
            _list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
            _list.isSelectable = false;
            _list.clipContent = false;
            _list.autoHideBackground = true;
            _list.hasElasticEdges = false;
            addChild(_list);
        }

        private function imagesPathInput_changeHandler(event:Event):void
        {
            splitData.imagesPath = _imagesPathInput.text;
            checkContinueButton();
        }

        private function addStatePrefixSwitch_changeHandler(event:Event):void
        {
            splitData.addStatePrefix = _addStatePrefixSwitch.isSelected;
        }

        private function suffixFilterInput_changeHandler(event:Event):void
        {
            splitData.suffixFilter = _suffixFilterInput.text;
        }

        private function mainMenuButton_triggeredHandler(event:Event):void
        {
            var alert:Alert = Alert.show(ALERT_MESSAGE_1, "Alert", new ListCollection([
                                                                                          { label: ALERT_LABEL_CANCEL },
                                                                                          { label: ALERT_LABEL_OK }
                                                                                      ]));
            alert.addEventListener(Event.CLOSE, exitAlert_closeHandler);
        }

        private function exitAlert_closeHandler(event:Event, data:Object):void
        {
            event.target.removeEventListener(Event.CLOSE, exitAlert_closeHandler);

            if (data != null)
            {
                switch (data.label)
                {
                    case ALERT_LABEL_CANCEL:
                        // Do nothing.
//						LOGGER.info("Alert closed with 'Cancel' button.");
                        break;

                    case ALERT_LABEL_OK:
//						LOGGER.info("Alert closed with 'OK' button.");
                        dispatchEventWith(EVENT_MAIN_MENU);
                        break;

                    default:
//						LOGGER.warn("Alert closed with invalid button.");
                        break;
                }
            }
            else
            {
//				LOGGER.warn("Alert closed without button.");
            }
        }

        private function continueButton_triggeredHandler(event:Event):void
        {
            var file:File = File.userDirectory.resolvePath(splitData.imagesPath);
            if (!file.exists)
            {
                showSettingsErrorAlert(ALERT_MESSAGE_2 + splitData.imagesPath);
            }
            else if (!file.isDirectory)
            {
                showSettingsErrorAlert(ALERT_MESSAGE_3 + splitData.imagesPath);
            }
            else
            {
                _verifyingLabel = new Label();
                _verifyingLabel.text = "Verifying...";
                PopUpManager.addPopUp(_verifyingLabel);
                file.addEventListener(FileListEvent.DIRECTORY_LISTING, onGotDirectoryListing);
                file.getDirectoryListingAsync();
            }
        }

        private function onGotDirectoryListing(event:FileListEvent):void
        {
            event.target.removeEventListener(FileListEvent.DIRECTORY_LISTING, onGotDirectoryListing);

            PopUpManager.removePopUp(_verifyingLabel, true);
            _verifyingLabel = null;

            var numFiles:uint;
            if (splitData.suffixFilter.length == 0)
            {
                numFiles = event.files.length;
            }
            else
            {
                numFiles = 0;
                for each (var file:File in event.files)
                {
                    if (suffixCheck(file.name, splitData.suffixFilter) && !file.isDirectory)
                    {
                        ++numFiles;
                    }
                }
            }

            if (numFiles == 0)
            {
                showSettingsErrorAlert(ALERT_MESSAGE_4);
            }
            else
            {
                event.files.sortOn("name");
                files.length = 0;
                for (var i:uint = 0; i < numFiles; ++i)
                {
                    files[i] = event.files[i];
                }
                dispatchEventWith(EVENT_CONTINUE);
            }
        }

        private function showSettingsErrorAlert(message:String):void
        {
            Alert.show(message, "Error", new ListCollection([
                                                                { label: ALERT_LABEL_OK }
                                                            ]));
        }

        private function suffixCheck(string:String, suffix:String):Boolean
        {
            return string.lastIndexOf(suffix) == string.length - suffix.length;
        }

        private function checkContinueButton():void
        {
            _continueButton.isEnabled = splitData.imagesPath.length != 0;
        }
    }
}