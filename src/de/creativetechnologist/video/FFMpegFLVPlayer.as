/**
 * Created by mak on 27/05/15.
 */
package de.creativetechnologist.video {
import com.furusystems.dconsole2.plugins.BytearrayHexdumpUtil;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.NetStatusEvent;
import flash.events.ProgressEvent;
import flash.events.StatusEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.NetStreamAppendBytesAction;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import org.osflash.signals.Signal;

public class FFMpegFLVPlayer{

	private var ffmpeg: File;
	private var netConnection: NetConnection;

	private var _stream: NetStream;
	public function get stream(): NetStream {return _stream;}

	private var nativeProcessParams: NativeProcessStartupInfo;
	private var nativeProcess: NativeProcess;

	private var idleTimer: Timer;

	private var path: String;
	private var retryTimeoutDelay: Number = 4000;
	private var retryTimeoutID: uint;

	private var _streaming: Boolean;
	public function get streaming(): Boolean {return _streaming;}

	public var signalStreamStarted: Signal = new Signal(FFMpegFLVPlayer);
	public var signalStreamStopped: Signal = new Signal(FFMpegFLVPlayer);


	public function FFMpegFLVPlayer(ffmpegFile: File){
		ffmpeg = ffmpegFile;
		netConnection = new NetConnection();
		netConnection.connect(null);
		_stream = new NetStream(netConnection);
		_stream.bufferTime = 0.001;
		_stream.backBufferTime = 0.001;
		_stream.bufferTimeMax = 0.001;
		_stream.client = this;
		_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
		_stream.addEventListener(StatusEvent.STATUS, onNetStreamStatus);

		nativeProcessParams = new NativeProcessStartupInfo();
		nativeProcessParams.executable = ffmpeg;

		idleTimer = new Timer(4000, 1);
	}

	public function play(path: String): void {
		trace( 'FFMpegFLVPlayer -> play: ', path );

		if( this.path == path && streaming )
			return;
		stop();
		this.path = path;

		nativeProcessParams.arguments = new <String>['-loglevel', 'quiet', '-i', path, '-c', 'copy', '-f', 'flv', '-'];

		nativeProcess = new NativeProcess();
		nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessOutputData);
		nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessErrorData);
		nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
		nativeProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
		nativeProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);

		_stream.play(null);
		_stream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
		nativeProcess.start(nativeProcessParams);

		idleTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onIdleTimer);
		idleTimer.reset();
		idleTimer.start();
	}


	public function stop(): void {

		idleTimer.stop();
		idleTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onIdleTimer);
		clearTimeout(retryTimeoutID);

		path = null;
		disposeNativeProcess();

		try {
//			_stream.close();
		} catch(e: Error){ /* doesn't matter */}

	}


	public function disposeNativeProcess(forceExit: Boolean = false): void {
		if( nativeProcess ) {
			nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessOutputData);
			nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessErrorData);
			nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
			nativeProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
			nativeProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);

			try {
				nativeProcess.closeInput();
				nativeProcess.exit(forceExit);
			} catch(e: Error){ /* doesn't matter */}

			nativeProcess = null;
		}
	}


	private function onIdleTimer(event: TimerEvent): void {
		var replayPath: String = path;
		disposeNativeProcess(true);
		stop();
		if( replayPath ) {
			retryTimeoutID = setTimeout(function():void{
				play(replayPath);
			}, retryTimeoutDelay);
		}
	}



	//////////////////////////////
	// NativeProcess handlers
	//////////////////////////////

	var counter: int = 0;
	private var headerBytes: ByteArray;

	private function onNativeProcessOutputData(event: ProgressEvent): void {
//		trace( 'FFMpegFLVPlayer -> onNativeProcessOutputData: ' );

		if( !_streaming ) {
			_streaming = true;
			signalStreamStarted.dispatch(this);
		}
		idleTimer.reset();
		idleTimer.start();

		var buffer: ByteArray = new ByteArray();

		nativeProcess.standardOutput.readBytes(buffer, 0, nativeProcess.standardOutput.bytesAvailable);
//		trace( 'FFMpegFLVPlayer -> onNativeProcessOutputData: ', buffer.length );

		if( _stream.info.videoBufferLength > .08 ) {
//			trace(_stream.info.videoBufferLength, 'seeking!');
			_stream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
//			counter++;
		}
		_stream.appendBytes(buffer);

		return;

		/*
		if( !headerBytes ) {
			headerBytes = new ByteArray();

			buffer.position = 0;
			buffer.readBytes(headerBytes, 0, 13);

			_stream.appendBytes(headerBytes);

			// find last flv tag bytearray index
			var position: int;
			position = buffer.position - 4;


			var bodySize: uint;
			while ( true ) {
				// + 4 for previous tagSize, + 1 for TagType
				bodySize = buffer[position + 4 + 1] << 16 | buffer[position + 4 + 2] << 8 | buffer[position + 4 + 3];

				buffer.position = position;
				trace(buffer.readUnsignedInt(), position, bodySize);

				if( position + bodySize + 15 >= buffer.length)
					break;
				position += bodySize + 15;

			}
			var lastTagBytes: ByteArray =  new ByteArray();
			buffer.position = position + 4;
			lastTagBytes.writeBytes(buffer, position + 4);
			lastTagBytes.position = 0;
			_stream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
			_stream.appendBytes(lastTagBytes);
		}
		else {
			trace('appending', buffer.length);
			_stream.appendBytes(buffer);
		}
		*/
	}


	private function onNativeProcessExit(event: NativeProcessExitEvent): void {
		trace( 'FFMpegFLVPlayer -> onNativeProcessExit: ' );

		var replayPath: String = path;
		stop();
		if( replayPath ) {
			retryTimeoutID = setTimeout(function():void{
				play(replayPath);
			}, retryTimeoutDelay);

		}
		signalStreamStopped.dispatch(this);
		_streaming = false;
	}

	private function onNativeProcessErrorData(event: ProgressEvent): void {
		trace( 'FFMpegFLVPlayer -> onNativeProcessErrorData: ' );
		trace(nativeProcess.standardError.readUTFBytes(nativeProcess.standardError.bytesAvailable));
		stop();
	}

	private function onNativeProcessIOError(event: IOErrorEvent): void {
		trace( 'FFMpegFLVPlayer -> onNativeProcessIOError: ' );
		stop();
	}





	//////////////////////////////
	// Stream handlers
	//////////////////////////////

	protected function onNetStatusEvent(event: NetStatusEvent): void {
	    trace( 'FFMpegFLVPlayer -> onNetStatusEvent: ', event.type, event.info.code );
//		if( event.info.code == 'NetStream.Buffer.Full')
//			_stream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
	}

	protected function onNetStreamStatus(item: Object): void {
		trace( 'FFMpegFLVPlayer -> onNetStreamStatus: ', item.info.code );
	}


	public function onXMPData(infoObject:Object):void {
		// trace("LocalNetStream->onXMPData() :: ", infoObject );
	}


	public function onMetaData(metadata:Object): void {
		// trace('onMetaData', metadata);
	}


	public function onPlayStatus(...args): void {
		trace( 'LocalNetStream -> onPlayStatus: ' );
	}


}
}
