/**
 * Created by mak on 18.02.15.
 */
package de.creativetechnologist.form {
public interface IValidator {

	function getInvalidMessage(): String;
	function validate(value: *): Boolean;
}
}
