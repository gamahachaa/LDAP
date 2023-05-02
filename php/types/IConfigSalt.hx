package php.types;
import ldap.Attributes;

/**
 * @author bb
 */
interface IConfigSalt extends ILdapConfig
{
    public var disabled_dn(get, null):String;
	public var externalTeamsPath:String;
	public var serviceUsername(get, null):String;
	public var servicePwd(get, null):String;
	@:isVar public var attributes(get, set):Array<Attributes>;
	@:isVar public var attributesSubs(get, set):Array<Attributes>;
	/*function get_attributes():Array<Attributes>;
	function set_attributes(value:Array<Attributes>):Array<Attributes>;
	function get_attributesSubs():Array<Attributes>;
	function set_attributesSubs(value:Array<Attributes>):Array<Attributes>;
	function get_serviceUsername():String;
	function get_servicePwd():String;
	function get_disabled_dn():String;*/
}