/**
 * Created by mak on 18.02.15.
 */
package de.creativetechnologist.form {
import de.creativetechnologist.feathers.form.*;

public class MinLengthValidator implements IValidator{

	private var minLength: int;
	private var invalidMessage: String;

	public function MinLengthValidator( minLength: int = 1, invalidMessage: String = 'Text must be at least ${minLength} long') {
		this.minLength = minLength;
		this.invalidMessage = invalidMessage;
	}


	public function getInvalidMessage(): String {
		return invalidMessage.replace('${minLength}', minLength.toString());
	}


	public function validate(value: *): Boolean {
		var string: String = value as String;
		if( string === null )
			return false;
		if( minLength < -1 )
			return true;

		return string.length >= minLength;
	}
}
}
