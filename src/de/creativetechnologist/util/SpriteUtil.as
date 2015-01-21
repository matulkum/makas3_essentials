package de.creativetechnolgist.util {
import flash.display.Sprite;

/**
	 * @author fatfishfree
	 */
	public class SpriteUtil {
		public static function createRectSprite(w : int, h : int, color : uint = 0, x: int = 0, y:int = 0) : Sprite {
			var r : Sprite = new Sprite();
			r.graphics.beginFill(color);
			r.graphics.drawRect(0, 0, w, h);
			r.x = x;
			r.y = y;
			r.graphics.endFill();
			return r;
		}
	}
}
