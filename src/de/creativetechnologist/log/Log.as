/**
 * Created by mak on 12.06.14.
 */
package de.creativetechnologist.log {
import org.osflash.signals.Signal;

public class Log {

	public static var stack: Vector.<String>;

	public static const ERROR: int = 0;
	public static const WARNING: int = 1;
	public static const INFO: int = 2;
	public static const DEBUG: int = 3;

	public static const STACK_SIZE: int = 75;

	public static var traceLevel: int = -1;
	private static var _signal: Signal;

	public function Log() {
	}

	public static function enableStack(): void {
	    stack = new <String>[];
	}

	public static function get signal(): Signal {
		if( !_signal )
			_signal = new Signal();
		return _signal;
	}



	public static function msg(level: int, ...arguments): void {
		var string: String = '';
		var i: int = 0;
		var length: int = arguments.length;

		for( i; i < length; i++) {
			string += arguments.toString();
			if( i < length-1 )
				string += ', ';
		}

		var message: String = '['+level+']' + ':: '+ string;
		if( stack ) {
			stack.push(message);
			if( stack.length > STACK_SIZE )
				stack.shift();
		}
		if( level <= traceLevel )
			trace(message);

		if( signal )
			signal.dispatch(message, level);
	}


	public static function error(...arguments): void {
		msg(ERROR, arguments);
	}

	public static function warn(...arguments): void {
		msg(WARNING, arguments);
	}

	public static function info(...arguments): void {
		msg(INFO, arguments);
	}

	public static function debug(...arguments): void {
		msg(DEBUG, arguments);
	}


	public static function stackToString(): String {
		var string: String = '';
		if( !stack )
			return string;

		var i: int;
		var stackLength: int = stack.length;
		for (i = 0; i < stackLength; i++) {
			string += stack[i];
			if( i < stackLength-1 )
				string += '\n';
		}
		return string;
	}
}
}
