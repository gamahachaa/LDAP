package php.acl;

/**
 * ...
 * @author bbaudry
 */
class Role extends Object implements IRoleInterface
{
	public function getDescription():String
	{
		return "";
	}
	public function toString():String 
	{
		return "[Role] " + this.name;
	}
}