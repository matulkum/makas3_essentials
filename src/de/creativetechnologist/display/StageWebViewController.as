/**
 * Created by mak on 11.04.15.
 */
package de.creativetechnologist.display {
import bb.signals.BBSignal;

import flash.display.Stage;
import flash.events.LocationChangeEvent;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.media.StageWebView;

public class StageWebViewController {

	private var stage: Stage;
	private var useNative: Boolean;

	private var _swv: StageWebView;
	private var viewport: Rectangle;

	private var _signalReceivedJSON: BBSignal;




	public function get signalReceivedJSON(): BBSignal {return _signalReceivedJSON;}



	public function get swv(): StageWebView {return _swv;}


	public function StageWebViewController(stage: Stage, useNative: Boolean = false) {
		this.stage = stage;
		this.useNative = useNative;

		_swv = new StageWebView(useNative);
		_swv.stage = stage;
	}


	public function show(dimensions: Rectangle = null): void {
		if( dimensions ) {
			viewport = dimensions.clone();
		}
		if( !viewport )
			viewport = new Rectangle(0,0, stage.stageWidth, stage.stageHeight);
		applyViewport();
	}


	public function disposeWebView(): void {
		if ( _swv) {
			_swv.dispose();
			_swv.removeEventListener(LocationChangeEvent.LOCATION_CHANGING, onListenForJSONLocationChange);
		}
	}


	public function get width(): Number {
		return viewport.width;
	}

	public function set width(value: Number): void {
		viewport.width = value;
	}

	public function get height(): Number {
		return viewport.height;
	}

	public function set height(value: Number): void {
		viewport.height = value;
	}

	public function get x(): Number {
		return viewport.x;
	}

	public function set x(value: Number): void {
		viewport.x = value;
	}

	public function get y(): Number {
		return viewport.y;
	}

	public function set y(value: Number): void {
		viewport.y = value;
 	}


	public function applyViewport(): void {
		_swv.viewPort = viewport;
	}




	public function loadURL(url: String): void {
		_swv.loadURL(url);
	}


	public function loadString(string: String, mimeType: String = 'text/html'): void {
		_swv.loadString(string, mimeType)
	}


	public function loadAppPackageFile(filename: String): void {
		trace('app:' + new File(new File(filename).nativePath).url);
		loadURL( new File(new File('app:' + filename).nativePath).url);
	}


	public function callJSFunction(functionName: String, ...params): void {
		var command: String = 'javascript:'+functionName+'(';
		var i: int;
		var length: int = params.length;
		for (i = 0; i < length; i++) {
			if( params[i] is Object)
				command += '"' + params[i].toString() + '"';
			else if ( params[i] is String )
				command += '"' + params[i] + '"';
			else
				command += params[i];

			if( i < length-1 )
				command += ', ';
		}
		command += ')';
		loadURL(command);
	}


	public function listenForJSON(): BBSignal {
		_swv.addEventListener(LocationChangeEvent.LOCATION_CHANGING, onListenForJSONLocationChange);
		if( !_signalReceivedJSON)
			_signalReceivedJSON = BBSignal.get(this);
		return _signalReceivedJSON;
	}


	private function onListenForJSONLocationChange(event: LocationChangeEvent): void {
		if( event.location.substr(0,1) == '{') {
			event.preventDefault();
			var object: Object;
			try {
				object = JSON.parse(unescape(event.location));
			}
			catch(e: Error) {
				trace("StageWebViewController->onListenForJSONLocationChange() :: ERROR parsing JSON!" );
			}
		}
	}



}
}
