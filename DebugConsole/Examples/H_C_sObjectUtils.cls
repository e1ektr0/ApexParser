//
//This class provides utilities for working with sObjects
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (14-05-2013)
public class H_C_sObjectUtils
{
    //
    //Public static methods
    //
    public static Object getFieldValue(sObject obj, String fieldName)
    {
        try
        {
            return obj.get(fieldName);
        }
        catch (sObjectException e)
        {
            System.debug(LoggingLevel.WARN, e);
        }
        catch (Exception e)
        {
        	//this block is added for any unexpected situation (for example,
        	//access to the field is blocked)
            System.debug(LoggingLevel.WARN, e);
        }
        return null;
    }
    
    public static Object getComplexFieldValue(sObject obj, String complexFieldName)
    {
        try
        {
        	//split complex name to parts ('split' method is based on regex, that's why we need to escape 'dot' char)
        	String[] nameParts = complexFieldName.split('\\.');
        	if (nameParts.size() > 0)
        	{
        		//in an every interation we get sObject which contains reference to another sObject
        		//or contains a necessary field (we stop before the last name part, because it should
        		//be a field, but not a reference to another sObject)
        		Integer indexOfLastPart = nameParts.size() - 1;
	        	sObject lastSelectedObject = obj;
	        	for (Integer indexOfNamePart = 0; indexOfNamePart < indexOfLastPart; indexOfNamePart++)
	        	{
	        		//get reference to another sObject (parent object)
	        		lastSelectedObject = lastSelectedObject.getSObject(nameParts[indexOfNamePart]);
	        	}
	        	
	        	if (lastSelectedObject != null)
	        	{
		        	//at this time we find a real object which contains a necessary field
		        	//(so, we try to read it)  
		            return lastSelectedObject.get(nameParts[indexOfLastPart]);
	        	}
        	}
        }
        catch (sObjectException e)
        {
            System.debug(LoggingLevel.WARN, e);
        }
        catch (Exception e)
        {
        	//this block is added for any unexpected situation (for example,
        	//access to the field is blocked)
            System.debug(LoggingLevel.WARN, e);
        }
        return null;
    }
    
    public static sObject getParentObject(sObject obj, String fieldName)
    {
        try
        {
            return obj.getSObject(fieldName);
        }
        catch (sObjectException e)
        {
            System.debug(LoggingLevel.WARN, e);
        }
        catch (Exception e)
        {
        	//this block is added for any unexpected situation (for example,
        	//access to the field is blocked)
            System.debug(LoggingLevel.WARN, e);
        }
        return null;
    }
    
    public static sObject[] getChildObjects(sObject obj, String childRelationshipName)
    {
        try
        {
            return obj.getSObjects(childRelationshipName);
        }
        catch (sObjectException e)
        {
            System.debug(LoggingLevel.WARN, e);
        }
        catch (Exception e)
        {
        	//this block is added for any unexpected situation (for example,
        	//access to the field is blocked)
            System.debug(LoggingLevel.WARN, e);
        }
        return null;
    }
    
    /*3 methods for universal approach
    public static void putFieldValue(sObject destinationObject, String destinationFieldName,
    	String newFieldValue)
    {
        try
        {
            destinationObject.put(destinationFieldName, newFieldValue);
        }
        catch (sObjectException e)
        {
            System.debug(LoggingLevel.WARN, e);
        }
        catch (Exception e)
        {
        	//this block is added for any unexpected situation (for example,
        	//access to the field is blocked)
            System.debug(LoggingLevel.WARN, e);
        }
    }
    
    public static void putFieldValue(sObject destinationObject, String destinationFieldName,
    	sObject sourceObject, String sourceFieldName)
    {
        try
        {
            destinationObject.put(destinationFieldName, sourceObject.get(sourceFieldName));
        }
        catch (sObjectException e)
        {
            System.debug(LoggingLevel.WARN, e);
        }
        catch (Exception e)
        {
        	//this block is added for any unexpected situation (for example,
        	//access to the field is blocked)
            System.debug(LoggingLevel.WARN, e);
        }
    }
    
    //this method initializes an instance of a Type which has default constructor
    public static sObject createObject(String objectName)
    {
    	//try to initialize new sObject
        sObject resultObject;
        try
        {
            Type resultType = Type.forName(objectName);
            resultObject = (sObject)resultType.newInstance();
        }
        catch (Exception e)
        {
            resultObject = null;
            System.debug(LoggingLevel.ERROR,
            	'Exception occurred in H_C_sObjectUtils.createObject: ' + e.getMessage());
        }
        
        return resultObject;
    }*/
    //
    
    
    
    
    
    //
    //Unit tests
    //
    /*@IsTest
    private static void test_putFieldValue1()
    {
    	Account sourceAccount = H_C_UnitTestUtils.constructAccount('Account Name 1');
    	Account destinationAccount = new Account();
    	
    	//wrong parameters
    	putFieldValue(null, null, null, null);
    	putFieldValue(destinationAccount, 'Name1', sourceAccount, 'Name1');
    	System.assertNotEquals(sourceAccount.Name, destinationAccount.Name);
    	
    	//correct parameters
    	putFieldValue(destinationAccount, 'Name', sourceAccount, 'Name');
    	System.assertEquals(sourceAccount.Name, destinationAccount.Name);
    }
    
    @IsTest
    private static void test_putFieldValue2()
    {
    	Account destinationAccount = new Account();
    	String newName = 'New Name 1';
    	
    	//wrong parameters
    	putFieldValue(null, null, null);
    	System.assertNotEquals(newName, destinationAccount.Name);
    	putFieldValue(destinationAccount, 'Name1', newName);
    	System.assertNotEquals(newName, destinationAccount.Name);
    	
    	//correct parameters
    	putFieldValue(destinationAccount, 'Name', newName);
    	System.assertEquals(newName, destinationAccount.Name);
    }
    
    @IsTest
    private static void test_createObject()
    {
    	//wrong parameters
    	sObject account = createObject(null);
    	account = createObject('');
    	
    	//correct parameters
    	account = createObject('Account');
    	System.assertNotEquals(null, account);
    	System.assert(account instanceof Account);
    }*/
    //
}