/**
 * Created by mak on 21.02.15.
 */
package de.creativetechnologist.log {
public class LogMessage {

	public var message: String;
	public var level: uint;

	private static var POOL: Vector.<LogMessage>;

	public function LogMessage(enforcer: Enforcer) {
		if( !enforcer )
			throw new Error('use get() instead!');
	}

	public static function get(message: String, level: uint): LogMessage {
		if( POOL && POOL.length > 0)
			return POOL.pop().set(message, level);

		return new LogMessage(new Enforcer()).set(message, level);
	}


	public function set(message: String, level: uint): LogMessage {
		this.message = message;
		this.level = level;
		return this;
	}

	public function dispose(logMessage: LogMessage): void {
		if( !POOL )
			POOL = new <LogMessage>[];
		POOL.push(logMessage);
	}
}

}
class Enforcer {
	public function Enforcer(){}
}
