//
//This class is used to build SOQL-queries
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-05-2013)
public class H_C_SoqlQueryBuilder
{
    //
    //Constructors
    //
    public H_C_SoqlQueryBuilder(String selectedFields, String objectName)
    {
        this.selectedFields = selectedFields;
        this.objectName = objectName;
    }
    
    public H_C_SoqlQueryBuilder(String selectedFields, String objectName, String condition)
    {
        this.selectedFields = selectedFields;
        this.objectName = objectName;
        this.condition = condition;
    }
    // 
    
    //
    //Public properties
    //
    public String selectedFields
    {
        get;
        set;
    }
    
    public String objectName
    {
        get;
        set;
    }
    
    public String condition
    {
        get;
        set;
    }
    
    public String groupByFields
    {
        get;
        set;
    }
        
    public String orderByBlockValue
    {
        get;
        private set;
    }
    
    public Integer limitOfResultSet
    {
        get;
        set;
    }
    
    public Integer offsetOfResult
    {
        get;
        set;
    }
    
    //
    //Public methods
    //
    public void setOrderByBlock(String fieldsForSorting, H_C_SortingUtils.SortingOrder sortingOrder)
    {
        if (String.isBlank(fieldsForSorting))
        {
            this.orderByBlockValue = null;
            return;
        }
        
        this.orderByBlockValue = fieldsForSorting;
        
        if (sortingOrder != null)
        {
            if (sortingOrder == H_C_SortingUtils.SortingOrder.Ascending)
            {
                this.orderByBlockValue += ' ASC';
            }
            else if (sortingOrder == H_C_SortingUtils.SortingOrder.Descending)
            {
                this.orderByBlockValue += ' DESC';
            }
        }
    }
    
    public String buildQuery()
    {
        //check required data
        if (String.isBlank(this.selectedFields) || String.isBlank(this.objectName))
        {
            return null;
        }
        
        //create main part of the query
        String soqlQuery = 'SELECT ' + this.selectedFields + ' FROM ' + this.objectName;
        
        //add WHERE section to the query
        if (!String.isBlank(this.condition))
        {
            soqlQuery += ' WHERE ' + this.condition;
        }
        
        //NOTE: we do not need WITH section at this time
        
        //add GROUP BY section to the query
        if (!String.isBlank(this.groupByFields))
        {
            soqlQuery += ' GROUP BY ' + this.groupByFields;
        }
        
        //NOTE: we do not need HAVING section at this time
        
        //add ORDER BY block to the query
        if (!String.isBlank(this.orderByBlockValue))
        {
            soqlQuery += ' ORDER BY ' + this.orderByBlockValue;
        }
        
        //add LIMIT block to the query (Limit must be a non-negative value)
        if (this.limitOfResultSet >= 0)
        {
            soqlQuery += ' LIMIT ' + this.limitOfResultSet;
        }
        
        //add OFFSET block to the query (SOQL offset must be a non-negative value)
        if (this.offsetOfResult >= 0)
        {
            soqlQuery += ' OFFSET ' + this.offsetOfResult;
        }
        
        return soqlQuery;
    }
}