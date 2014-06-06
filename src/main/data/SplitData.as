package main.data {
	
	import com.rokannon.core.utils.requireProperty;
	
	public class SplitData {
		
		private static const PROPERTY_STATES:String = "states";
		private static const PROPERTY_IMAGES_PATH:String = "imagesPath";
		private static const PROPERTY_ADD_STATE_PREFIX:String = "addStatePrefix";
		private static const PROPERTY_SUFFIX_FILTER:String = "suffixFilter";
		
		public const stateDatas:Vector.<StateData> = new Vector.<StateData>();
		
		public var imagesPath:String;
		public var addStatePrefix:Boolean;
		public var suffixFilter:String;
		
		public function SplitData() {
			
		}
		
		public function initFromJSON(data:Object):void {
			
			var stateDataObjects:Array = requireProperty(data, PROPERTY_STATES);
			var length:uint = stateDataObjects.length;
			for (var i:uint = 0; i < length; ++i) {
				var stateData:StateData = new StateData();
				stateData.initFromJSON(stateDataObjects[i]);
				stateDatas.push(stateData);
			}
			imagesPath = requireProperty(data, PROPERTY_IMAGES_PATH);
			addStatePrefix = requireProperty(data, PROPERTY_ADD_STATE_PREFIX);
			suffixFilter = requireProperty(data, PROPERTY_SUFFIX_FILTER);
			
		}
		
		public function toObject(resultObject:Object = null):Object {
			
			if (resultObject == null) resultObject = new Object();
			var stateDataObjects:Array = new Array();
			var length:uint = stateDatas.length;
			for (var i:uint = 0; i < length; ++i) {
				var stateData:StateData = stateDatas[i];
				stateDataObjects.push(stateData.toObject());
			}
			resultObject[PROPERTY_STATES] = stateDataObjects;
			resultObject[PROPERTY_IMAGES_PATH] = imagesPath;
			resultObject[PROPERTY_ADD_STATE_PREFIX] = addStatePrefix;
			resultObject[PROPERTY_SUFFIX_FILTER] = suffixFilter;
			return resultObject;
			
		}
		
	}
	
}