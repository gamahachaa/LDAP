package php ;
import haxe.Json;
import haxe.crypto.Base64;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import ldap.Params;
import php.types.IConfigSalt;
//import lrs.Actor;
import php.LDAP;
import php.Lib;
import php.NativeArray;
import sys.FileSystem;
import sys.io.File;
import ldap.Attributes;
//import php.Syntax;
//import php.types.ILdapConfig;
using StringTools;

/**
 * @todo re abstract outof Salt for further flexibility
 * ...
 * @author bbaudry
 */
class LdapConnector extends LDAP
{
	var config:IConfigSalt;
	var is_conected:Bool;
	var cnFromDn:EReg;
	static inline var ERROR_ATTRIBUTE_MESSAGE:String = "error";
	static inline var INTERNAL:String = "INTERNAL";
	static inline var EXTERNAL_EMPLOYEE:String = "External emp";
	//static inline var EXTERNAL_EMPLOYEE:String = "External employee";

	public var teams(get, null):Map<String,String>;
	public var teamLeaders(get, null):Map<String,String>;

	public function new(config:IConfigSalt)
	{
		super();
		this.config = config;
		cnFromDn = new EReg("^CN=((\\W|\\w)+),OU=Users,OU=Domain-Users,DC=ad,DC=salt,DC=ch$", "gi");
		loadExternalTeams();
		//trace(config);
		//ldap = new LDAP();
		is_conected = this.connect(config.server, config.port);
		#if debug
		//Lib.dump("Is connected : " + is_conected);
		#end
		this.set_option( LDAPOpt.PROTOCOL_VERSION, config.version);
		this.set_option( LDAPOpt.REFERRALS, config.opt_referrals );
	}

