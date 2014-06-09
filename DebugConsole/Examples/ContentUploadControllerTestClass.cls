/*
    Name - ContentUploadControllerTestClass
    Description - This test class is used to test the publishcontent visualforce page controller "ContentUploadController" class, which uploads file to content library.
    Developed by - Bhushan Adhikari(Innoveer Solution) on 23/07/2012
*/

@istest(seeAllData=false)
public class ContentUploadControllerTestClass
{
    //testmethod that test successfull file upload to content
    public static testmethod void testContent_upload()
    {   
           
           //creating binary value for test document body
            Blob docBody = Blob.valueof('TestDocument');
            
            //creating a test document
            Document testDoc = new Document(Name = 'TestDocument', Body = docBody , FolderId = [SELECT Id FROM Folder WHERE Type = 'Document' LIMIT 1].id);
            insert testDoc;
            
            //getting the recordtypeId 
            Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> rtMap = d.getRecordTypeInfosByName();
            Id rtProspectId =  rtMap.get('Prospect Account').getRecordTypeId(); 
                
            //Creating a test Account    
            Account testAccount = new Account (Name='TestAccount' , 
                                               RecordTypeId = rtProspectId , 
                                               Division__c = 'Donor',
                                               BillingStreet='St One',
                                               BillingState='Oval',
                                               BillingCountry='UK');
            insert testAccount;
            
            //Creating test Opportunity
            Opportunity Opp = new Opportunity(Name='Test Opportunity' ,
                                              AccountId = testAccount.Id, 
                                              CloseDate = date.today()+5,
                                              StageName = 'Targeting');
            insert opp;
            
            //creating test Quote to which content will be attached
            Quote Q  =  new Quote(Name = 'TestQuote' ,
                                  OpportunityId = Opp.Id ,
                                  Contract_Type__c ='Rental',
                                  Duration_yrs__c ='1',
                                  Quote_Reason__c = 'New Customer',
                                  Technical_Service__c = 'Yes');
            insert Q;                      
        
            //getting contentWorkspaceId(Library Id)
            String libraryName = 'Haemonetics Europe';// Defalult Library where all the uploaded content will be saved
            //ContentWorkspace WId = [SELECT Id FROM ContentWorkspace WHERE Name=:libraryName];
      
       
           //create a reference to the Visualforce page
            PageReference testPage = Page.publishContent;
            Test.setCurrentPage(testPage);
                
            //populate the Visualforce page with the Id of the Quote from above
            ApexPages.currentPage().getParameters().put('id', Q.Id);
        
            //create an instance of the controller extension
            ApexPages.StandardController sc = new ApexPages.standardController(Q);
            /*
            ContentUploadController con = new ContentUploadController(sc);
            
            //call the method for populuating the picklist
            List<selectOption> Library = con.getlib();
        
            //testing for Successfull file upload by passing required parameters
            con.file = testDoc.body;
            con.fileName = testDoc.name;
            //con.setDefaultValue = WId.id;
            
            //calling the upload finction that is being called by "Upload" button on VF page
            con.upload();
            
            List<contentVersion> cv = [SELECT Id, Quote__c FROM contentVersion WHERE Quote__c =: Q.id];        
            system.debug('***********Content' + cv);
            //as we have uploaded one content document, there should be only one content  attached to Quote Q
            system.assertEquals(1,cv.Size());
            */
     }
     
     //testmethod that will test for error condition
     public static testmethod void testContent_error()
     {    
                
            //creating binary value for test document body
            Blob docBody = Blob.valueof('TestDocument');
            
            //creating a test document
            Document testDoc = new Document(Name = 'TestDocument', Body = docBody , FolderId = [SELECT Id FROM Folder WHERE Type = 'Document' LIMIT 1].id);
            insert testDoc;
            
            //getting the recordtypeId 
            Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> rtMap = d.getRecordTypeInfosByName();
            Id rtProspectId =  rtMap.get('Prospect Account').getRecordTypeId(); 
                
            //Creating a test Account    
            Account testAccount = new Account (Name='TestAccount' , 
                                               RecordTypeId = rtProspectId , 
                                               Division__c = 'Donor',
                                               BillingStreet='St One',
                                               BillingState='Oval',
                                               BillingCountry='UK');
            insert testAccount;
            
            //Creating test Opportunity
            Opportunity Opp = new Opportunity(Name='Test Opportunity' ,
                                              AccountId = testAccount.Id, 
                                              CloseDate = date.today()+5,
                                              StageName = 'Targeting');
            insert opp;
            
            //creating test Quote
            Quote Q  =  new Quote(Name = 'TestQuote' ,
                                  OpportunityId = Opp.Id ,
                                  Contract_Type__c ='Rental',
                                  Duration_yrs__c ='1',
                                  Quote_Reason__c = 'New Customer',
                                  Technical_Service__c = 'Yes');
            insert Q;                     
        
            //getting contentWorkspaceId(Library Id)
            String libraryName = 'Haemonetics Europe';// Defalult Library where all the uploaded content should get saved
            
            ContentWorkspace WId = null;
            ContentWorkspace[] WIds = [SELECT Id FROM ContentWorkspace WHERE Name=:libraryName];
            
            if(WIds.size() > 0) {
            	WId = WIds[0];
            }
      
           //create a reference to the Visualforce page
            PageReference testPage = Page.publishContent;
            Test.setCurrentPage(testPage);
                
            //populate the Visualforce page with the Id of the Quote from above
            ApexPages.currentPage().getParameters().put('id', Q.Id);
        
            //create an instance of the controller extension
            ApexPages.StandardController sc = new ApexPages.standardController(Q);
            /*
            ContentUploadController con = new ContentUploadController(sc);
            
            //call the method for populuating the picklist
            List<selectOption> Library = con.getlib();
                            
            //testing for error in file upload by not passing the file
            con.file = null;
            con.fileName = null;
            con.setDefaultValue = WId.id;
            //calling the upload finction that is being called by "Upload" button on VF page
            con.upload();
            
            
            List<Apexpages.Message> msgs1 = ApexPages.getMessages();
            Boolean c = False;
            system.debug('****Msg1 ' + msgs1);
            
            //As there was no file provided , it should throw an error in uploading file
            for(Apexpages.Message msg1: msgs1)
            {
                    
                    if (msg1.getDetail().contains('File Uploading failed')) c = True;
                    msg1 = null;
            }
            //checking that we got the appropriate error message in file uploading 
            system.assert(c);
            
            con.cancelGoBack();
            */
      }
}