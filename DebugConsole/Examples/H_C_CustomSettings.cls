// 
//This class provides access to custom settings
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin
public class H_C_CustomSettings
{
    //
    //Constants
    //
    public static final String RTN_CONTRACT_ACCOUNT = 'RTN_CONTRACT_ACCOUNT';
    public static final String RTN_KEY_REGION_ACCOUNT = 'RTN_KEY_REGION_ACCOUNT';
    public static final String RTN_TRANSACTIONAL_ACCOUNT = 'RTN_TRANSACTIONAL_ACCOUNT';
    public static final String RTN_PROSPECT_ACCOUNT = 'RTN_PROSPECT_ACCOUNT';
    
    public static final String TRIGGERS_ENABLED = 'TRIGGERS_ENABLED';
    
    public static final String ATRD_PROCESS_ENABLED = 'ATRD_PROCESS_ENABLED';
    public static final String ATRD_CA_2_KA_IGNORABLE_TEAM_ROLES = 'ATRD_CA_2_KA_IGNORABLE_TEAM_ROLES';
    public static final String ATRD_KA_2_TA_IGNORABLE_TEAM_ROLES = 'ATRD_KA_2_TA_IGNORABLE_TEAM_ROLES';
    
    public static final String ATRU_IGNORABLE_TEAM_ROLES = 'ATRU_IGNORABLE_TEAM_ROLES';
    
    public static final String ATRU_TA_2_KA_MINIMAL_PARTICIPATION = 'ATRU_TA_2_KA_MINIMAL_PARTICIPATION';
    public static final String ATRU_TA_2_KA_PERMITS_FOR_NEW_ATMs = 'ATRU_TA_2_KA_PERMITS_FOR_NEW_ATMs';
    public static final String ATRU_TA_2_KA_ROLES_FOR_NEW_ATMs = 'ATRU_TA_2_KA_ROLES_FOR_NEW_ATMs';
    //public static final String ATRU_TA_2_KA_ROLE_FOR_OWNER_ATM = 'ATRU_TA_2_KA_ROLE_FOR_OWNER_ATM';
    //public static final String ATRU_TA_2_KA_CONSIDER_OWNERS = 'ATRU_TA_2_KA_CONSIDER_OWNERS';
    public static final String ATRU_KA_2_CA_MINIMAL_PARTICIPATION = 'ATRU_KA_2_CA_MINIMAL_PARTICIPATION';
    public static final String ATRU_KA_2_CA_PERMITS_FOR_NEW_ATMs = 'ATRU_KA_2_CA_PERMITS_FOR_NEW_ATMs';
    public static final String ATRU_KA_2_CA_ROLES_FOR_NEW_ATMs = 'ATRU_KA_2_CA_ROLES_FOR_NEW_ATMs';
    
    public static final String ANY_ROLE_NAME = 'ANY';
    public static final String SEPARATOR_OF_ROLES = ',';
    
    public static final String CRON_EXPR_FOR_SCHEDULED_ACCOUNTS_MNGR = 'CRON_EXPR_FOR_SCHEDULED_ACCOUNTS_MNGR';
    
    public static final String SCOPE_FOR_ACCOUNT_HIERARCHY_MANAGER = 'SCOPE_FOR_ACCOUNT_HIERARCHY_MANAGER';
    public static final String SCOPE_FOR_ACCOUNT_RELATED_LISTS_MANAGER = 'SCOPE_FOR_ACCOUNT_RELATED_LISTS_MNGR';
    public static final String SCOPE_FOR_ATRU_MANAGER = 'SCOPE_FOR_ATRU_MANAGER';
    public static final String SCOPE_FOR_ATRD_MANAGER = 'SCOPE_FOR_ATRD_MANAGER';
    public static final String SCOPE_FOR_COMPUTE_ACCOUNT_CHILD = 'SCOPE_FOR_COMPUTE_ACCOUNT_CHILD';
    //
    
    //
    //Variables
    //
    private static transient Boolean triggersEnabled;
    
