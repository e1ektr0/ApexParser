//
//This class provides utility methods for working with SOQL
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-05-2013)
public class H_C_SoqlUtils
{
    //
    //Data types
    //
    //This enumeration contains logic operators which are used in SOQL-queries
    public enum LogicOperator
    {
        AND_Operator,
        OR_Operator
    }
    
    //This enumeration contains all DML operations
    public enum DmlOperation
    {
        Deleting,
        Inserting,
        Updating,
        Undeleting,
        Upserting
    }
    
    public interface IQueryCreator
    {
    	String createQuery();
    }
    //
    
    //
    //Constants
    //
    public static final List<String> SPECIAL_CHARS_FOR_LIKE_OPERATOR = new String[] {'%', '_', '\''};
    //
        
    //
    //Private static methods
    //
    private static String createSeparatorForConditions(LogicOperator logicOperator)
    {
        if (logicOperator == H_C_SoqlUtils.LogicOperator.AND_Operator)
        {
            return ' AND ';
        }
        else if (logicOperator == H_C_SoqlUtils.LogicOperator.OR_Operator)
        {
            return ' OR ';
        }
        else
        {
            return null;
        }
    }
    
    //method performs DML operation for sObject-list
    private static void callDmlOperation(DmlOperation dmlOperation, sObject[] objects)
    {
        if (dmlOperation == H_C_SoqlUtils.DmlOperation.Updating)
        {
            update objects;
        }
        else if (dmlOperation == H_C_SoqlUtils.DmlOperation.Inserting)
        {
            insert objects;
        }
        else if (dmlOperation == H_C_SoqlUtils.DmlOperation.Deleting)
        {
            delete objects;
        }
        else if (dmlOperation == H_C_SoqlUtils.DmlOperation.Upserting)
        {
            upsert objects;
        }
        else if (dmlOperation == H_C_SoqlUtils.DmlOperation.Undeleting)
        {
            undelete objects;
        }
        else
        {
            throw new NullPointerException();
        }
    }
    
    //method performs DML operation for sObject-list with specific DML options. Note that
    //it returns an array of results which is returned by an every DML operation:
    //- Database.SaveResult[] - for insert and update operations
    //- Database.DeleteResult[] - for delete operation
    //- Database.UpsertResult[] - for upsert operation (as for now, the method doesn't return
    //the result for this operation)
    //- Database.UndeleteResult[] - for undelete operation
    private static Object[] callDmlOperation(DmlOperation dmlOperation, sObject[] objects,
    	Database.DmlOptions dmlOptions)
    {
        if (dmlOperation == H_C_SoqlUtils.DmlOperation.Updating)
        {
            return Database.update(objects, dmlOptions);
        }
        else if (dmlOperation == H_C_SoqlUtils.DmlOperation.Inserting)
        {
            return Database.insert(objects, dmlOptions);
        }
        else if (dmlOperation == H_C_SoqlUtils.DmlOperation.Deleting)
        {
        	//delete operation supports only a single setting (boolean flag)
            return Database.delete(objects, dmlOptions.optAllOrNone);
        }
        else if (dmlOperation == H_C_SoqlUtils.DmlOperation.Upserting)
        {
        	//#IMPORTANT: it was supposed to use Database.upsert method, but this method
        	//doesn't work with an array of sObjects unlike single upsert operation. That's
        	//why this method doesn't return real array of Database.UpsertResult[]
            //upsert operation supports 2 settings:
            //- especial setting for an external Id which is not used at this moment
            //- boolean flag (like, all other operations)
            //return Database.upsert(objects, null, dmlOptions.optAllOrNone);
            upsert objects;
            return null;
        }
        else if (dmlOperation == H_C_SoqlUtils.DmlOperation.Undeleting)
        {
            //undelete operation supports only a single setting (boolean flag)
            return Database.undelete(objects, dmlOptions.optAllOrNone);
        }
        else
        {
            throw new NullPointerException();
        }
    }
    //
    
