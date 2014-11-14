LDAP
====

Haxe LDAP wrapper for the php target.  
It isn't complete yet, but you can bind and search. Should be enough for LDAP Auth.
Feel free to contribute.


Installation
====

`haxelib install LDAP`


Usage Example
====

It is basically just the PHP LDAP functions wrapped into a Haxe class.  
Options for `set_option` are in the `LDAPOpt` class and Deref Options are in the `LDAPDeref` class.
```Haxe
import php.LDAP;
import php.Lib;

class Index
{
    static function main()
    {
        var ldap = new LDAP();

        ldap.connect("ldap://yourhost", 389);

        ldap.set_option(LDAPOpt.PROTOCOL_VERSION, 3);

        var bind = ldap.bind("cn=user,dc=example,dc=com", "password");

        if (bind) {
            var result = ldap.search('ou=octocats,dc=example,dc=com', ' (objectClass=user)');

            var entries = ldap.get_entries(result);

            for (e in entries) {
                Lib.dump(e);
            }

            ldap.close();
        }
    }
}
```

