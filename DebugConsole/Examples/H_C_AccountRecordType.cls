//
//This class provides methods to wotk with record types of 'Account' object
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-05-2013)
public without sharing class H_C_AccountRecordType
{
	//
	//Constants
	//
    public static String CONTRACT_ACCOUNT;
    public static String KEY_REGION_ACCOUNT;
    public static String TRANSACTIONAL_ACCOUNT;
    public static String PROSPECT_ACCOUNT;
    
    public static String[] ALL_KNOWN_RECORD_TYPES;
    
    //initialize constants from custom settings
    static
    {
    	//get value from custom setting and fill 'CONTRACT_ACCOUNT' constant
    	String recordTypeNameFromSetting = H_C_CustomSettings.getStringValueByName(
    		H_C_CustomSettings.RTN_CONTRACT_ACCOUNT);
    	CONTRACT_ACCOUNT = (recordTypeNameFromSetting != null
    		? recordTypeNameFromSetting : 'Customer Account');
    	
    	//get value from custom setting and fill 'KEY_REGION_ACCOUNT' constant
    	recordTypeNameFromSetting = H_C_CustomSettings.getStringValueByName(
    		H_C_CustomSettings.RTN_KEY_REGION_ACCOUNT);
    	KEY_REGION_ACCOUNT = (recordTypeNameFromSetting != null
    		? recordTypeNameFromSetting : 'Focus Account');
    	
    	//get value from custom setting and fill 'TRANSACTIONAL_ACCOUNT' constant
    	recordTypeNameFromSetting = H_C_CustomSettings.getStringValueByName(
    		H_C_CustomSettings.RTN_TRANSACTIONAL_ACCOUNT);
    	TRANSACTIONAL_ACCOUNT = (recordTypeNameFromSetting != null
    		? recordTypeNameFromSetting : 'Transactional Account');
    	
    	//get value from custom setting and fill 'PROSPECT_ACCOUNT' constant
    	recordTypeNameFromSetting = H_C_CustomSettings.getStringValueByName(
    		H_C_CustomSettings.RTN_PROSPECT_ACCOUNT);
    	PROSPECT_ACCOUNT = (recordTypeNameFromSetting != null
    		? recordTypeNameFromSetting : 'Prospect Account');
    	
    	//initialize and fill ALL_KNOWN_RECORD_TYPES
    	ALL_KNOWN_RECORD_TYPES = new String[] {CONTRACT_ACCOUNT, KEY_REGION_ACCOUNT,
    		TRANSACTIONAL_ACCOUNT, PROSPECT_ACCOUNT};
    }
    //
    
    //
    //Variables
    //
    //map stores mappings between between Ids and Names of records types 
    private static Map<String, String> var_mapOfIdsAndNames;
    //map stores mappings between between Names and Objects of records types
    private static Map<String, RecordType> var_mapOfNamesAndRecordTypes;
    //this array keeps all record types for accounts
    private static RecordType[] var_accountRecordTypes;
    //
    
    //
    //Properties
    // 
    private static RecordType[] accountRecordTypes
    {
    	get
    	{
	    	//the array is initialized at the moment when it's used the first time
	    	if (var_accountRecordTypes == null)
	    	{
		    	//get all record types for 'Account' object;
		        var_accountRecordTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account'];
	    	}
	    	return var_accountRecordTypes;
    	}
    }
    
    public static Map<String, String> mapOfIdsAndNames
    {
    	get
    	{
    		//the map is initialized at the moment when it's used the first time
			if (var_mapOfIdsAndNames == null)
			{
				//initialize and fill mapOfIdsAndNames
		        var_mapOfIdsAndNames = new Map<String, String>();
		        for (RecordType rt : accountRecordTypes)
		        {
		            var_mapOfIdsAndNames.put(rt.Id, rt.Name);
		        }
			}
			return var_mapOfIdsAndNames;
    	}
    }
    
    public static Map<String, RecordType> mapOfNamesAndRecordTypes
    {
    	get
    	{
	    	//the map is initialized at the moment when it's used the first time
	    	if (var_mapOfNamesAndRecordTypes == null)
	    	{
	    		//initialize and fill mapOfNamesAndRecordTypes
		        var_mapOfNamesAndRecordTypes = new Map<String, RecordType>();
		        for (RecordType rt : accountRecordTypes)
		        {
		        	System.debug('RecT - ' + rt.Name);
		            var_mapOfNamesAndRecordTypes.put(rt.Name, rt);
		        }
	    	}
	    	return var_mapOfNamesAndRecordTypes;
    	}
    }
    
    //map stores mappings between record type name and its parent record type name
    public static Map<String, String> mapOfParentRecordTypes {get; private set;}
    static
    {
        //initialize and fill mapOfParentRecordTypes
        mapOfParentRecordTypes = new Map<String, String>();
        mapOfParentRecordTypes.put(KEY_REGION_ACCOUNT, CONTRACT_ACCOUNT);
        mapOfParentRecordTypes.put(TRANSACTIONAL_ACCOUNT, KEY_REGION_ACCOUNT);
    }
    
    //map stores mappings between record type name and its child record type name
    public static Map<String, String> mapOfChildRecordTypes {get; private set;}
    static
    {
        //initialize and fill mapOfParentRecordTypes
        mapOfChildRecordTypes = new Map<String, String>();
        mapOfChildRecordTypes.put(CONTRACT_ACCOUNT, KEY_REGION_ACCOUNT);
        mapOfChildRecordTypes.put(KEY_REGION_ACCOUNT, TRANSACTIONAL_ACCOUNT);
    }
    //
    
    
    //
    //Public static methods
    //    
    public static String[] getRecordTypeIdsByNames(String[] recordTypeNames)
    {
    	//if input parameter is incorrect then return null
        if (recordTypeNames == null)
        {
            return null;
        }
        
        List<String> recordTypeIds = new List<String>();
        //save the map into a local variable to increase performance
        Map<String, RecordType> localMapOfNamesAndRecordTypes = mapOfNamesAndRecordTypes;
        //iterate through record type names
        for (String recordTypeName : recordTypeNames)
        {
        	//get record type object by its name from the map
            RecordType recordTypeObject = localMapOfNamesAndRecordTypes.get(recordTypeName);
            if (recordTypeObject != null)
            {
            	//if object was obtained successfully then we add record type Id into the result list
                recordTypeIds.add(recordTypeObject.Id);
            }
        }
        //return the list of record type Ids
        return recordTypeIds;
    }
    //
}