	public function isAuthorised( username:String, password:String)
	{
		if (is_conected)
		{
			return this.bind('${config.domain}\\$username', password );
		}
		else return false;
	}
	public function getAttributes( username:String ):StringMap<Dynamic>
	{
		var attrs =  new StringMap<Dynamic>();
		var filter = '(${config.map_username}=$username)';

		var configAttibutes = Lambda.map(config.attributes, function(a) {return Std.string(a).toLowerCase(); });
		//Lib.dump(configAttibutes);
		try{

			var search:NativeArray = this.search(config.dn, filter, Lib.toPhpArray(config.attributes));
			var entries:NativeArray = this.get_entries(search);
			var data:Map<String,NativeArray> = Lib.hashOfAssociativeArray(entries[0]);
			//#if debug
			for (k => v in data)
			{
				if (configAttibutes.indexOf(k.toLowerCase()) > -1)
				{
					attrs.set(k,Lib.hashOfAssociativeArray(v));
				}
			}
			//#end
		}
		catch (e:Exception)
		{
			#if debug
			//trace("NOT FOUND");
			#end
			attrs.set(ERROR_ATTRIBUTE_MESSAGE,'Unknown $username');
		}

		return attrs;
	}
	public function getAttributesFromSingle(searchFilter:String, ?attributesFilter:Array<String>, ?disabled:Bool = false)
	{
		//return parseAttributes(getRawAttributesFromSingle(searchFilter, attributesFilter));
		return getAttributesFromMultiple(searchFilter, attributesFilter== null ? config.attributes: attributesFilter, null, disabled)[0];
	}
	//@todo implement skips
	/**
	 *
	 * @param	searchFilter
	 * @param	attributesFilter
	 * @param	skip
	 * @param	disabled
	 * @return
	 */
	public function getAttributesFromMultiple
	(
		searchFilter:String,
		?attributesFilter:Array<String>,
		?skip:Array<String>,
		?disabled:Bool):Array<StringMap<Dynamic>>
	{
		
		//Lib.dump("getAttributesFromMultiple---------------------");
		//
		
		
		disabled = disabled == null ? false: disabled;
		var attrs =  new Array<StringMap<Dynamic>>();
		var attFilters:Array<String> = Lambda.map(attributesFilter == null ? config.attributesSubs : attributesFilter, function(a) {return Std.string(a).toLowerCase(); });
		#if debug
		Lib.dump(searchFilter);
		Lib.dump(attFilters);
		#end
		////Lib.dump(skip);
		//Lib.dump(disabled);
		
		try
		{

			var search:NativeArray = this.search(disabled ? config.disabled_dn :config.dn, searchFilter, Lib.toPhpArray(attFilters));
			var entries = Lib.toHaxeArray(this.get_entries(search));
			//Lib.dump("entries");
			
			//Lib.dump(entries[0]);
			//Lib.dump(entries[0] == null);
			if (entries[0] == null) return null;
			try{
				for (i in entries)
				{
					#if debug
					Lib.print(i);
					#end
					var parsed = parseRealAttributes(Lib.hashOfAssociativeArray(i));
					//Lib.dump("PARSED---------------------");
					//Lib.dump(parsed);
					attrs.push(parsed);
					//Lib.dump("pushed");
					
				}
			}
			catch (e)
			{
				//Lib.dump("ERROR PARSING");
				//Lib.dump(e);
			}

		}
		catch (e:Exception)
		{
			attrs = [[ERROR_ATTRIBUTE_MESSAGE=>'Unknown']];
		}
		//Lib.dump(attrs[0]);
		//Lib.dump(attrs[0]);
		return attrs;
	}
	/**
	 *
	 * @param	params
	 * @param	String
	 */
	public function setAdditionalAttributesFromStringifiedArray(attributes : String, add:Bool)
	{
		if (add)
			config.attributes = config.attributes.concat(attributes.split(Params.ATTRIBUTE_SEPARATOR));
		else
			config.attributes = attributes.split(Params.ATTRIBUTE_SEPARATOR);
	}
	/**
	 *
	 * @param	params
	 * @param	String
	 */
	public function setAdditionalSubattributesFromStringifiedArray(attributesSubs : String, add:Bool)
	{
		if (add)
			config.attributesSubs = config.attributesSubs.concat(attributesSubs.split(Params.ATTRIBUTE_SEPARATOR));
		else
			config.attributesSubs = attributesSubs.split(Params.ATTRIBUTE_SEPARATOR);

	}
	/**
	 * Set additional LDAP atributes (main and sub) to retrieve from JSON string
	 * Needs  "attributes" and or "attributesSubs"
	 * @param	s
	 */
	public function setAdditionalAttributesFromJsonString(s: String, add:Bool)
	{

		var j = Json.parse(s);
		//Lib.dump(j);
		var has = false;
		var msg = "";
		if (j.attr != null)
		{
			if (add)
				config.attributes = config.attributes.concat(j.attr);
			else
				config.attributes = j.attr;
			has = true;
		}
		else
		{
			msg += "php.LdapConnector::setAdditionalAttributesFromJsonString MISSING 'attributes'";
		}
		if (j.subattr != null)
		{
			if (add)
				config.attributesSubs = config.attributesSubs.concat(j.subattr);
			else
				config.attributesSubs = j.subattr;
			has = true;
		}
		else
		{
			msg += "php.LdapConnector::setAdditionalAttributesFromJsonString MISSING 'attributesSubs'";
		}
		if (!has)
		{
			#if debug
			trace(msg);
			#else
			throw new ErrorException(msg);
			#end
		}

	}
	/**
	 *
	 * @param	username
	 * @param	ldapSearchAtt
	 * @param	attributeFilter
	 * @return
	 */
	public function getUserAttributesToMap(
		username:String,
		?ldapSearchAtt:String = "",
		?attributeFilter:Array<String> = null,
		?skip:Array<String>,
		?disabled:Bool
	):StringMap<Dynamic>
	{
		//Lib.dump("getUserAttributesToMap------------------------");
		var mapper = ldapSearchAtt == "" ? config.map_username : ldapSearchAtt;
		var filter = '$mapper=$username';
		//Lib.dump(filter);
		try{
			//return parseAttributes(getRawAttributesFromSingle(filter, attributeFilter));
			var ma = getAttributesFromMultiple(filter, attributeFilter, skip, disabled );
			//Lib.dump(ma);
			//Lib.dump(ma[0]);
			return ma[0];
		}
		catch (e:Exception)
		{
			return ["error" => 'Error searching "$filter"'];
		}

		//return attrs;
	}
	/**
	 *
	 * @param	username
	 * @param	ldapSearchAtt
	 * @param	attributeFilter
	 * @return
	 */
	public function getActor( username:String, ?attributeFilter):SaltLdapActor
	{
		var mapper = config.map_username;

		var filter = '$mapper=$username';

		//var parsedAttributes:StringMap<Dynamic> = parseAttributes(getRawAttributesFromSingle(filter, fullAttributes? config.attributes: config.attributesSubs));

		try{

			return attributesToActor(getAttributesFromMultiple(filter, attributeFilter)[0]);

		}
		catch (e:Exception)
		{
			return null;
		}

		//return attrs;
	}

