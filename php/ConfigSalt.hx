package php;
import php.types.IConfigSalt;
import php.types.ILdapConfig;
//import php.Attributes;
import ldap.Attributes;

/**
 * ...
 * @author bbaudry
 */
class ConfigSalt implements IConfigSalt
{
	public var disabled_dn(get, null):String;
	public var externalTeamsPath:String;

	public var dn(get, null):String;
	public var server(get, null):String;
	public var port(get, null):Int;
	public var domain(get, null):String;
	public var map_username(get, null):String;
	public var version(get, null):Int;
	public var opt_referrals(get, null):Int;
	@:isVar public var attributes(get, set):Array<Attributes>;
	@:isVar public var attributesSubs(get, set):Array<Attributes>;
	public var serviceUsername(get, null):String;
	public var servicePwd(get, null):String;

	function get_dn():String
	{
		return dn;
	}

	function get_server():String
	{
		return server;
	}

	function get_port():Int
	{
		return port;
	}

	function get_domain():String
	{
		return domain;
	}

	function get_map_username():String
	{
		return map_username;
	}

	function get_attributes():Array<Attributes>
	{
		return attributes;
	}

	function set_attributes(value:Array<Attributes>):Array<Attributes>
	{
		return attributes = value;
	}

	function get_attributesSubs():Array<Attributes>
	{
		return attributesSubs;
	}

	function set_attributesSubs(value:Array<Attributes>):Array<Attributes>
	{
		return attributesSubs = value;
	}

	function get_serviceUsername():String
	{
		return serviceUsername;
	}

	function get_servicePwd():String
	{
		return servicePwd;
	}

	function get_disabled_dn():String
	{
		return disabled_dn;
	}

	function get_version():Int
	{
		return version;
	}

	function get_opt_referrals():Int
	{
		return opt_referrals;
	}

	public function new(?externalTeamsPath:String="")
	{
		this.externalTeamsPath = externalTeamsPath;
		serviceUsername = "ser_quality_mgmt";
		servicePwd = "T0Th3T0p";
		dn = 'OU=Users,OU=Domain-Users,DC=ad,DC=salt,DC=ch';
		disabled_dn = "OU=Domain-Disabled-Objects,DC=ad,DC=salt,DC=ch";
		server = "10.192.114.241";
		port = 389;
		domain = "salt";
		version = 3;
		opt_referrals = 0;
		map_username = Attributes.sAMAccountName;
		attributes = [
						 Attributes.mail,
						 Attributes.sAMAccountName,
						 Attributes.givenName,
						 Attributes.sn,
						 Attributes.mobile,
						 Attributes.company,
						 Attributes.l,
						 Attributes.division,
						 Attributes.department,
						 Attributes.accountExpires,
						 Attributes.msExchUserCulture,
						 Attributes.title,
						 Attributes.initials,
						 Attributes.memberOf,
						 Attributes.manager,
						 Attributes.distinguishedName,
						 Attributes.description,
						 Attributes.thumbnailphoto
					 ];
		attributesSubs = [
							 /*Attributes.manager,*/
							 Attributes.info,
							 Attributes.sAMAccountName,
							 Attributes.mail,
							 Attributes.distinguishedName,
							 Attributes.accountExpires,
							 Attributes.description/*, Attributes.thumbnailPhoto*/];
		//attributes = ["mail", "sAMAccountName", "givenName", "sn", "mobile", "company", "l", "division", "department", "accountExpires", "msExchUserCulture", "title", "initials"];
	}
}