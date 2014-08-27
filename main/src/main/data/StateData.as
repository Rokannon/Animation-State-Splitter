package main.data
{
    import com.rokannon.core.utils.requireProperty;

    public class StateData
    {
        private static const PROPERTY_NAME:String = "name";
        private static const PROPERTY_START_FRAME:String = "startFrame";
        private static const PROPERTY_END_FRAME:String = "endFrame";

        public var name:String;
        public var startFrame:uint;
        public var endFrame:uint;

        public function StateData()
        {
        }

        public function initFromJSON(data:Object):void
        {
            name = requireProperty(data, PROPERTY_NAME);
            startFrame = requireProperty(data, PROPERTY_START_FRAME);
            endFrame = requireProperty(data, PROPERTY_END_FRAME);
        }

        public function toObject(resultObject:Object = null):Object
        {
            if (resultObject == null)
            {
                resultObject = new Object();
            }
            resultObject[PROPERTY_NAME] = name;
            resultObject[PROPERTY_START_FRAME] = startFrame;
            resultObject[PROPERTY_END_FRAME] = endFrame;
            return resultObject;
        }

        public function copyFrom(stateData:StateData):void
        {
            this.name = stateData.name;
            this.startFrame = stateData.startFrame;
            this.endFrame = stateData.endFrame;
        }
    }
}