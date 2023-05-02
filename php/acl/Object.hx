package php.acl;

/**
 * ...
 * @author bbaudry
 */
class Object implements IObject
{
	var name:String;

	public function new(name:String) 
	{
		this.name = name;
	}
	
	
	/* INTERFACE php.acl.IObject */
	
	public function getName():String 
	{
		return this.name;
	}
	
}