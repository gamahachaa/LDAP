package php.acl;

/**
 * ...
 * @author bbaudry
 */
class Permission extends Object implements IPermission
{
	public function toString():String 
	{
		return "[Permission] "+this.name;
	}
}