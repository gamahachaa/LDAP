package php;
//import lrs.Actor;
import xapi.Agent;

/**
 * ...
 * @author bb
 */
class SaltLdapActor extends Agent
{
	@:isVar public var boss(get, set):SaltLdapActor;
	@:isVar public var directReports(get, set):Array<SaltLdapActor>;
	@:isVar public var peers(get, set):Array<SaltLdapActor>;
	// pure LDAP
	@:isVar public var manager(get, set):String;
	@:isVar public var authorised(get, set):Bool;
	//var adminFile:Csv;

	//public var sAMAccountName(get, null):String;
	@:isVar public var givenname(get, set):String;
	@:isVar public var sn(get, set):String;
	@:isVar public var mobile(get, set):String;
	@:isVar public var company(get, set):String;
	@:isVar public var l(get, set):String;
	@:isVar public var division(get, set):String;
	@:isVar public var department(get, set):String;
	@:isVar public var description(get, set):String;
	
	@:isVar public var distinguishedname(get, set):String;
	@:isVar public var msexchuserculture(get, set):String;
	@:isVar public var accountexpires(get, set):String; //@todo Date

	@:isVar public var title(get, set):String;
	@:isVar public var initials(get, set):String;
	@:isVar public var memberof(get, set):Array<String>;
	public function new( 
			mail:String,
			name:String
	) 
	{
		super(mail.toLowerCase(), name.toLowerCase());
	}
	public function hasDirectReport():Bool
	{
		return !Lambda.empty(directReports);
	}
	public function hasPeers():Bool
	{
		return !Lambda.empty(peers);
	}
	public inline function isExternal():Bool
	{
		return description.indexOf("External employee") > -1;
	}
	function get_manager():String 
	{
		return manager;
	}
	
	function set_manager(value:String):String 
	{
		return manager = value;
	}
	
	function get_authorised():Bool 
	{
		return authorised;
	}
	
	function set_authorised(value:Bool):Bool 
	{
		return authorised = value;
	}
	

	
	function get_mobile():String 
	{
		return mobile;
	}
	
	function set_mobile(value:String):String 
	{
		return mobile = value;
	}
	
	function get_company():String 
	{
		return company;
	}
	
	function set_company(value:String):String 
	{
		return company = value;
	}
	

	
	function get_division():String 
	{
		return division;
	}
	
	function set_division(value:String):String 
	{
		return division = value;
	}
	
	function get_department():String 
	{
		return department;
	}
	
	function set_department(value:String):String 
	{
		return department = value;
	}
	
	function get_distinguishedname():String 
	{
		return distinguishedname;
	}
	
	function set_distinguishedname(value:String):String 
	{
		return distinguishedname = value;
	}
	
	function get_accountexpires():String 
	{
		return accountexpires;
	}
	
	function set_accountexpires(value:String):String 
	{
		return accountexpires = value;
	}
	
	function get_title():String 
	{
		return title;
	}
	
	function set_title(value:String):String 
	{
		return title = value;
	}
	
	function get_initials():String 
	{
		return initials;
	}
	
	function set_initials(value:String):String 
	{
		return initials = value;
	}
	
	function get_directReports():Array<SaltLdapActor> 
	{
		return directReports;
	}
	
	function set_directReports(value:Array<SaltLdapActor>):Array<SaltLdapActor> 
	{
		return directReports = value;
	}
	
	function get_peers():Array<SaltLdapActor> 
	{
		return peers;
	}
	
	function set_peers(value:Array<SaltLdapActor>):Array<SaltLdapActor> 
	{
		return peers = value;
	}
	
	function get_memberof():Array<String> 
	{
		return memberof;
	}
	
	function get_boss():SaltLdapActor 
	{
		return boss;
	}
	
	function set_boss(value:SaltLdapActor):SaltLdapActor 
	{
		return boss = value;
	}
	
	function get_msexchuserculture():String 
	{
		return msexchuserculture;
	}
	
	function set_msexchuserculture(value:String):String 
	{
		return msexchuserculture = value;
	}
	
	function get_description():String 
	{
		return description;
	}
	
	function set_description(value:String):String 
	{
		return description = value;
	}
	
	function get_givenname():String 
	{
		return givenname;
	}
	
	function set_givenname(value:String):String 
	{
		return givenname = value;
	}
	
	function get_sn():String 
	{
		return sn;
	}
	
	function set_sn(value:String):String 
	{
		return sn = value;
	}
	
	function get_l():String 
	{
		return l;
	}
	
	function set_l(value:String):String 
	{
		return l = value;
	}
	
	function set_memberof(value:Array<String>):Array<String> 
	{
		return memberof = value;
	}
	
}