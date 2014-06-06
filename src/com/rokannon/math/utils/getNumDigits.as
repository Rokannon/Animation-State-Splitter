package com.rokannon.math.utils {
	
	
	public function getNumDigits(n:int):int {
		
		if (n == 0) return 1;
		n = getAbs(n);
		var num:int = 0;
		while (n != 0) {
			num++;
			n = int(n / 10);
		}
		return num;
		
	}
	
}