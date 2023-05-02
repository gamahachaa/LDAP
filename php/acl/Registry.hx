package php.acl;
import php.acl.IObject;

/**
 * ...
 * @author bbaudry
 */
class Registry implements IRegistry
{
	var registry:Array<String>;

	public function new() 
	{
		registry = [];
	}
	
	
	/* INTERFACE php.acl.IRegistry */
	
	public function save(object:String,  ?options:Array<String>):Void 
	{
		if (registry.indexOf(object) == -1)
		{
			registry.push(object);
		}
	}
	
	public function remove(object:String):Void 
	{
		var i = registry.indexOf(object);
		if ( i > -1 )
		{
			registry.splice(i, 1);
		}
	}
	
	public function exists(object:String):Bool 
	{
		return registry.length > 0 && registry.indexOf(object) >-1;
	}
	
	public function get(object:String):String 
	{
		if (exists(object))
		{
			return registry[registry.indexOf(object)];
		}
		else
			throw 'Error $object is not set in the registry' ;
	}
	
	public function getRegistry():Array<String> 
	{
		return registry;
	}
	
	public function setRegistryValue(registryIndex:String, registryValue:String):Void 
	{
		
	}
	
}