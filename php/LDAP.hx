
package php;

class LDAPOpt
{
	public static inline var DEREF            = 0x02;
	public static inline var SIZELIMIT        = 0x03;
	public static inline var TIMELIMIT        = 0x04;
	public static inline var REFERRALS        = 0x08;
	public static inline var RESTART          = 0x09;
	public static inline var PROTOCOL_VERSION = 0x11;
	public static inline var SERVER_CONTROLS  = 0x12;
	public static inline var CLIENT_CONTROLS  = 0x13;
	public static inline var API_FEATURE_INFO = 0x15;
	public static inline var HOST_NAME        = 0x30;
	public static inline var ERROR_NUMBER     = 0x31;
	public static inline var ERROR_STRING     = 0x32;
	public static inline var MATCHED_DN       = 0x33;
	public static inline var DEBUG_LEVEL      = 0x5001;
	public static inline var NETWORK_TIMEOUT  = 0x5005;
}

class LDAPDeref
{
	public static inline var NEVER     = 0x00;
	public static inline var SEARCHING = 0x01;
	public static inline var FINDING   = 0x02;
	public static inline var ALWAYS    = 0x03;
}

class LDAP
{
	var connection : Dynamic;

	public static function __init__():Void
	{
		var is_ldap_installed = Global.function_exists("ldap_connect");
		if (!is_ldap_installed)
		{
			throw "no ldap installed";
		}
		else{
			#if debug
			trace("LDAP is installed");
			#end
		}
	}

	public function new() {}

	public function bind(?user : String, ?password : String) : Bool
	{
		//@ call sucks but i don't know how to do it otherwise yet
		var success = false;
		try{
			if (user == null || password == null)
			{
				//Attempt Anonymous bind
				success = Syntax.code("ldap_bind({0})", connection);
			}
			else {

				success = Syntax.code("ldap_bind({0}, {1}, {2})", connection, user, password);

			}
		}
		catch ( e:Dynamic  )
		{
			#if debug
			trace(e);
			#end
			return false;
		}
		return Syntax.strictEqual(success, true);
	}

	public function convert_8859_to_t61(value : String)
	{
		return Syntax.code("ldap_8859_to_61({0})", value);
	}

	public function convert_t61_to_8859(value : String)
	{
		return Syntax.code("ldap_t61_to_8859({0})", value);
	}

	public function close()
	{
		return unbind();
	}

	public function connect(host : String, ?port : Int) : Bool
	{
		if (port == null)
		{
			connection = Syntax.code("ldap_connect({0})", host);
		}
		else {
			connection = Syntax.code("ldap_connect({0}, {1})", host, port);
		}

		//Will return true almost always since there is no real connection. Bind is more reliable for connection checking somehow
		return !Syntax.strictEqual(connection, false);
	}

	public function err2str(errno : Int) : String
	{
		return Syntax.code("ldap_err2str({0},{1})", connection, errno);
	}

	public function errno() : Int
	{
		return Syntax.code("ldap_errno({0})", connection);
	}

	public function error() : String
	{
		return Syntax.code("ldap_error({0})", connection);
	}

	public function free_result(result : Dynamic) : Bool
	{
		return Syntax.strictEqual(Syntax.code("ldap_free_result({0},{1})", connection, result), true);
	}

	public function get_entries(result : Dynamic)
	{
		/** kept from original for compatibilty */
		return Lib.hashOfAssociativeArray(Syntax.code("ldap_get_entries({0},{1})", connection, result));
		/** if it makes more sense to keep all native inside and deal with mapping data outside uncomment the line below and comment the above*/
		//return Syntax.code("ldap_get_entries({0},{1})", connection, result);
	}

	public function get_option(option : Int) : Dynamic
	{
		var return_value : Dynamic = null;

		var success = Syntax.code("ldap_get_option({0},{1},{2})", connection, option, return_value);

		if (Syntax.strictEqual(success, true))
		{
			return return_value;
		}
		else {
			return null;
		}
	}

	public function list(base_dn : String, filter : String, ?attributes : NativeArray, attributes_only : Int = 0, size_limit : Int = 0, time_limit : Int = 0, ?deref : Int) : Dynamic
	{
		if (attributes == null)
		{
			attributes = new NativeArray();
		}
		if (deref == null)
		{
			deref = LDAPDeref.NEVER;
		}
		return Syntax.code("ldap_list({0},{1},{2},{3},{4},{5},{6},{7})", connection, base_dn, filter, attributes, attributes_only, size_limit, time_limit, deref);
	}

	public function read(base_dn : String, filter : String, ?attributes : NativeArray, attributes_only : Int = 0, size_limit : Int = 0, time_limit : Int = 0, ?deref : Int) : Dynamic
	{
		if (attributes == null)
		{
			attributes = new NativeArray();
		}
		if (deref == null)
		{
			deref = LDAPDeref.NEVER;
		}
		return Syntax.code("ldap_read({0},{1},{2},{3},{4},{5},{6},{7})", connection, base_dn, filter, attributes, attributes_only, size_limit, time_limit, deref);
	}

	public function search(base_dn : String, filter : String, ?attributes : NativeArray, attributes_only : Int = 0, size_limit : Int = 0, time_limit : Int = 0, ?deref : Int) : Dynamic
	{
		if (attributes == null)
		{
			attributes = new NativeArray();
		}
		if (deref == null)
		{
			deref = LDAPDeref.NEVER;
		}
		return Syntax.code("ldap_search({0},{1},{2},{3},{4},{5},{6},{7})", connection, base_dn, filter, attributes, attributes_only, size_limit, time_limit, deref);
	}

	public function set_option(option : Int, value : Dynamic) : Bool
	{
		return Syntax.strictEqual(Syntax.code("ldap_set_option({0},{1},{2})", connection, option, value), true);
	}

	public function sort(result : Dynamic, sort_filter : String)
	{
		return Syntax.code("ldap_sort({0},{1},{2})", connection, result, sort_filter);
	}

	public function start_tls()
	{
		return Syntax.code("ldap_start_tls({0})", connection);
	}

	public function unbind() : Bool
	{
		return Syntax.code("ldap_unbind({0})", connection);
	}

}
