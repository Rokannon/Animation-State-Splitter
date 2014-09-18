package com.rokannon.project.AnimationStateSplitter.screen
{
    import com.rokannon.core.utils.callOutStack;
    import com.rokannon.core.utils.string.intToString;
    import com.rokannon.project.AnimationStateSplitter.data.SplitData;
    import com.rokannon.project.AnimationStateSplitter.data.StateData;
    import com.rokannon.project.AnimationStateSplitter.file.FileCopyHelper;
    import com.rokannon.project.AnimationStateSplitter.file.FileSaveHelper;

    import feathers.controls.Alert;
    import feathers.controls.Button;
    import feathers.controls.Header;
    import feathers.controls.Label;
    import feathers.controls.List;
    import feathers.controls.PanelScreen;
    import feathers.controls.ProgressBar;
    import feathers.core.IFeathersControl;
    import feathers.core.PopUpManager;
    import feathers.data.ListCollection;
    import feathers.layout.AnchorLayout;
    import feathers.layout.AnchorLayoutData;

    import flash.filesystem.File;

    import starling.display.DisplayObject;
    import starling.events.Event;

    public class SplitOverviewScreen extends PanelScreen
    {
        public static const EVENT_LAYOUT:String = "eventLayout";

        private static const HELPER_STRINGS:Vector.<String> = new Vector.<String>();
        private static const STATUS_MESSAGE_COMPLETE:String = "Work complete.";
        private static const STATUS_MESSAGE_ERROR:String = "There was error copying files.";

        public var splitData:SplitData;
        public var files:Vector.<File>;

        private var _layoutButton:Button;
        private var _splitButton:Button;
        private var _saveButton:Button;
        private var _list:List;
        private var _workingLabel:Label;
        private var _progressBar:ProgressBar;

        override public function dispose():void
        {
            if (_isInitialized)
            {
                _layoutButton.removeEventListener(Event.TRIGGERED, layoutButton_triggeredHandler);
                _splitButton.removeEventListener(Event.TRIGGERED, splitButton_triggeredHandler);
                _saveButton.removeEventListener(Event.TRIGGERED, saveButton_triggeredHandler);
            }
            super.dispose();
        }

        override protected function initialize():void
        {
            super.initialize();

            headerProperties.title = "Split Overview";
            layout = new AnchorLayout();
            footerFactory = function ():IFeathersControl
            {
                return new Header();
            };

            _layoutButton = new Button();
            _layoutButton.label = "Layout";
            _layoutButton.nameList.add(Button.ALTERNATE_NAME_BACK_BUTTON);
            _layoutButton.addEventListener(Event.TRIGGERED, layoutButton_triggeredHandler);
            headerProperties.leftItems = new <DisplayObject> [
                _layoutButton
            ];

            _splitButton = new Button();
            _splitButton.label = "Split!";
            _splitButton.addEventListener(Event.TRIGGERED, splitButton_triggeredHandler);
            headerProperties.rightItems = new <DisplayObject> [
                _splitButton
            ];

            _saveButton = new Button();
            _saveButton.label = "Save";
            _saveButton.addEventListener(Event.TRIGGERED, saveButton_triggeredHandler);
            footerProperties.leftItems = new <DisplayObject> [
                _saveButton
            ];

            var items:Array = new Array();
            var numFiles:uint = files.length;
            for (var i:uint = 0; i < numFiles; ++i)
            {
                var item:Object = new Object();
                item.text = files[i].name;
                HELPER_STRINGS.length = 0;
                var numStates:uint = splitData.stateDatas.length;
                for (var j:uint = 0; j < numStates; ++j)
                {
                    var stateData:StateData = splitData.stateDatas[j];
                    if (stateData.startFrame <= i && i <= stateData.endFrame)
                    {
                        HELPER_STRINGS.push(stateData.name);
                    }
                }
                item.accessoryText = HELPER_STRINGS.join("|");
                items.push(item);
            }

            _list = new List();
            _list.itemRendererProperties.labelField = "text";
            _list.itemRendererProperties.accessoryLabelField = "accessoryText";
            _list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
            _list.isSelectable = false;
            _list.clipContent = false;
            _list.autoHideBackground = true;
            _list.hasElasticEdges = false;
            _list.dataProvider = new ListCollection(items);
            addChild(_list);
        }

        private function layoutButton_triggeredHandler(event:Event):void
        {
            dispatchEventWith(EVENT_LAYOUT);
        }

        private var _currentFileIndex:uint;
        private var _currentStateDataIndex:uint;

        private function splitButton_triggeredHandler(event:Event):void
        {
            _progressBar = new ProgressBar();
            _progressBar.minimum = 0;
            _progressBar.maximum = 1;
            _progressBar.value = 0;
            PopUpManager.addPopUp(_progressBar);

            _currentFileIndex = 0;
            _currentStateDataIndex = 0;
            if (files.length > 0 && splitData.stateDatas.length > 0)
            {
                copyNext();
            }
        }

        private function copyNext():void
        {
            _progressBar.value = (_currentFileIndex * splitData.stateDatas.length + _currentStateDataIndex) / (files.length * splitData.stateDatas.length);

            var file:File = files[_currentFileIndex];
            var stateData:StateData = splitData.stateDatas[_currentStateDataIndex];

            if (stateData.startFrame <= _currentFileIndex && _currentFileIndex <= stateData.endFrame)
            {
                var statePrefix:String = (splitData.addStatePrefix ? "state_" + intToString(_currentStateDataIndex + 1,
                                                                                            2) + "_" : "");
                var newFile:File = file.parent.resolvePath(statePrefix + stateData.name + File.separator + file.name);
                var fileCopyHelper:FileCopyHelper = new FileCopyHelper(file);
                fileCopyHelper.addEventListener(FileCopyHelper.EVENT_COMPLETE, fileCopyHelper_completeHandler);
                fileCopyHelper.addEventListener(FileCopyHelper.EVENT_ERROR, fileCopyHelper_errorHandler);
                fileCopyHelper.copyTo(newFile);
            }
            else if (setNextIndex())
            {
                callOutStack(copyNext);
            }
            else
            {
                onCopyEnd(STATUS_MESSAGE_COMPLETE);
            }
        }

        private function setNextIndex():Boolean
        {
            ++_currentStateDataIndex;
            if (_currentStateDataIndex < splitData.stateDatas.length)
            {
                return true;
            }
            else
            {
                _currentStateDataIndex = 0;
                ++_currentFileIndex;
                if (_currentFileIndex < files.length)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        private function fileCopyHelper_completeHandler(event:Event):void
        {
            var fileCopyHelper:FileCopyHelper = event.target as FileCopyHelper;
            fileCopyHelper.removeEventListener(FileCopyHelper.EVENT_COMPLETE, fileCopyHelper_completeHandler);
            fileCopyHelper.removeEventListener(FileCopyHelper.EVENT_ERROR, fileCopyHelper_errorHandler);
            fileCopyHelper.dispose();

            if (setNextIndex())
            {
                copyNext();
            }
            else
            {
                onCopyEnd(STATUS_MESSAGE_COMPLETE);
            }
        }

        private function fileCopyHelper_errorHandler(event:Event):void
        {
            var fileCopyHelper:FileCopyHelper = event.target as FileCopyHelper;
            fileCopyHelper.removeEventListener(FileCopyHelper.EVENT_COMPLETE, fileCopyHelper_completeHandler);
            fileCopyHelper.removeEventListener(FileCopyHelper.EVENT_ERROR, fileCopyHelper_errorHandler);
            fileCopyHelper.dispose();

            onCopyEnd(STATUS_MESSAGE_ERROR);
        }

        private function onCopyEnd(message:String):void
        {
            PopUpManager.removePopUp(_progressBar, true);
            _progressBar = null;

            Alert.show(message, "Status", new ListCollection([
                                                                 { label: "OK" }
                                                             ]));
        }

        private function saveButton_triggeredHandler(event:Event):void
        {
            _workingLabel = new Label();
            _workingLabel.text = "Saving...";
            PopUpManager.addPopUp(_workingLabel);

            var fileSaveHelper:FileSaveHelper = new FileSaveHelper();
            fileSaveHelper.addEventListener(FileSaveHelper.EVENT_END, fileSaveHelper_endHandler);
            fileSaveHelper.save(JSON.stringify(splitData.toObject()), "split_data.spl");
        }

        private function fileSaveHelper_endHandler(event:Event):void
        {
            onSaveEnd(event);
        }

        private function onSaveEnd(event:Event):void
        {
            PopUpManager.removePopUp(_workingLabel, true);
            _workingLabel = null;

            var fileSaveHelper:FileSaveHelper = event.target as FileSaveHelper;
            fileSaveHelper.removeEventListener(FileSaveHelper.EVENT_END, fileSaveHelper_endHandler);
            fileSaveHelper.dispose();
        }
    }
}