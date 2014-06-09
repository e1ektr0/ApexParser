public class Diff {
    
    public static list<Diff> getDiffs(map<Id,sObject> oldMap,map<Id,sObject> newMap){
        return getDiffMap(oldMap,newMap).values();
    }
    
    public static map<Id,Diff> getDiffMap(map<Id,sObject> oldMap,map<Id,sObject> newMap){
        map<Id,Diff> diffMap = new map<Id,Diff>();
        sObject o;
        sObject n;
        for(Id sId : newMap.keySet()){
            o = oldMap.get(sId);
            n = newMap.get(sId);
            diffMap.put(sId,new Diff(o,n));
        }
        return diffMap;
    }
    
    private Schema.sObjectType sObjType;
    private sObject oObj;
    private sObject nObj;
    
    public sObject getOldObject(){
        return oObj;
    }
    
    public sObject getNewObject(){
        return nObj;
    }
    
    public Diff(sObject oObj,sObject nObj){
        if(oObj.getSObjectType()!=nObj.getSObjectType()){
            //throw new Exception ('The SObjectType of both records must be the same.');
        } else {
            sObjType = oObj.getSObjectType();
            this.oObj = oObj;
            this.nObj = nObj;
        }
    }
    
    public Schema.sObjectType getSObjectType(){
        return sObjType;
    }
    
    public FieldDiff get(String fieldName){
        return new FieldDiff(oObj,nObj,fieldName);
    }

    public boolean isChanged(String fieldName){
        try {
            return this.get(fieldName).isChanged; 
        } catch (SObjectException e) {
            return false;
        }
    }
    
    public Id getId(){
        return this.nObj.Id;
    }
    
    public class FieldDiff{
        
        public Object oldValue {get;set;}
        public Object newValue {get;set;}
        public String field {get;set;}
        public boolean isChanged {
            get{return oldValue==null||oldValue!=newValue;}
        }
        
        public FieldDiff(sObject oObj,sObject nObj,String fieldName){
            this.field = fieldName;
            this.oldValue = oObj.get(this.field);
            this.newValue = nObj.get(this.field);
        }
    }
    
    /**
 *  Name : testDiff
 *
 *  Last Modified By : Avinash Bari <abari@innoveer.com>
 *
 *  @since   Aug 29, 2012
 */
    static testMethod void testDiff() {
    	
    	//Inserting Accounts
        Account oAcc = new Account();
        oAcc.name = 'Old Name';
        oAcc.BillingCountry='US';
        database.insert(oAcc);
        
        Account nAcc = new Account();
        nAcc.name = 'New Name';
        nAcc.BillingCountry='US';
        database.insert(nAcc);
        
        //Calling Constructor
        Diff dfs = Diff.getDiffs(new Map<Id,Account>{oAcc.Id=>oAcc},new Map<Id,Account>{oAcc.Id=>nAcc})[0];
        dfs.getOldObject();
        dfs.getNewObject();
        
        System.assertEquals(Account.sObjectType,dfs.getSObjectType());
        System.assert(dfs.isChanged('Name'));
        FieldDiff fd = dfs.get('Name');
        System.assertEquals('Old Name',(String) fd.oldValue);
        System.assertEquals('New Name',(String) fd.newValue);
        System.assertEquals(nAcc.Id,dfs.getId());
    }
   
    
}