/**
 * Created by mak on 10.05.14.
 */
package de.creativetechnolgist.storage {

import flash.net.SharedObject;

import flash.net.registerClassAlias;
import flash.utils.ByteArray;

public class SharedObjectStorage {

	public var defaultName: String;
	public var localPath: String;


	public function SharedObjectStorage(defaultName: String, localPath: String = null) {
		if( !defaultName || defaultName == '') {
			throw new Error('default name can not be null or empty');
			return;
		}
		this.defaultName = defaultName;
		this.localPath = localPath;

		registerClassAliases();
	}





	/**
	 * override this method to register class aliases
	 * @return
	 */
	protected function registerClassAliases(): void {

	}

	public function write(object: *, key: String, name: String = null) {
		var ba: ByteArray = new ByteArray();
		ba.writeObject(object);

		var sharedObject:SharedObject = getSharedObject(name);
		sharedObject.data[key] = ba;
		sharedObject.flush();

	}


	public function read(key: String, name: String = null): * {

		var sharedObject:SharedObject = getSharedObject(name);
		var bytes: ByteArray = sharedObject.data[key];

		if( !bytes )
			return null;

		return bytes.readObject();
	}


	public function clear(name: String = null): void {
		var sharedObject:SharedObject = getSharedObject(name);
		sharedObject.clear();
		sharedObject.flush();
	}


	[Inline]
	private final function getSharedObject(name: String = null): SharedObject {
		if( !name )
			name = defaultName;

		return SharedObject.getLocal(name, localPath);
	}

}
}