    //Variables which are used for caching 
    private static List<String> ignorableATMRolesForRollup;
    //the map stores mappings between record type name of an account and roll-DOWN
    //options for such accounts
    private static Map<String, H_C_ATRD_Options> mapOfATRD_Options =
        new Map<String, H_C_ATRD_Options>();
    //the map stores mappings between record type name of an account and roll-UP
    //options for such accounts
    private static Map<String, H_C_ATRU_Options> mapOfATRU_Options =
        new Map<String, H_C_ATRU_Options>();
    //
    
    //
    //Public static methods
    //
    //this method gets string value from a custom setting and returns it
    public static String getStringValueByName(String settingName)
    {
        try
        {
            H_C_Settings__c setting = H_C_Settings__c.getValues(settingName);
            if (setting != null)
            {
                return setting.value__c;
            }
        }
        catch (Exception ex)
        {
            System.debug(LoggingLevel.WARN, ex);
        }
        return null;
    }
    
    //this method gets string value from a custom setting, tries to convert it to an Integer
    //and returns the result
    public static Integer getIntegerValueByName(String settingName)
    {
        try
        {
            String settingValue = getStringValueByName(settingName);
            return Integer.valueOf(settingValue);
        }
        catch (Exception ex)
        {
            System.debug(LoggingLevel.WARN, ex);
        }
        return null;
    }
    
    //this method gets string value from a custom setting, tries to convert it to a Double
    //and returns the result
    public static Double getDoubleValueByName(String settingName)
    {
        try
        {
            String settingValue = getStringValueByName(settingName);
            return Double.valueOf(settingValue);
        }
        catch (Exception ex)
        {
            System.debug(LoggingLevel.WARN, ex);
        }
        return null;
    }
    
    //this method gets string value from a custom setting, tries to convert it to a Boolean
    //and returns the result
    public static Boolean getBooleanValueByName(String settingName)
    {
        try
        {
            String settingValue = getStringValueByName(settingName);
            return Boolean.valueOf(settingValue);
        }
        catch (Exception ex)
        {
            System.debug(LoggingLevel.WARN, ex);
        }
        return null;
    }
    
    //this method gets string value from a custom setting, tries to convert it to JSON-format,
    //deserializes it to 'AccountShare' object and returns it
    public static AccountShare getAccountShareByName(String settingName)
    {
        try
        {
            String settingValue = getStringValueByName(settingName);
            if (String.isNotBlank(settingValue))
            {
                String jsonString = settingValue.replace(' ', '');
                jsonString = jsonString.replace(',', '","');
                jsonString = jsonString.replace(':', '":"');
                jsonString = '{"' + jsonString + '"}';
                
                return (AccountShare)Json.deserialize(jsonString, AccountShare.class);
            }
        }
        catch (Exception ex)
        {
            System.debug(LoggingLevel.WARN, ex);
        }
        return null;
    }
    
    //this method returns the value which determines whether the triggers are enabled or no. The method
    //reads custom setting only one time per a request and stores the value in a local static variable. Such
    //approach allows us to enable/disable triggers in a current request without additional DML operations. 
    public static Boolean triggersEnabled()
    {
        if (triggersEnabled == null)
        {
            String settingForTriggersValue = getStringValueByName(TRIGGERS_ENABLED);
            if (settingForTriggersValue != null)
            {
                triggersEnabled = Boolean.valueOf(settingForTriggersValue);
            }
            else
            {
                triggersEnabled = true;
            }
        }
        return triggersEnabled;
    }
    
    public static void setTriggersSettingForCurrentRequest(Boolean areTriggersEnabled)
    {
        H_C_CustomSettings.triggersEnabled = areTriggersEnabled;
    }
    
    public static String[] getIgnorableTeamRolesDuringRollup()
    {
        if (ignorableATMRolesForRollup == null)
        {
            ignorableATMRolesForRollup = new List<String>();
            
            //get value from settings
            String valueFromSetting = getStringValueByName(ATRU_IGNORABLE_TEAM_ROLES);
            if (!String.isBlank(valueFromSetting))
            {
                //parse the value and remove blank spaces
                String[] settingParts = valueFromSetting.split(SEPARATOR_OF_ROLES);
                for (String settingPart : settingParts)
                {
                    ignorableATMRolesForRollup.add(settingPart.trim());
                }
            }
        }
        return ignorableATMRolesForRollup;
    }
    
