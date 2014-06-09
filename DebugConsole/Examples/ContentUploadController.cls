/*
    Name - ContentUploadController 
    Description - This is the controller for publishContent Visualforce Page. 
    Developed by - Bhushan Adhikari(Innoveer Solution) on 23/07/2012
*/
//Start of Apex Controller
public with sharing class ContentUploadController 
{
        //declarations
        
        public Quote quote; 
        
        //variable for getting and setting file base64 value
        public transient blob file{get;set;}
        
        //variable for getting and setting file name
        public transient string fileName{get;set;}
    
        //variable for getting and setting Default Library Picklist Value
        public string setDefaultValue{get;set;}
    
        //List of ContentWorkspace
        public List<ContentWorkspace> cw{get;set;}
        
        // Defalult Library where all the uploaded content should be saved 
        final string LibraryName = LibraryName__c.getInstance().Library_Name__c;

        
        //This SOQL is used for getting Id of the Default Library(Haemonetics Europe)
        public ContentWorkspace WId = [SELECT Id FROM ContentWorkspace WHERE Name=:LibraryName];
    
        //Constructor
        public ContentUploadController (ApexPages.StandardController controller)
        {
                 //this sets the default Library picklist value
                 setDefaultValue=WId.Id;
         
                 quote=[SELECT Id FROM Quote WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
         
                 //PrePopulating Quote lookup field
                 contentVersion.Quote__c = quote.Id;
                 
         }
    
    
         //Creating a getter method for getting Librareis from database and displaying as Library picklist values in Visualforce page
        public List<selectOption> getlib()
        {   
                //new list for holding all of the picklist options 
                List<selectOption> options = new List<selectOption>(); 
                for(ContentWorkspace cw: [SELECT Id, Name FROM ContentWorkspace])
                { 
                    //for all records found - add them to the Library picklist options
                    options.add(new selectOption(cw.Id, cw.Name)); 
                }
                //return the picklist options
            return options; 
         }
         
        //getter setter method for contentVersion 
        public ContentVersion contentversion
        {
              get
              {
                if (contentversion == null)
                contentversion = new contentversion ();
                return contentversion ;
              }
              set;
        }
  
        //This function is being called from Upload Button on click event for uploading a file to content  
        public PageReference upload()
        { 
               
                //Passing file Title
                contentversion.Title = fileName;
            
                //Setting current user as the content owner
                contentversion.OwnerId = UserInfo.getUserId(); 
            
                //setting the File Path
                contentversion.PathOnClient =contentVersion.Title; 
            
                //setting content versionData
                contentversion.versiondata = file;

                //WorkspaceId (Library) where the file should be uploded
                contentversion.FirstPublishLocationId=setDefaultValue;

                //Associating Quote to particular content being uploaded
                contentversion.Quote__c =contentVersion.Quote__c;
    
                try
                {   
                    //Inserting the content
                    insert contentversion ;
                    PageReference GotoQuotePage= new PageReference('/'+quote.id);
                    GotoQuotePage.setRedirect(true);
                    return GotoQuotePage;
            
                } 
                
                //this catch is used for handling any exceptions occured during content insert
                catch (DMLException e)
                {
                    //Displaying Error message in case any exception occurs during file upload 
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File Uploading failed'));
                    system.debug('Error'+e);
                }
                
                //this creates a new instance of contentVersion which will be used for new file upload process 
                finally 
                {  
                    //clearing the view state
                    file = null;
                    //creating new contentversion
                    contentversion = new contentversion (); 
                }
                
                //Returning to current visualforce page
                return null;
               
        }
        
        public PageReference cancelGoBack()
        { 
            PageReference GotoQuotePage= new PageReference('/'+quote.id);
            GotoQuotePage.setRedirect(true);
            return GotoQuotePage;
        }
}//End Of Apex Controller