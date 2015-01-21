/**
 * Created by mak on 25.08.14.
 */
package de.creativetechnologist.util {
import flash.geom.Point;

public class Geom {
	public function Geom() {
	}

	public static function distanceBetween(point1: Point, point2: Point): Number{
		return Math.sqrt(Math.pow(point2.x - point1.x, 2) + Math.pow(point2.y - point1.y, 2))
	}
}
}