    //the method returns options that should be used by the system to roll up ATMs
    public static H_C_ATRU_Options getATRU_Options(String targetAccountRecordType)
    {
        //try to extract options from the cached map
        H_C_ATRU_Options atruOptions = mapOfATRU_Options.get(targetAccountRecordType);
        //if options don't exist in the cache then read them from settings
        if (atruOptions == null)
        {
            //read options according to record type of target accounts
            if (targetAccountRecordType == H_C_AccountRecordType.KEY_REGION_ACCOUNT)
            {
                //read necessary custom settings
                Double minimalParticipation = getDoubleValueByName(ATRU_TA_2_KA_MINIMAL_PARTICIPATION);
                AccountShare permitsForNewATMs = getAccountShareByName(ATRU_TA_2_KA_PERMITS_FOR_NEW_ATMs);
                String stringOfRolesForNewATMs = getStringValueByName(ATRU_TA_2_KA_ROLES_FOR_NEW_ATMs);
                
                //initialize options
                atruOptions = new H_C_ATRU_Options(minimalParticipation, permitsForNewATMs,
                    stringOfRolesForNewATMs);
            }
            else if (targetAccountRecordType == H_C_AccountRecordType.CONTRACT_ACCOUNT)
            {
                //read necessary custom settings
                Double minimalParticipation = getDoubleValueByName(ATRU_KA_2_CA_MINIMAL_PARTICIPATION);
                AccountShare permitsForNewATMs = getAccountShareByName(ATRU_KA_2_CA_PERMITS_FOR_NEW_ATMs);
                String stringOfRolesForNewATMs = getStringValueByName(ATRU_KA_2_CA_ROLES_FOR_NEW_ATMs);
                
                //initialize options
                atruOptions = new H_C_ATRU_Options(minimalParticipation, permitsForNewATMs,
                    stringOfRolesForNewATMs);
            }
            else
            {
                throw new H_C_Exception('H_C_CustomSettings.getATRU_Options: roll-up options '
                    + 'don`t exist for \'' + targetAccountRecordType + '\' account record type');
            }
            
            //if options were read from settings then put them into the map
            mapOfATRU_Options.put(targetAccountRecordType, atruOptions);
        }
        
        return atruOptions;
    }
    
    //the method returns options that should be used by the system to roll down ATMs
    public static H_C_ATRD_Options getATRD_Options(String targetAccountRecordType)
    {
        //try to extract options from the cached map
        H_C_ATRD_Options atrdOptions = mapOfATRD_Options.get(targetAccountRecordType);
        //if options don't exist in the cache then read them from settings
        if (atrdOptions == null)
        {
            //read options according to record type of target accounts
            if (targetAccountRecordType == H_C_AccountRecordType.KEY_REGION_ACCOUNT)
            {
                //read necessary custom settings
                Boolean isProcessEnabled = getBooleanValueByName(ATRD_PROCESS_ENABLED);
                String stringOfIgnorableRoles = getStringValueByName(ATRD_CA_2_KA_IGNORABLE_TEAM_ROLES);
                //initialize options
                atrdOptions = new H_C_ATRD_Options(isProcessEnabled, stringOfIgnorableRoles);
            }
            else if (targetAccountRecordType == H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT)
            {
                //read necessary custom settings
                Boolean isProcessEnabled = getBooleanValueByName(ATRD_PROCESS_ENABLED);
                String stringOfIgnorableRoles = getStringValueByName(ATRD_KA_2_TA_IGNORABLE_TEAM_ROLES);
                //initialize options
                atrdOptions = new H_C_ATRD_Options(isProcessEnabled, stringOfIgnorableRoles);
            }
            else
            {
                throw new H_C_Exception('H_C_CustomSettings.getATRD_Options: roll-down options '
                    + 'don`t exist for \'' + targetAccountRecordType + '\' account record type');
            }
            
            //if options were read from settings then put them into the map
            mapOfATRD_Options.put(targetAccountRecordType, atrdOptions);
        }
        
        return atrdOptions;
    }
    //
}