    //
    //Public static methods
    //
    //
    //the following 2 methods perform DML operations safely for usual cases, because they
    //catch all catchable exceptions
    //
    public static Boolean tryPerformDmlOperation(DmlOperation dmlOperation, sObject objectForOperation)
    {
        //we can't use calls like this
        //'return tryPerformDmlOperation(dmlOperation, new sObject[] {objectForOperation}, parameters);'
        //here, because 'DML on generic List<SObject> only allowed for insert, update or delete operations'.
        //So non-standard dml operations (upsert, undelete) can be called only for a single object or
        //for a list which contains objects of a concrete type. That's why we'll create empty array of
        //the same type as 'objectForOperation' 
        
        //1 STEP: check input parameters
        //we can't perform DML operation if some parameters are not correct 
        if (dmlOperation == null || objectForOperation == null)
        {
            return false;
        }
        
        List<sObject> sObjects = (sObject[])H_C_ApexTypeUtils.createEmptyListByTypeName(
            String.valueOf(objectForOperation.getSObjectType()));
        sObjects.add(objectForOperation);
        return tryPerformDmlOperation(dmlOperation, sObjects);
    }
    
    //NOTE: the following method processes standard and non-standard DML operations. All DML operations
    //can be performed for a list of objects, but it is important to know that non-standard DML
    //operations (upsert and undelete) can be performed only for lists which contain objects of
    //a concrete type. If you try to instantiate sObject-list in a code and then call
    //the method below for this list then System.TypeException will occur and you'll get false result.
    //THE FIRST WAY TO AVOID this problem is that you should use only lists which contain objects of
    //a concrete type when you want to perform an upsert or undelete operation.
    //ANOTHER WAY is to call these operations in for-loop for an every single object (this way is bad
    //because of the limit 'Total number of DML statements issued = 150', every DML statement
    //(for list or for single object) counts against the number of allowed DML queries. So it is more
    //effective to use the FIRST WAY).
    public static Boolean tryPerformDmlOperation(DmlOperation dmlOperation, sObject[] objects)
    {
        //1 STEP: check input parameters
        //we can't perform DML operation if some parameters are not correct 
        if (dmlOperation == null || objects == null)
        {
            return false;
        }
        
        //2 STEP: perform DML operation
        Boolean isOperationSuccessful = true;
        try
        {
            //simply call DML operation
            callDmlOperation(dmlOperation, objects);
        }
        catch (System.Exception e)
        {
            System.debug(LoggingLevel.ERROR, e);
            isOperationSuccessful = false;
        }
        
        return isOperationSuccessful;
    }
    
    public static H_C_OperationResults performDmlOperation(DmlOperation dmlOperation,
    	sObject[] objects, Database.DmlOptions dmlOptions)
    {
        //1 STEP: check input parameters
        //we can't perform DML operation if some parameters are not correct 
        if (dmlOperation == null || objects == null || dmlOptions == null)
        {
            return new H_C_OperationResults(false);
        }
        
        //2 STEP: perform DML operation
        H_C_OperationResults operationResults;
        try
        {
            //call DML operation
            Object[] dmlResults = callDmlOperation(dmlOperation, objects, dmlOptions);
            //fill the container with results
            operationResults = new H_C_OperationResults(true);
            if (dmlResults != null)
            {
            	operationResults.results = dmlResults;
            }
        }
        catch (System.Exception e)
        {
            System.debug(LoggingLevel.ERROR, e);
            //fill the container with results
            operationResults = new H_C_OperationResults(false);
            operationResults.exceptions.add(e);
        }
        
        return operationResults;
    }
    
