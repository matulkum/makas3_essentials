/**
 * Created by mak on 12.06.14.
 */
package de.creativetechnologist.log {
import org.osflash.signals.Signal;

public class Log {

	public static var logger: Logger;

	public static const ERROR: int = 0;
	public static const WARNING: int = 1;
	public static const INFO: int = 2;
	public static const DEBUG: int = 3;


	public function Log() {
	}

	public static function init(logger: Logger): void {
		Log.logger = logger;
	}


	// (message: String, level: int)
	public static function get signal(): Signal {
		return logger.signal;
	}



	public static function msg(level: int, ...arguments): void {
		logger.msg(level, arguments);
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

}
}
