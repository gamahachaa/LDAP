
package php;

class LDAPOpt {
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

class LDAPDeref {
    public static inline var NEVER     = 0x00;
    public static inline var SEARCHING = 0x01;
    public static inline var FINDING   = 0x02;
    public static inline var ALWAYS    = 0x03;
}

class LDAP
{
    var connection : Dynamic;

    static function __init__():Void untyped
    {
        var is_ldap_installed = untyped __call__("function_exists", "ldap_connect");
        if (!is_ldap_installed) {
            throw "no ldap installed";
        }
    }

    public function new() {}

    public function bind(?user : String, ?password : String) : Bool
    {
        //@ call sucks but i don't know how to do it otherwise yet
        var success = false;
        if (user == null || password == null) {
            //Attempt Anonymous bind
            success = untyped __call__("@ldap_bind", connection);
        } else {
            success = untyped __call__("@ldap_bind", connection, user, password);
        }

        return untyped __physeq__(success, true);
    }

    public function convert_8859_to_t61(value : String) {
        return untyped __call__("ldap_8859_to_61", value);
    }

    public function convert_t61_to_8859(value : String) {
        return untyped __call__("ldap_t61_to_8859", value);
    }

    public function close()
    {
        return unbind();
    }

    public function connect(host : String, ?port : Int) : Bool
    {
        if (port == null) {
            connection = untyped __call__("ldap_connect", host);
        } else {
            connection = untyped __call__("ldap_connect", host, port);
        }

        //Will return true almost always since there is no real connection. Bind is more reliable for connection checking somehow
        return untyped __physeq__(connection, false);
    }

    public function err2str(errno : Int) : String
    {
        return untyped __call__("ldap_err2str", connection, errno);
    }

    public function errno() : Int
    {
        return untyped __call__("ldap_errno", connection);
    }

    public function error() : String
    {
        return untyped __call__("ldap_error", connection);
    }

    public function free_result(result : Dynamic) : Bool
    {
        return untyped __physeq__(untyped __call__("ldap_free_result", connection, result), true);
    }

    public function get_entries(result : Dynamic)
    {
        return Lib.hashOfAssociativeArray(untyped __call__("ldap_get_entries", connection, result));
    }

    public function get_option(option : Int) : Dynamic
    {
        var return_value : Dynamic = null;

        var success = untyped __call__("ldap_get_option", connection, option, return_value);

        if (untyped __physeq__(success, true)) {
            return return_value;
        } else {
            return null;
        }
    }

    public function list(base_dn : String, filter : String, ?attributes : haxe.ds.StringMap<Dynamic>, attributes_only : Int = 0, size_limit : Int = 0, time_limit : Int = 0, ?deref : Int) : Dynamic
    {
        if (attributes == null) {
            attributes = new haxe.ds.StringMap<Dynamic>();
        }
        if (deref == null) {
            deref = LDAPDeref.NEVER;
        }
        return untyped __call__("ldap_list", connection, base_dn, filter, Lib.associativeArrayOfHash(attributes), attributes_only, size_limit, time_limit, deref);
    }

    public function read(base_dn : String, filter : String, ?attributes : haxe.ds.StringMap<Dynamic>, attributes_only : Int = 0, size_limit : Int = 0, time_limit : Int = 0, ?deref : Int) : Dynamic
    {
        if (attributes == null) {
            attributes = new haxe.ds.StringMap<Dynamic>();
        }
        if (deref == null) {
            deref = LDAPDeref.NEVER;
        }
        return untyped __call__("ldap_read", connection, base_dn, filter, Lib.associativeArrayOfHash(attributes), attributes_only, size_limit, time_limit, deref);
    }

    public function search(base_dn : String, filter : String, ?attributes : haxe.ds.StringMap<Dynamic>, attributes_only : Int = 0, size_limit : Int = 0, time_limit : Int = 0, ?deref : Int) : Dynamic
    {
        if (attributes == null) {
            attributes = new haxe.ds.StringMap<Dynamic>();
        }
        if (deref == null) {
            deref = LDAPDeref.NEVER;
        }
        return untyped __call__("ldap_search", connection, base_dn, filter, Lib.associativeArrayOfHash(attributes), attributes_only, size_limit, time_limit, deref);
    }

    public function set_option(option : Int, value : Dynamic) : Bool
    {
        return untyped __physeq__(untyped __call__("ldap_set_option", connection, option, value), true);
    }

    public function sort(result : Dynamic, sort_filter : String) {
        return untyped __call__("ldap_sort", connection, result, sort_filter);
    }

    public function start_tls() {
        return untyped __call__("ldap_start_tls", connection);
    }

    public function unbind() : Bool
    {
        return untyped __call__("ldap_unbind", connection);
    }

}