    //this method perform DML operations absolutely safely, because it catches even
    //uncatchable exceptions (like System.LimitException)
    public static H_C_OperationResults performSafeDmlOperation(DmlOperation dmlOperation,
    	sObject[] objects)
    {
    	//make an assumption that the operation will not be successful 
    	H_C_OperationResults results = new H_C_OperationResults(false);
    	if (objects != null)
    	{
	    	//STEP #1: check potential problems with limits
	    	//make an assumption that the operation is possible
	    	Boolean isDmlOperationPossible = true;
	    	
	    	//check that the limit for allowed DML statements is not reached yet
	    	if (H_C_SFLimits.getNumberOfAllowedDMLStatements() == 0)
	    	{
	    		isDmlOperationPossible = false;
	    		results.errors.add(H_C_OperationResults.ErrorType.DMLStatementsLimitExceeded);
	    	}
	    	
	    	//check that number of allowed DML rows is not less than number of passed objects
	    	if (objects.size() > H_C_SFLimits.getNumberOfAllowedDMLRows())
	    	{
	    		isDmlOperationPossible = false;
	    		results.errors.add(H_C_OperationResults.ErrorType.DMLRowsLimitExceeded);
	    	}
	    	
	    	//STEP #2: if DML operation is still possible then call it
	    	if (isDmlOperationPossible)
	    	{
	    		//perform DML operation and save the boolean status into the final results  
	    		results.isOperationSuccessful = tryPerformDmlOperation(dmlOperation, objects);
	    	}
    	}
    	
    	return results;
    }
    //
    
    
    //method simply performs query but catches all possible problems and exceptions
    public static List<sObject> performQuery(String soqlCommand)
    {
        //check input parameters
        if (String.isBlank(soqlCommand))
        {
            return null;
        }
        
        List<sObject> listOfObjects;
        try
        {
            listOfObjects = Database.query(soqlCommand);
        }
        catch (System.QueryException e)
        {
            System.debug(Logginglevel.ERROR, e);
            listOfObjects = null;
        }
        
        return listOfObjects;
    }
    
    //method simply performs query but catches all possible problems and exceptions and returns single object  
    public static sObject performSingleResultQuery(String soqlCommand)
    {
        sObject resultObject = null;
        
        List<sObject> listOfsObjects = performQuery(soqlCommand);
        if (listOfsObjects != null && listOfsObjects.size() > 0)
        {
            resultObject = listOfsObjects[0];
        }
        
        return resultObject;
    }
    
    public static List<sObject> performQuery(H_C_SoqlQueryBuilder queryBuilder)
    {       
        if (queryBuilder == null)
        {
            return null;
        }
        
        return performQuery(queryBuilder.buildQuery());
    }
    
    public static sObject performSingleResultQuery(H_C_SoqlQueryBuilder queryBuilder)
    {       
        if (queryBuilder == null)
        {
            return null;
        }
        
        return performSingleResultQuery(queryBuilder.buildQuery());
    }
    
    public static Database.QueryLocator createQueryLocator(String queryString)
    {
    	if (String.isBlank(queryString))
    	{
    		return null;
    	}
    	
    	Database.QueryLocator queryLocator;
    	try
    	{
    		queryLocator = Database.getQueryLocator(queryString);
    	}
    	catch (System.QueryException e)
        {
            System.debug(Logginglevel.ERROR, e);
            queryLocator = null;
        }
        return queryLocator;
    }
    
    public static Database.QueryLocator createEmptyQueryLocator()
    {
    	//initialize a query locator which doesn't return objects
        return createQueryLocator('SELECT Id FROM Account LIMIT 0');
    }
    //
    
    //
    //Public static service methods
    //
    //method returns string with escaped special SOQL chars 
    public static String escapeSpecialCharsForLikeOperator(String sourceString)
    {
        if (sourceString == null)
        {
            return null;
        }
        
        String resultString = sourceString;
        for (String specialChar : SPECIAL_CHARS_FOR_LIKE_OPERATOR)
        {
            resultString = resultString.replace(specialChar, '\\' + specialChar);
        }
        return resultString;
    }
    
    public static String escapeSpecialCharsForSimpleCondition(String sourceString)
    {
        if (sourceString == null)
        {
            return null;
        }
        
        return String.escapeSingleQuotes(sourceString);
    }
    
