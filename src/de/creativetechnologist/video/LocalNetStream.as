/**
 * Created by mak on 16.12.14.
 */
package de.creativetechnologist.video {
import flash.events.NetStatusEvent;
import flash.events.StatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

public class LocalNetStream extends NetStream {

	public var loop: Boolean = false;
	private var _nc: NetConnection;

	public var dispatchTime: Number = 0;


	public function get netConnection(): NetConnection {return _nc;}


	public function LocalNetStream(client: Object = null) {
		_nc = new NetConnection();
		_nc.connect(null);
		super(_nc);

		if( !client )
			client = this;
		this.client = client;

		addEventListener(StatusEvent.STATUS, onNetStreamStatus);
		addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
	}

	protected function onNetStatusEvent(event: NetStatusEvent): void {
//	    trace('onNetStatusEvent:', event.type, event.info.code);
		if (event.info.code == "NetStream.Play.Stop")  {
			if( loop ) {
				seek(0);
				play();
			}
		}
	}


	protected function onNetStreamStatus(item: Object): void {
		// trace('onNetStreamStatus', item.info.code);
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
