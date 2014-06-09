//
//This class provides utility methods for working with Type object
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-05-2013)
public class H_C_ApexTypeUtils
{
    //
    //Public static methods
    //
    public static Type getType(String typeName)
    {
        //try get Type from a class name
        Type resultType;
        try
        {
            resultType = Type.forName(typeName);
        }
        catch (Exception e)
        {
            resultType = null;
            System.debug(LoggingLevel.ERROR, 'Exception occurred in H_C_ApexTypeUtils.getType: ' + e.getMessage());
        }
        
        return resultType;
    }
    
    //this method initializes empty list of a concrete type
    public static List<Object> createEmptyListByTypeName(String typeName)
    {
        String fullNameOfListType = 'List<' + typeName + '>';
        Type listType = H_C_ApexTypeUtils.getType(fullNameOfListType);
        
        List<Object> resultList = null;
        if (listType != null)
        {
            resultList = (Object[])listType.newInstance();
        }
        
        return resultList;
    }
    //
}