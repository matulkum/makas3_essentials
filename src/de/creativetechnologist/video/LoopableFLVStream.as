/**
 * Created by mak on 17/03/15.
 */
package de.creativetechnologist.video {
import flash.display.Stage;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.net.NetStreamAppendBytesAction;
import flash.utils.ByteArray;

import org.osflash.signals.Signal;

public class LoopableFLVStream extends LocalNetStream {
	private var flashStage: Stage;
	private var bytes: ByteArray;

	private var buffer: ByteArray;


	private var headerBytes: ByteArray;
	private var headerLength: int;
	private var contentBytes: ByteArray;
	private var metaData: Object;

	private var isPlaying: Boolean;
	private var isPausing: Boolean;


	private var _currentVideoStartTime: Number = -1;

	public var signalComplete: Signal;
	public var signalVideoStarted: Signal;

	private var _dispatchAtTime: Number = -1;
	private var _signalTimeDispatch: Signal;


	private var BUFFER_BYTES_LENGTH: int = 262144;
//	private var BUFFER_BYTES_LENGTH: int = 65536;



	public function get currentVideoStartTime(): Number { return _currentVideoStartTime;}
	public function get currentVideoTime(): Number { return time - _currentVideoStartTime;}


	public function LoopableFLVStream(flashStage: Stage, bytes: ByteArray = null) {
		super(this);
		bufferTime = 0;
		inBufferSeek = true;
		this.flashStage = flashStage;

		signalComplete = new Signal();
		signalVideoStarted = new Signal();

		if( bytes )
			parseBytes(bytes);
	}


	private function parseBytes(bytes: ByteArray): void {
		this.bytes = bytes;

		headerBytes = new ByteArray();
		bytes.position = 0;
		bytes.readBytes(headerBytes, 0, 9);

		headerBytes.position = headerBytes.length-1;
		headerLength = headerBytes.readByte();

		bytes.position = 0;
		headerBytes.position = 0;
		bytes.readBytes(headerBytes, 0, headerLength + 4);

		contentBytes = new ByteArray();
		bytes.readBytes(contentBytes, 0, 0);
	}

//	public function setBytes(bytes: ByteArray): void {
//		this.bytes = bytes;
//		seek(0);
//	}


	public function reset(): void {
		isPlaying = false;
		close();
		bytes = null;
		_currentVideoStartTime = -1;
		metaData = null;
		flashStage.removeEventListener(Event.ENTER_FRAME, onEnterFrameForBuffer);
	}


	override public function close(): void {
		isPlaying = false;
		isPausing = false;
		removeEventListener(NetStatusEvent.NET_STATUS, onSeekForNewBytesNetStatus);
		flashStage.removeEventListener(Event.ENTER_FRAME, onEnterFrameForBuffer);
		super.close();
	}



	override public function play(...args): void {
		trace( 'LoopableFLVStream -> play: ' );
		if( args && args.length > 0 ) {
			if( args[0] is ByteArray)
				parseBytes(args[0]);
		}

		if( bytes ) {
			if( !buffer )
				buffer = new ByteArray();

			if( !isPausing) {
				if( !isPlaying) {
					super.play(null);
					headerBytes.position = 0;
					contentBytes.position = 0;
//
					buffer.clear();
					contentBytes.readBytes(buffer, 0, BUFFER_BYTES_LENGTH);
					buffer.position = 0;

					appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
					appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
					appendBytes(headerBytes);
					appendBytes(buffer);
				}
				else {
					addEventListener(NetStatusEvent.NET_STATUS, onSeekForNewBytesNetStatus);
					seek(0);
				}


			}
			else if( isPausing ) {
				resume();
			}
		}
		isPlaying = true;
		isPausing = false;
	}


	override public function resume(): void {
		trace( 'LoopableFLVStream -> resume: ' );
		isPausing = false;
		if( metaData )
			flashStage.addEventListener(Event.ENTER_FRAME, onEnterFrameForBuffer);
		super.resume();
	}

	override public function pause(): void {
		isPausing = true;
		if( isPlaying ) {
			flashStage.removeEventListener(Event.ENTER_FRAME, onEnterFrameForBuffer);
			super.pause();
		}
	}


	public function setDispatchAtTime(time: Number): Signal {
		if( !_signalTimeDispatch ) {
			_signalTimeDispatch = new Signal();
		}
		_dispatchAtTime = time;
		return _signalTimeDispatch;
	}


	override protected function onNetStatusEvent(event: NetStatusEvent): void {
		trace('onNetStatusEvent:', event.type, event.info.code);
	}


	override protected function onNetStreamStatus(item: Object): void {
		trace('onNetStreamStatus', item.info.code);
	}


	override public function onXMPData(infoObject: Object): void {
		trace("LocalNetStream->onXMPData() :: ", infoObject);
	}



	override public function onMetaData(metadata: Object): void {
		trace('onMetaData', time, metadata.duration);
		this.metaData = metadata;
		_currentVideoStartTime = time;
		signalVideoStarted.dispatch(this);
		flashStage.addEventListener(Event.ENTER_FRAME, onEnterFrameForBuffer);

		removeEventListener(NetStatusEvent.NET_STATUS, onSeekForNewBytesNetStatus);
	}


	private function onEnterFrameForBuffer(event: Event): void {
//        trace( 'LoopableFLVStream -> onEnterFrameForBuffer: ', time, bufferLength );

		if( _dispatchAtTime > -1) {
			if( _dispatchAtTime < time ) {
				_signalTimeDispatch.dispatch(this);
				_dispatchAtTime = -1;
			}
		}

//		trace('bytes: ', info.videoBufferByteLength, contentBytes.bytesAvailable);



		var bytesAvailable: uint = contentBytes.bytesAvailable;
		if (info.videoBufferByteLength < BUFFER_BYTES_LENGTH && bytesAvailable > 0) {
//			trace('buffer');
//			buffer.clear();
			if( bytesAvailable < BUFFER_BYTES_LENGTH) {
				contentBytes.readBytes(buffer, 0, bytesAvailable);
				if( loop ) {
//					trace('loop');
					headerBytes.position = 0;
					contentBytes.position = 0;
					buffer.clear();
					buffer.position = 0;
					contentBytes.readBytes(buffer, 0, BUFFER_BYTES_LENGTH);
					appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
					appendBytes(headerBytes);
					appendBytes(buffer);
//					flashStage.addEventListener(Event.ENTER_FRAME, onEnterFrameForBuffer);
				}
				else {
					appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
					flashStage.removeEventListener(Event.ENTER_FRAME, onEnterFrameForBuffer);
				}
			}
			else {
				contentBytes.readBytes(buffer, 0, BUFFER_BYTES_LENGTH);
				appendBytes(buffer);
			}
			return;
		}
	}



	private function onSeekForNewBytesNetStatus(event: NetStatusEvent): void {
		trace( 'LoopableFLVStream -> onSeekForNewBytesNetStatus: ' );
		if( event.info.code == 'NetStream.SeekStart.Notify') {
			removeEventListener(NetStatusEvent.NET_STATUS, onSeekForNewBytesNetStatus);
			if( bytes ) {
				headerBytes.position = 0;
				contentBytes.position = 0;

				buffer.clear();
				buffer.position = 0;
				contentBytes.readBytes(buffer, 0, BUFFER_BYTES_LENGTH);
				appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
				appendBytes(headerBytes);
				appendBytes(buffer);
			}
		}
	}

}
}
