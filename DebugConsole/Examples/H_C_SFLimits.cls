//
//This class contains some methods which return information about the limits
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (31-05-2013)
public class H_C_SFLimits
{
	//
	//Public static methods
	//
	
	//method returns number of rows that can participate in DML operations for the current transaction
	public static Integer getNumberOfAllowedDMLRows()
	{
		return Limits.getLimitDMLRows() - Limits.getDmlRows();
	}
	
	//method returns number of rows that can participate in DML operations for the current transaction
	public static Integer getNumberOfAllowedDMLStatements()
	{
		return Limits.getLimitDmlStatements() - Limits.getDmlStatements();
	}
	//
}