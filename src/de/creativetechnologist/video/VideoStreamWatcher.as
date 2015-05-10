/**
 * Created by mak on 30/04/15.
 */
package de.creativetechnologist.video {
import flash.display.Stage;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.events.StatusEvent;
import flash.net.NetStream;

import org.osflash.signals.Signal;

public class VideoStreamWatcher {

	public var stream: NetStream;
	private var stage: Stage;

	public var dispatchTime: Number = 0;
	public var signalTime: Signal;


	public function VideoStreamWatcher(netStream: NetStream, stage: Stage) {
		stream = netStream;
		this.stage = stage;
		signalTime = new Signal(VideoStreamWatcher, Number);
		stream.addEventListener(StatusEvent.STATUS, onNetStreamStatus);
		stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
	}

	private function onNetStatusEvent(event: NetStatusEvent): void {
		if (event.info.code == "NetStream.Play.Start" || event.info.code == "NetStream.Play.Resume")  {
			if( dispatchTime > 0 && stream.time < dispatchTime)
				stage.addEventListener(Event.ENTER_FRAME, onEnterFrameForDispatchTime);
		}
		if (event.info.code == "NetStream.Play.Stop")  {
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrameForDispatchTime);
		}
		// TODO pause?
	}

	private function onNetStreamStatus(event: StatusEvent): void {

	}

	private function onEnterFrameForDispatchTime(event: Event): void {
		// is it time to dispatch
		if( dispatchTime <= stream.time) {
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrameForDispatchTime);
		}
	}
}
}
