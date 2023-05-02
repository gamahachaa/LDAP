package php.acl;

/**
 * ...
 * @author bbaudry
 */
class Ressource extends Object implements IRessource
{
	public function toString():String 
	{
		return "[Ressource] " + this.name;
	}
	
}