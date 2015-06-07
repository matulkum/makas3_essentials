/**
 * Created by mak on 18.02.15.
 */
package de.creativetechnologist.form {
import de.creativetechnologist.feathers.form.*;

public class EmailValidator implements IValidator{

	private var isRequired: Boolean;
	private var invalidMessage: String;

	public function EmailValidator(required: Boolean = true, invalidMessage: String = 'Not a valid E-Mail address') {
		this.isRequired = required;
		this.invalidMessage = invalidMessage;
	}


	public function getInvalidMessage(): String {
		return invalidMessage;
	}


	public function validate(value: *): Boolean {
		var string: String = value as String;
		if( string === null)
			return false;
		if( string == '' && !isRequired )
			return true;

		return /^[\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i.test(string);
	}
}
}
