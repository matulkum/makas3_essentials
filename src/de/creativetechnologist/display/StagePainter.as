/**
 * Created by mak on 18.06.14.
 */
package de.creativetechnologist.display {
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.ui.Keyboard;

public class StagePainter {

	public static var stage: Stage;
	private static var canvas: Shape;

	public function StagePainter() {
	}

	public static function init(stage: Stage): void {
		StagePainter.stage = stage;
		if( canvas )
			stage.removeChild(canvas);

		canvas = new Shape();
		stage.addChild(canvas);
	}


	public static function rectBorder(rectangle: Rectangle, color:uint = 0xff00ff): void {
		if( !canvas ) {
			trace("StagePainter.rectBorder() FAILED: call init() first!!");
			return;
		}
		canvas.graphics.lineStyle(1, color);
		canvas.graphics.drawRect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
		stage.setChildIndex(canvas, stage.numChildren-1);
	}


	public static function clear(): void {
		if( canvas )
			canvas.graphics.clear();
	}


	public static function enablePasteBitmapFromClipboard(stage: Stage): void {
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventForPasteBitmap);
	}



	private static var pastedBitmap: Bitmap;
	private static function onKeyEventForPasteBitmap(event: KeyboardEvent): void {
		var stage: Stage = event.target as Stage;

		if( event.keyCode == Keyboard.V ) {
			if( Clipboard.generalClipboard.hasFormat(ClipboardFormats.BITMAP_FORMAT) ) {
				if( !pastedBitmap ) {
					pastedBitmap = new Bitmap();
					pastedBitmap.alpha = .5;
					stage.addChild(pastedBitmap);
				}
				else {
					pastedBitmap.parent.setChildIndex(pastedBitmap, pastedBitmap.parent.numChildren-1);
				}
				pastedBitmap.bitmapData = Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT) as BitmapData;
				pastedBitmap.width = stage.stageWidth;
				pastedBitmap.height = stage.stageHeight;
			}
			return;
		}

		if( pastedBitmap ) {
			if( event.keyCode == Keyboard.X ) {
				pastedBitmap.parent.removeChild(pastedBitmap);
				pastedBitmap.bitmapData.dispose();
				pastedBitmap = null;
			}
			if( event.keyCode == Keyboard.LEFT ){
				pastedBitmap.x -= 1;
				trace('x:', pastedBitmap.x, '| y:', pastedBitmap.y )
			}
			if( event.keyCode == Keyboard.RIGHT ){
				pastedBitmap.x += 1;
				trace('x:', pastedBitmap.x, '| y:', pastedBitmap.y )
			}
			if( event.keyCode == Keyboard.UP ){
				pastedBitmap.y -= 1;
				trace('x:', pastedBitmap.x, '| y:', pastedBitmap.y )
			}
			if( event.keyCode == Keyboard.DOWN ){
				pastedBitmap.y += 1;
				trace('x:', pastedBitmap.x, '| y:', pastedBitmap.y )
			}
		}

	}
}
}
