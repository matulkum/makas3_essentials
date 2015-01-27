/**
 * Created by mak on 25.01.15.
 */
package de.creativetechnologist.util {
public class Utils {
	public function Utils() {
	}


	public static function normalizeIndexToLength(index: int, length: int): int {
		if( index < length && index >= 0)
			return index;
		if( index < 0)
			return (length-1) + ((index+1) % length);

		return index % length;
	}
}
}
