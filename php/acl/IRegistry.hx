package php.acl;

/**
 * @author bbaudry
 */
interface IRegistry 
{
	/**
	 * @todo type for options
	 * @param	object
	 * @param	options
	 */
	public function save(object:String, ?options:Array<String>):Void;
	public function remove(object:String):Void;
	public function exists(object:String) : Bool;
	public function get(object:String):String;
	public function getRegistry():Array<String>;
	public function setRegistryValue(registryIndex:String, registryValue:String):Void;
}