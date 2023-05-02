package php.acl;
import php.acl.IObject;
import php.acl.Permission;

/**
 * ...
 * @author bbaudry
 */
class ACL implements IACL
{

	public function new()
	{

	}

	/* INTERFACE php.acl.IACL */

	public function addRole(role:String):Void
	{

	}

	public function addResource(resource:String):Void
	{

	}

	public function addPermission(permission:String):Void
	{

	}

	public function add(object:IObject):Void
	{

	}

	public function allow(role:String, permission:Permission, ressource:Ressourcestatus, Bool):Void
	{

	}

}