	function parseRealAttributes( attributes:StringMap<Dynamic> ):Map<Attributes,Dynamic>
	{
		//Lib.dump("parseRealAttributes------------------------");
		//Lib.dump(attributes);
		var  r:Map<Attributes,Dynamic> = [];

		for ( k=> v in attributes)
		{

			if ( Std.parseInt(k) != null)
			{
				continue ;
			}
			else
			{
				//Lib.print("<br>");
				//Lib.print(k);
				//Lib.print(" >>> ");
				//Lib.print(v);
				//Lib.print("<br>");
				if (k == "count")
				{
					continue ;
				}
				else
				{
					if (Type.getClass(v) == String)
					{
						r.set(k, v);
					}
					else
					{
						var value = Lib.hashOfAssociativeArray(attributes.get(k));
						if ( value.get("count") > 1)
						{
							r.set(k, filterCN(Lib.toHaxeArray(v)));
						}
						else if (value.get("count") == 1)
						{
							//trace(k);
							//trace("<br/>");
							//trace(value, Type.getClass(value['0']));
							//trace("<br/>");
							if (k == Attributes.thumbnailphoto)
							{
								r.set(k,
									  Base64.encode(
										  Bytes.ofString(
											  //cast(value['0']) 
											  Reflect.field(value,'0')
										  )
									  )
									 );
							}
							else
								//r.set(k, value['0']);
								r.set(k, Reflect.field(value,'0'));
						}
						else
						{
							//
						}

					}
				}
			}
		}
		if (r.exists(Attributes.memberOf))
		{
			r.set(Attributes.memberOf, filterCN(r.get(Attributes.memberOf)));
		}
		//Lib.dump(r);
		return r;
	}
	function parseAttributes(attributes:StringMap<Dynamic>):Map<String,Dynamic>
	{
		var  r:Map<String,Dynamic> = [];
		for (k=>v in attributes)
		{
			if (Type.getClass(v) == String) r.set(k, v);
			else if (v.get("count") == 1)
			{

				r.set(k, v.get('0'));
			}
			else
			{
				r.set(k, filterCN(Lambda.array(v)));
			}

		}
		return r;
	}

	function get_teams():Map<String, String>
	{
		return teams;
	}

	public function filterCN(tab:Array<String>)
	{
		var erg:EReg = new EReg("^CN=([.&a-zA-Z0-9_ -]*),\\s*\\S*$", "g");
		var r = [];
		for (i in tab)
		{
			if (erg.match(i))
			{
				r.push(erg.matched(1));
			}
			else if (i !=null)
			{
				r.push(i);
			}

		}
		return r;
	}
	function loadExternalTeams()
	{
		/**
		 * @todo use csv reader package
		 */
		teams = [];
		teamLeaders = [];

		if (config.externalTeamsPath != "" && FileSystem.exists(config.externalTeamsPath))
		{
			//var f = File.getContent(config.externalTeamsPath);
			var h = File.read( config.externalTeamsPath, false);

			var l = [];
			//var s = "";
			try
			{
				while (true)
				{
					l = h.readLine().split(";");
					// build both tls and teams Maps
					if (l[0].trim() != "")
						teams.set(	l[0], l[1] ); teamLeaders.set(	l[1], l[0] );
				}
			}
			catch (e)
			{
				//Lib.println(e);
			}

		}
	}
	public function getTeamTlList():String
	{
		return File.getContent( config.externalTeamsPath );
	}
	public function setTeamTlList(list:String)
	{
		try
		{
			File.saveContent( config.externalTeamsPath, list );
		}
		catch (e)
		{
			trace(e);
		}
	}
	inline function isInternal(s:String)
	{
		return s.toLowerCase().indexOf(EXTERNAL_EMPLOYEE.toLowerCase()) == -1;
	}

