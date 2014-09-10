package main
{
    import feathers.controls.Alert;
    import feathers.controls.Label;
    import feathers.controls.ScreenNavigator;
    import feathers.controls.ScreenNavigatorItem;
    import feathers.core.PopUpManager;
    import feathers.data.ListCollection;
    import feathers.themes.MetalWorksDesktopTheme;

    import flash.filesystem.File;

    import main.data.SplitData;
    import main.file.FileBrowseHelper;
    import main.file.FileLoadHelper;
    import main.screen.AboutScreen;
    import main.screen.MainMenuScreen;
    import main.screen.SplitLayoutScreen;
    import main.screen.SplitOverviewScreen;
    import main.screen.SplitSettingsScreen;
    import main.screen.StateEditScreen;

    import starling.display.Sprite;
    import starling.events.Event;

    public class StarlingApplication extends Sprite
    {
        public static const SCREEN_MAIN_MENU:String = "screenMainMenu";
        public static const SCREEN_ABOUT:String = "screenAbout";
        public static const SCREEN_SPLIT_SETTINGS:String = "screenSplitSettings";
        public static const SCREEN_SPLIT_LAYOUT:String = "screenSplitLayout";
        public static const SCREEN_STATE_EDIT:String = "screenStateEdit";
        public static const SCREEN_SPLIT_OVERVIEW:String = "screenSplitOverview";

        private const _splitData:SplitData = new SplitData();
        private const _stateEditProperties:Object = new Object();
        private const _files:Vector.<File> = new Vector.<File>();

        private var _navigator:ScreenNavigator;
        private const _browsingLabel:Label = new Label();

        public function StarlingApplication()
        {
            super();
        }

        public function launch(splitAddress:String = null):void
        {
            var events:Object;

            new MetalWorksDesktopTheme();

            _navigator = new ScreenNavigator();

            events = new Object();
            events[MainMenuScreen.EVENT_SHOW_ABOUT] = SCREEN_ABOUT;
            events[MainMenuScreen.EVENT_SHOW_NEW_SPLIT] = createNewSplit;
            events[MainMenuScreen.EVENT_SHOW_LOAD_SPLIT] = loadSplit;
            _navigator.addScreen(SCREEN_MAIN_MENU, new ScreenNavigatorItem(MainMenuScreen, events));

            events = new Object();
            events[AboutScreen.EVENT_BACK] = SCREEN_MAIN_MENU;
            _navigator.addScreen(SCREEN_ABOUT, new ScreenNavigatorItem(AboutScreen, events));

            events = new Object();
            events[SplitSettingsScreen.EVENT_MAIN_MENU] = SCREEN_MAIN_MENU;
            events[SplitSettingsScreen.EVENT_CONTINUE] = SCREEN_SPLIT_LAYOUT;
            _navigator.addScreen(SCREEN_SPLIT_SETTINGS, new ScreenNavigatorItem(SplitSettingsScreen, events, {
                splitData: _splitData,
                files: _files
            }));

            events = new Object();
            events[SplitLayoutScreen.EVENT_SETTINGS] = SCREEN_SPLIT_SETTINGS;
            events[SplitLayoutScreen.EVENT_CONTINUE] = SCREEN_SPLIT_OVERVIEW;
            events[SplitLayoutScreen.EVENT_EDIT] = SCREEN_STATE_EDIT;
            _navigator.addScreen(SCREEN_SPLIT_LAYOUT, new ScreenNavigatorItem(SplitLayoutScreen, events, {
                splitData: _splitData,
                stateEditProperties: _stateEditProperties
            }));

            _stateEditProperties.splitData = _splitData;
            events = new Object();
            events[StateEditScreen.EVENT_RETURN] = SCREEN_SPLIT_LAYOUT;
            _navigator.addScreen(SCREEN_STATE_EDIT,
                                 new ScreenNavigatorItem(StateEditScreen, events, _stateEditProperties));

            events = new Object();
            events[SplitOverviewScreen.EVENT_LAYOUT] = SCREEN_SPLIT_LAYOUT;
            _navigator.addScreen(SCREEN_SPLIT_OVERVIEW, new ScreenNavigatorItem(SplitOverviewScreen, events, {
                splitData: _splitData,
                files: _files
            }));

            addChild(_navigator);
            _navigator.showScreen(SCREEN_MAIN_MENU);

            splitAddress = "R:\\Dropbox\\split_data.spl";
            if (splitAddress != null)
            {
                _browsingLabel.text = "Loading: " + splitAddress + "...";
                PopUpManager.addPopUp(_browsingLabel);
                var splitFile:File = new File(splitAddress);
                var fileLoadHelper:FileLoadHelper = new FileLoadHelper(splitFile);
                fileLoadHelper.addEventListener(FileLoadHelper.EVENT_COMPLETE, fileLoadHelper_completeHandler);
                fileLoadHelper.addEventListener(FileLoadHelper.EVENT_ERROR, fileLoadHelper_errorHandler);
                fileLoadHelper.load();
            }
        }

        private function fileLoadHelper_completeHandler(event:Event):void
        {
            PopUpManager.removePopUp(_browsingLabel, true);
            var fileLoadHelper:FileLoadHelper = event.target as FileLoadHelper;
            _splitData.initFromJSON(JSON.parse(fileLoadHelper.getContent()));
            _navigator.showScreen(SCREEN_SPLIT_SETTINGS);
        }

        private function fileLoadHelper_errorHandler(event:Event):void
        {
            PopUpManager.removePopUp(_browsingLabel, true);
            Alert.show("Error opening file: ", "Error", new ListCollection([
                                                                               {
                                                                                   label: "OK"
                                                                               }
                                                                           ]));
        }

        private function createNewSplit():void
        {
            _splitData.imagesPath = "";
            _splitData.suffixFilter = ".png";
            _splitData.addStatePrefix = true;
            _splitData.stateDatas.length = 0;
            _navigator.showScreen(SCREEN_SPLIT_SETTINGS);
        }

        private function loadSplit():void
        {
            _browsingLabel.text = "Browsing...";
            PopUpManager.addPopUp(_browsingLabel);
            var fileBrowseHelper:FileBrowseHelper = new FileBrowseHelper();
            fileBrowseHelper.addEventListener(FileBrowseHelper.EVENT_COMPLETE, fileBrowseHelper_completeHandler);
            fileBrowseHelper.addEventListener(FileBrowseHelper.EVENT_ABORT, fileBrowseHelper_abortHandler);
            fileBrowseHelper.browse();
        }

        private function fileBrowseHelper_completeHandler(event:Event):void
        {
            onBrowsingComplete(event);
            var fileBrowseHelper:FileBrowseHelper = event.target as FileBrowseHelper;
            _splitData.initFromJSON(JSON.parse(fileBrowseHelper.getContent()));
            _navigator.showScreen(SCREEN_SPLIT_SETTINGS);
        }

        private function fileBrowseHelper_abortHandler(event:Event):void
        {
            onBrowsingComplete(event);
        }

        private function onBrowsingComplete(event:Event):void
        {
            event.target.removeEventListener(FileBrowseHelper.EVENT_COMPLETE, fileBrowseHelper_completeHandler);
            event.target.removeEventListener(FileBrowseHelper.EVENT_ABORT, fileBrowseHelper_abortHandler);
            PopUpManager.removePopUp(_browsingLabel, true);
        }
    }
}