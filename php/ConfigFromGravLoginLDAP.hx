package php;

import ldap.Attributes;
import php.types.IConfigSalt;
import php.types.ILdapConfig;
import sys.FileSystem;
import yaml.Yaml;

/**
 * ...
 * @author bb
 */
class ConfigFromGravLoginLDAP implements IConfigSalt
{
	public var disabled_dn(get, null):String;
	public var externalTeamsPath:String;
	public var serviceUsername(get, null):String;
	public var servicePwd(get, null):String;
	public var version(get, null):Int;
	public var opt_referrals(get, null):Int;
	@:isVar public var attributes(get, set):Array<Attributes>;
	@:isVar public var attributesSubs(get, set):Array<Attributes>;
	public function new( yamlPath:String, externalTeamsPath:String )
	{
		this.externalTeamsPath = externalTeamsPath;
		if (FileSystem.exists(yamlPath) && FileSystem.exists(this.externalTeamsPath) )
		{
			var conf : Dynamic = Yaml.read( yamlPath );
			
			#if debug
			//Lib.dump( conf );
			#end

			dn = conf.get("search_dn");
			server = conf.get("host");
			domain = Std.string(conf.get("user_dn")).substring(0, Std.string(conf.get("user_dn")).indexOf("\\"));
			port = conf.get("port");
			map_username = conf.get("map_username");
			disabled_dn = conf.get("disabled_dn");
			serviceUsername = conf.get("serviceUsername");
			servicePwd = conf.get("servicePwd");
			version = Std.int(conf.get("version"));
			opt_referrals = (conf.get("opt_referrals") == "true" ||conf.get("opt_referrals") == "1") ? 1:0;
			
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

		}
		else
		{
			throw 'Grav login-ldap config file not found under $yamlPath';
		}
	}

	/* INTERFACE php.types.ILdapConfig */

	public var dn(get, null):String;

	function get_dn():String
	{
		return dn;
	}

	public var server(get, null):String;

	function get_server():String
	{
		return server;
	}

	public var port(get, null):Int;

	function get_port():Int
	{
		return port;
	}

	public var domain(get, null):String;

	function get_domain():String
	{
		return domain;
	}

	public var map_username(get, null):String;

	function get_map_username():String
	{
		return map_username;
	}

	//public var attributes(get, null):Array<String>;

	function get_attributes():Array<String>
	{
		return attributes;
	}
	
	function set_attributes(value:Array<Attributes>):Array<Attributes> 
	{
		return attributes = value;
	}

	//public var attributesSubs(get, null):Array<String>;

	function get_disabled_dn():String
	{
		return disabled_dn;
	}

	function get_serviceUsername():String
	{
		return serviceUsername;
	}

	function get_servicePwd():String
	{
		return servicePwd;
	}

	function get_attributesSubs():Array<String>
	{
		return attributesSubs;
	}
	
	function get_version():Int 
	{
		return version;
	}
	
	function get_opt_referrals():Int 
	{
		return opt_referrals;
	}
	
	function set_attributesSubs(value:Array<Attributes>):Array<Attributes> 
	{
		return attributesSubs = value;
	}

}