/**
 * Created by mak on 29/04/15.
 */
package de.creativetechnologist.util {
public class Conversion {
	public function Conversion() {
	}

	public static function numberToGermanPrice(number: Number): String {
		var array: Array = number.toString().split('.');
		if( array.length == 1)
			return array[0] as String;


		var end: String = String(array[1]);
		var endLength: int = end.length;
		if ( endLength < 2)
			end += '0';
		else if( endLength > 2)
			end = end.substr(0,2);

		return array[0] + ',' + end;

	}
}
}