	function get_teamLeaders():Map<String, String>
	{
		return teamLeaders;
	}

	public function getExtTeamFromDescription( attributes :StringMap<Dynamic> )
	{
		var desc:String = cast(attributes.get(Attributes.description.toLowerCase()), String);
		return isInternal(desc) ? INTERNAL: desc.split("/").pop().trim();
	}
	public function getArrayOfDirectreportsActors(attributes :StringMap<Dynamic>,attibutesFilter:Array<Attributes>):Array<SaltLdapActor>
	{
		var dr : Array<StringMap<Dynamic>> = getDirectReports(attributes, attibutesFilter);
		var r = [];
		var tmp:SaltLdapActor;
		for (i in dr)
		{
			tmp = new SaltLdapActor(i.get(Attributes.mail), i.get(Attributes.sAMAccountName.toLowerCase()));
			tmp.distinguishedname = i.get(Attributes.distinguishedName.toLowerCase());
			r.push(tmp);
		}
		return r;
	}
	public function getDirectReports(attributes :StringMap<Dynamic>,attibutesFilter:Array<Attributes>)
	{
		var team = getExtTeamFromDescription(attributes);
		if (team == INTERNAL)
		{
			//internals
			return getDirectReportsFromDN(attributes.get(Attributes.distinguishedName.toLowerCase()), attibutesFilter);
		}
		else
		{
			//externals
			return getDirectReportsForExternals(attributes.get(Attributes.sAMAccountName.toLowerCase()), attibutesFilter);
		}
	}
	public function getDirectReportsFromDN(dn:String, attibutesFilter:Array<Attributes>):Array<StringMap<Dynamic>>
	{
		//var  dr = ;
		if (dn != "" && cnFromDn.match(dn))
		{
			//searchDN = '(manager=$dn})';

			return getAttributesFromMultiple( '(${Attributes.manager}=$dn)', attibutesFilter);
		}
		else
		{
			//throw ("status", 'not a valid DN: "$dn", cannot fetch Direct reports' );
			throw new ErrorException('not a valid DN: "$dn", cannot fetch Direct reports');
			return new Array<StringMap<Dynamic>>();
		}
	}
	public function getDirectReportsForExternals( manager:String, attibutesFilter:Array<Attributes> ) :Array<StringMap<Dynamic>>
	{
		if ( teamLeaders.exists(manager))
		{

			var tlTeam = teamLeaders.get(manager);

			//searchDN = '(description=*$tlTeam*)';
			return getAttributesFromMultiple(  '(${Attributes.description}=*$tlTeam*)', attibutesFilter);
		}
		else
		{
			//#if debug
			//trace('teamLeaders.exists(Attributes.sAMAccountName.toLowerCase()) ${teamLeaders.exists(Attributes.sAMAccountName.toLowerCase())}');
			//#end
			return new Array<StringMap<Dynamic>>();
		}
	}
	public function getMultiplesFromEmailList(list:Array<String>, ?attributes :Array<String>)
	{

		return  getAttributesFromMultiple(
					generateORSearchFromAttributeAndList(
						list, Attributes.mail
					),
					attributes == null ? config.attributesSubs: attributes
				);
	}
	public function getPeers(attributes:StringMap<Dynamic>, attibutesFilter:Array<Attributes>)
	{
		var searchDN = "";
		var team = getExtTeamFromDescription(attributes);
		if (team == INTERNAL)
		{
			//searchDN = '(${Attributes.manager}=${attributes.get(${Attributes.manager})})';
			searchDN = "(" + Attributes.manager +"=" + attributes.get(Attributes.manager) +")";
		}
		else
		{
			//externals
			searchDN = '(${Attributes.description}=*$team*)';
		}

		return getAttributesFromMultiple( searchDN, attibutesFilter, [attributes.get(Attributes.sAMAccountName.toLowerCase())]);

	}
	public 	function getBoss(
		attributes:StringMap<Dynamic>,
		attibutesFilter:Array<Attributes>,
		?disabled:Bool
	):StringMap<Dynamic>
	{
		//Lib.dump("getBoss------------------------");
		//Lib.dump(attributes);
		//Lib.dump(disabled);
		var team = getExtTeamFromDescription( attributes );
		//var cn = "";//
		//Lib.print(team);

		if (team != INTERNAL && teams.exists(team))
		{
			//Lib.print(teams.exists(team));
			//Lib.print("  >> ");
			//Lib.print(teams.get( team ));
//
			//Lib.print("<BR>");
			//for (k => v in attributes)
			//{
			//Lib.print(k); Lib.print("  >> "); Lib.print(v);
			//}
//
			//Lib.print("<BR>");
			var boosAttrbiute =  getUserAttributesToMap( 
									teams.get( team ), 
									config.map_username, 
									attibutesFilter == null ? config.attributesSubs: attibutesFilter, 
									null, 
									disabled);
			//var boosAttrbiute = getAttributesFromMultiple('(|(sAMAccountName=${teams.get( team )}))',attibutesFilter == null ? config.attributesSubs: attibutesFilter, 
									//null, 
									//disabled);						
			//Lib.dump("boosAttrbiute");					
			//Lib.dump(boosAttrbiute);						
			return boosAttrbiute;
		}
		else{
            //Lib.print("  <<  ");
			//internal
			//cn = attributes.get("manager");
			if (cnFromDn.match(attributes.get(Attributes.manager)))
			{
				return getUserAttributesToMap(cnFromDn.matched(1), Attributes.cn, attibutesFilter == null ? config.attributesSubs: attibutesFilter, null, disabled);
			}
			return [ERROR_ATTRIBUTE_MESSAGE=>'cn did not match'];
		}
		//return getManagerNtEmailFromAttribute(cn) ;
	}
	public 	function getOldBoss(attributes:StringMap<Dynamic>, attibutesFilter:Array<Attributes>,
								?disabled:Bool):StringMap<Dynamic>
	{
		var team = getExtTeamFromDescription( attributes );
		//var cn = "";//
		if (team == "")
		{
			//internal
			//cn = attributes.get("manager");
			if (cnFromDn.match(attributes.get(Attributes.manager)))
			{
				return getUserAttributesToMap(cnFromDn.matched(1), Attributes.cn, attibutesFilter == null ? config.attributesSubs: attibutesFilter, null, disabled);
			}
			return [ERROR_ATTRIBUTE_MESSAGE=>'cn did not match'];
		}
		else{
			//external
			if (teams.exists(team))
				return getUserAttributesToMap( teams.get( team ), config.map_username, attibutesFilter == null ? config.attributesSubs: attibutesFilter, null,  disabled);
			else {
				return [ERROR_ATTRIBUTE_MESSAGE=>'No boss found for $team'];
			}
		}
		//return getManagerNtEmailFromAttribute(cn) ;
	}
	public function getBossActor(attributes:StringMap<Dynamic>, attibutesFilter:Array<Attributes>)
	{
		return attributesToActor(getBoss(attributes, attibutesFilter));

	}
	function attributesToActor(attributes:StringMap<Dynamic>)
	{
		var A:SaltLdapActor = new SaltLdapActor(attributes.get(Attributes.mail), attributes.get(Attributes.sAMAccountName.toLowerCase()) );
		for (k=>v in attributes)
		{
			if (k == Attributes.mail || k == Attributes.sAMAccountName) continue;
			else
			{
				Reflect.setField(A, k.toLowerCase(), v);
			}
		}
		return A;
	}
	public function generateORSearchFromAttributeAndList(list:Array<String>, ldapAttibute:String, ?wildCard:Bool=false ):String
	{
		var w = wildCard ? "*":"";
		return multipleSearchesOR(Lambda.map(list, (e:String)->(return '($ldapAttibute=$w$e$w)')));
	}
	public function generateANDSearchFromAttributeAndList(list:Array<String>, ldapAttibute:String, ?wildCard:Bool=false ):String
	{
		var w = wildCard ? "*":"";
		return multipleSearchesAND(Lambda.map(list, (e:String)->(return '($ldapAttibute=$w$e$w)')));
	}
	inline public function multipleSearchesOR(searches:Array<String>)
	{
		return  "(|" + searches.join("") + ")";
	}
	inline public function multipleSearchesAND(searches:Array<String>)
	{
		return  "(&" + searches.join("") + ")";
	}
}