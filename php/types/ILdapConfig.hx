package php.types ;

/**
 * @author bbaudry
 */
interface ILdapConfig 
{
	public var dn(get, null):String;
	public var server(get, null):String;
	public var port(get, null):Int;
	public var domain(get, null):String;
	public var map_username(get, null):String;
	public var version(get, null):Int;
	public var opt_referrals(get, null):Int;
	
	
	/*public var attributes(get, null):Array<String>; 
	public var attributesSubs(get, null):Array<String>;*/ 
}