    public static String joinConditions(List<String> listOfConditions, LogicOperator logicOperator)
    {
        //check input parameters
        if (listOfConditions == null || logicOperator == null)
        {
            return null;
        }
        
        //result condition
        String fullCondition = null;
        
        String separatorForConditions = createSeparatorForConditions(logicOperator);
        //if type of an operator is unknown then the method couldn't create a separator for it
        if (!String.isBlank(separatorForConditions))
        {
            Boolean conditionExpressionCreated = false;
            for (String condition : listOfConditions)
            {
                if (!String.isBlank(condition))
                {
                    if(conditionExpressionCreated)
                    {
                        fullCondition += separatorForConditions;
                    }
                    else
                    {
                        fullCondition = '';
                        conditionExpressionCreated = true;
                    }
                    fullCondition += '(' + condition + ')';
                }
            }
        }
        
        return fullCondition;
    }
    
    public static String joinStringsForINSection(List<String> listOfStrings)
    {
        //check input parameters
        if (listOfStrings == null)
        {
            return null;
        }
        
        Set<String> setOfStrings = new Set<String>(listOfStrings);
        //remove null and empty strings, because they are not useful for IN-conditions
        setOfStrings.remove(null);
        setOfStrings.remove('');
        
        String resultString = null;
        if (setOfStrings.size() > 0)
        {
	        resultString = String.join(new List<String>(setOfStrings), '\',\'');
	        //if result string contains chars then we should wrap it by quotes, because
	        //they were not added by join-function
	        if (String.isNotBlank(resultString))
	        {
	        	resultString = '\'' + resultString + '\'';
	        }
        }
        
        return resultString;
    }
    
    //this method formats date from Date object and set start time of the day
    public static String formatDateTime(Date sourceDate)
    {
        //check input parameters
        if (sourceDate == null)
        {
            return null;
        }
        
        Datetime sourceDateTime = 
            DateTime.newInstanceGmt(sourceDate.year(), sourceDate.month(), sourceDate.day(), 0, 0, 0);
        return formatDateTime(sourceDateTime);
    }
    
    //this method formats date and time from DateTime object
    public static String formatDateTime(DateTime sourceDateTime)
    {
        //check input parameters
        if (sourceDateTime == null)
        {
            return null;
        }
        
        return sourceDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }
    
    //this method formats date from Date object
    public static String formatDate(Date sourceDate)
    {
        //check input parameters
        if (sourceDate == null)
        {
            return null;
        }
        Datetime sourceDateTime = 
            DateTime.newInstance(sourceDate.year(), sourceDate.month(), sourceDate.day(), 0, 0, 0);
        return formatDate(sourceDateTime);
    }
    
    //this method formats date from DateTime object
    public static String formatDate(DateTime sourceDateTime)
    {
        //check input parameters
        if (sourceDateTime == null)
        {
            return null;
        }
        
        return sourceDateTime.format('yyyy-MM-dd');
    }
    //
    
    
    
    
    
    //
    //Private Unit tests (I wanted to use @TestVisible annotation for private methods and
    //test them in a separate class, but this annotation is still not supported by IDE
    //and breaks Outline window)
    //
    @IsTest
    private static void testSoqlUtils_privateMethods()
    {
    	//This method tests unusual cases in private methods:
    	//1) test createSeparatorForConditions
        System.assertEquals(null, H_C_SoqlUtils.createSeparatorForConditions(null));
        
        //2) test callDmlOperation with 2 parameters
        try
        {
            H_C_SoqlUtils.callDmlOperation(null, new sObject[0]);
            System.assert(false);
        }
        catch (Exception e)
        {
            System.assert(true);
        }
        
        //2) test callDmlOperation with 3 parameters
        try
        {
            H_C_SoqlUtils.callDmlOperation(null, new sObject[0], new Database.DmlOptions());
            System.assert(false);
        }
        catch (Exception e)
        {
            System.assert(true);
        }
    }
    //
}