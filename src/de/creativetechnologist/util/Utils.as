/**
 * Created by mak on 25.01.15.
 */
package de.creativetechnologist.util {
public class Utils {
	public function Utils() {
	}


	public static function normalizeIndexToLength(index: int, length: int): int {
		var result: int;
		if( index < length && index >= 0)
			result =  index;
		else if( index < 0)
			result = (length-1) + ((index+1) % length);
		else
			result = index % length;

		return result;
	}
}
}
