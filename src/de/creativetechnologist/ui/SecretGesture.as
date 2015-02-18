/**
 * Created by mak on 29.08.14.
 */
package de.creativetechnologist.ui {


import de.creativetechnologist.log.Log;

import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.utils.Timer;

import org.osflash.signals.Signal;

public class SecretGesture {

	private var stage: Stage;
	private var locations: Array;
	private var hitAreas: Vector.<Rectangle>;
	private var currentPhase: int = 0;
	private var hitAreasLength: uint;

	private var timer: Timer;

	public var signalActivate: Signal;


	/**
	 *
	 * @param stage "Classic flash" stage
	 * @param args Strings with touch locations (eg "ne" for north east or "" for center)
	 */
	public function SecretGesture(stage: Stage, ...args) {
		if( args.length == 0) {
			throw new Error('u have to declare at least one location!');
			return;
		}

		this.stage = stage;
		this.locations = args;

		createHitAreas();

		timer = new Timer(2000, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		signalActivate = new Signal();
		stage.addEventListener(MouseEvent.CLICK, onStageClick);
		stage.addEventListener(Event.RESIZE, onStageResize);
	}


	public function reset(): void {
		currentPhase = 0;
		timer.stop();
		timer.reset();
	}


	private function createHitAreas(): void {
		hitAreas = new <Rectangle>[];
		var i: int;
		var length: int = locations.length;
		for (i = 0; i < length; i++) {
			hitAreas.push(createRect(this.stage, locations[i]));
		}
		hitAreasLength = hitAreas.length;
	}


	private static function createRect(stage: Stage, location: String): Rectangle {
		var width: int = stage.fullScreenWidth / 5;
		var height: int = stage.fullScreenHeight / 5;
		var rect: Rectangle = new Rectangle(
				(stage.fullScreenWidth - width) >> 1,
				(stage.fullScreenHeight - height) >> 1,
				stage.fullScreenWidth / 5,
				stage.fullScreenHeight / 5);

		if( location.indexOf('n') > -1)
			rect.y = 0;
		else if( location.indexOf('s') > -1)
			rect.y = stage.fullScreenHeight - height;

		if( location.indexOf('w') > -1)
			rect.x = 0;
		else if( location.indexOf('e') > -1)
			rect.x = stage.fullScreenWidth - width;

		return rect;
	}


	private function onStageClick(event: MouseEvent): void {
		if( currentPhase >= hitAreasLength) {
			reset();
			return;
		}

		if( hitAreas[currentPhase].contains(event.localX, event.localY) ) {
			if( currentPhase == 0 )
				timer.start();
			currentPhase++;
			if( currentPhase == hitAreas.length ) {
				currentPhase = 0;
				Log.debug('SecretGesture activate');
				signalActivate.dispatch(this);
				reset();
			}
		}
		else {
			reset();
		}
	}


	private function onStageResize(event: Event): void {
		createHitAreas();
	}


	private function onTimerComplete(event: TimerEvent): void {
		reset();
	}
}
}
