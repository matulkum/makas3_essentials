/**
 * Created by mak on 12.06.14.
 */
package de.creativetechnologist.log {
import org.osflash.signals.Signal;

public class Logger {

	public var stack: Vector.<LogMessage>;

	public static const ERROR: int = 0;
	public static const WARNING: int = 1;
	public static const INFO: int = 2;
	public static const DEBUG: int = 3;

	public const STACK_SIZE: int = 50;

	public var traceLevel: int = -1;

	// (message: String, level: int)
	private var _signal: Signal;



	public function Logger() {
	}

	public function enableStack(): void {
	    stack = new <LogMessage>[];
	}

	// (message: String, level: int)
	public function get signal(): Signal {
		if( !_signal )
			_signal = new Signal();
		return _signal;
	}



	public function msg(level: int, ...arguments): void {
		var string: String = '';
		var i: int = 0;
		var length: int = arguments.length;

		for( i; i < length; i++) {
			string += arguments.toString();
			if( i < length-1 )
				string += ', ';
		}

		var messageString: String = '['+level+']' + ':: '+ string;
		if( stack ) {
			var logMessage: LogMessage = LogMessage.get(messageString, level);
			stack.push(logMessage);
			if( stack.length > STACK_SIZE )
				stack.shift();
		}
		if( level <= traceLevel )
			trace(messageString);

		if( _signal )
			_signal.dispatch(messageString, level);
	}


	public function error(...arguments): void {
		msg(ERROR, arguments);
	}

	public function warn(...arguments): void {
		msg(WARNING, arguments);
	}

	public function info(...arguments): void {
		msg(INFO, arguments);
	}

	public function debug(...arguments): void {
		msg(DEBUG, arguments);
	}
}
}
