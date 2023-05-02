package php.acl;

/**
 * @author bbaudry
 */
interface IACL 
{
	public function addRole(role:String):Void;
	public function addResource(resource:String):Void;
	public function addPermission(permission:String):Void;
	public function add(object:IObject):Void;
	public function allow(role:Strin, permission:Permission, ressource:Ressourcestatus:Bool):Void
}