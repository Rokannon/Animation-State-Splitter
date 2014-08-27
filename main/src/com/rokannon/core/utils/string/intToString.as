package com.rokannon.core.utils.string {
	
	import com.rokannon.math.utils.getNumDigits;
	
	public function intToString(n:int, minDigits:int = 1):String {
		
		var result:String = "";
		var numDigits:int = getNumDigits(n);
		for (var i:int = 0; i < minDigits - numDigits; i++) {
			result += "0";
		}
		result += n.toString();
		return result;
		
	}
	
}