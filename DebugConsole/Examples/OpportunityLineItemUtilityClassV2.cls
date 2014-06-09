/**
 *  Name - OpportunityLineItemUtilityClassV2
 *
 *  Description -This is a utility class for OpporutnityLineItem CreateMonthlyRevenue Trigger. 
 *
 *  @author  Abhijeet Baneka <abaneka@innoveer.com>
 *  @since   Aug 21, 2012
 *
 *  Last Modified By    Avinash Bari<abari@innoveer.com>
 *  @since              Oct 15,2012
 *  Description         Added the function CalMonthlyRevDisp for calcualting the Monthly revenue for 
                        those oli having product type as Disposable.
                        
 *  Modified By    		Satarupa Roy <satarupa@cloudsherpas.com>
 *  @since              Jul,2013
 *  Description         Modified the Monthly Revenue logic for Pipeline and Existing disposables to 
 						handle proportional seggregation of Revenue and Quantity for the period in a FY.
 						
 					  
 */
public without sharing class OpportunityLineItemUtilityClassV2{

    public static void init(list<OpportunitylineItem> olifromBatch){
        
        //Declarations
        set<String> prodLinesPipDisp = new set<String>();
        set<String> prodTypePipDisp= new set<String>();
        set<String> ManagementUnitSetPipDisp= new set<String>();
        set<id> OppOwnerIdsSetPipDisp = new set<id>();
        set<String> BusinessUnitsetPipDisp= new set<String>();
        set<String> OperatingUnitsetPipDisp= new set<String>();
        
        set<String> prodLinesPipEquip = new set<String>();
        set<String> prodTypePipEquip= new set<String>();
        
        //Declarations
        set<String> prodLinesExistDisp = new set<String>();
        set<String> prodTypeExistDisp= new set<String>();
        set<String> ManagementUnitSetExistDisp= new set<String>();
        set<id> OppOwnerIdsSetExistDisp = new set<id>();
        set<String> BusinessUnitsetExistDisp= new set<String>();
        set<String> OperatingUnitsetExistDisp= new set<String>();
        
        set<String> prodLinesExistEquip = new set<String>();
        set<String> prodTypeExistEquip= new set<String>();
        
        set<Date> closeDateSet = new set<Date>();
        set <FiscalYearSettings> FYSET = new set<FiscalYearSettings>();
        set<AOP__c> AOPforPipelineDisp;
        set<AOP__c> AOPforPipelineEquip;
        set<AOP__c> AOPforExistDisp;
        set<AOP__c> AOPforExistEquip;
        
        list<Monthly_Revenue__c> InsertNewMR = new list<Monthly_Revenue__c>();
       
        //get the ID's of Recordtype 'Pipeline' and 'Existing'
        Schema.DescribeSObjectResult dopp = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> opprtMapByName = dopp.getRecordTypeInfosByName();
        String PIPELINERECORDTYPEID= opprtMapByName.get('Pipeline').getRecordTypeId();
        String EXISTINGRECORDTYPEID= opprtMapByName.get('Existing').getRecordTypeId();
        final String DISPOSABLE = 'Disposable';
        final String EQUIPMENT = 'Equipment';
        list<OpportunityLineItem> oliForPipelineDisposable = new list<OpportunityLineItem>();
        list<OpportunityLineItem> oliForPipelineEquipment = new list<OpportunityLineItem>();
        list<OpportunityLineItem> oliForExistingDisposable = new list<OpportunityLineItem>();
        list<OpportunityLineItem> oliForExistingEquipment = new list<OpportunityLineItem>();
        list<Monthly_Revenue__c> calPipelineEquipmentResult = new list<Monthly_Revenue__c>();
		Set<Id>SetMrToDel = new Set<Id>(); // added by Satarupa Roy
        map<id, list<Period>> FYPeriod = new map<id, list<Period>>();
        
        //setup the required filter values.
        for(OpportunityLineItem oli :olifromBatch){    	
            closeDateSet.add(oli.Opportunity.closedate);
            if(oli.Create_Monthy_Revenue_Flag__c)
					SetMrToDel.add(oli.id);
            //get OLI for Pipeline and Product type = Disposable
            
            if(oli.Opportunity.RecordTypeId == PIPELINERECORDTYPEID && oli.Product_Type_Formula__c == DISPOSABLE){
                prodLinesPipDisp.add(oli.Product_Line_Formula__c);
                prodTypePipDisp.add(oli.Product_Type_Formula__c);
                ManagementUnitSetPipDisp.add(oli.Opportunity.Management_Unit__c);
                OppOwnerIdsSetPipDisp.add(oli.Opportunity.Owner.Id);
                OperatingUnitsetPipDisp.add(oli.Opportunity.Operating_Unit__c);
                BusinessUnitsetPipDisp.add(oli.Opportunity.Business_Unit__c);
                oliForPipelineDisposable.add(oli);

            } 
            
            //get OLI for Pipeline and Product type = Equipment
            if(oli.Opportunity.RecordTypeId == PIPELINERECORDTYPEID && oli.Product_Type_Formula__c == EQUIPMENT){
                prodLinesPipEquip.add(oli.Product_Line_Formula__c);
                prodTypePipEquip.add(oli.Product_Type_Formula__c);
                oliForPipelineEquipment.add(oli);
            } 
            
            //get OLI for Existing and Product type = Disposable
            if(oli.Opportunity.RecordTypeId == EXISTINGRECORDTYPEID && oli.Product_Type_Formula__c == DISPOSABLE){
        
                prodLinesExistDisp.add(oli.Product_Line_Formula__c);
			    prodTypeExistDisp.add(oli.Product_Type_Formula__c);
                ManagementUnitSetExistDisp.add(oli.Opportunity.Management_Unit__c);
                OppOwnerIdsSetExistDisp.add(oli.Opportunity.Owner.Id);
                OperatingUnitsetExistDisp.add(oli.Opportunity.Operating_Unit__c);
                BusinessUnitsetExistDisp.add(oli.Opportunity.Business_Unit__c);
                oliForExistingDisposable.add(oli);
     
            } 
            
            //get OLI for Existing and Product type = Equipment
            if(oli.Opportunity.RecordTypeId == EXISTINGRECORDTYPEID && oli.Product_Type_Formula__c == EQUIPMENT){
                prodLinesExistEquip.add(oli.Product_Line_Formula__c);
                prodTypeExistEquip.add(oli.Product_Type_Formula__c);
                oliForExistingEquipment.add(oli);
            }
        }
        
        //get the fiscal year we consider for calculation.
        for(FiscalYearSettings FYS :[Select f.StartDate, f.Id, f.EndDate,f.Name,(Select Id, FiscalYearSettingsId,FiscalYearSettings.Name, Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number From Periods where Type=:'Month' ORDER BY StartDate ASC) From FiscalYearSettings f]){
            for(Date dt : closeDateSet){
                if( dt >= FYS.StartDate && dt <= FYS.EndDate){
                    FYSET.add(FYS);
                }
            }
        }
        
        for(FiscalYearSettings FYS :FYSET){
          //creating map of FiscalYearSetting id and list of Periods Map.
            if(!FYS.Periods.isEmpty()){
                for(Period prd : FYS.Periods){
                   if(FYPeriod.containskey(prd.FiscalYearSettingsId)){
                       FYPeriod.get(prd.FiscalYearSettingsId).add(prd);
                   }else{
                       FYPeriod.put(prd.FiscalYearSettingsId,new list<Period>{prd});
                   }  
                }
            }
        }

         AOPforPipelineDisp = new set<AOP__c>([SELECT id,Sales_Rep__c,Fiscal_Year__c,Fiscal_Month__c,Fiscal_Period__c,Product_Line__c,Product_Type__c,Management_Unit__c,Business_Unit__c,Operating_Unit__c FROM 
                                                                                        AOP__c
                        WHERE Sales_Rep__c!=NULL AND Sales_Rep__c IN: OppOwnerIdsSetPipDisp AND Product_Line__c IN: prodLinesPipDisp AND Product_type__c IN: prodTypePipDisp AND  Management_Unit__c IN: ManagementUnitSetPipDisp AND Operating_Unit__c IN: OperatingUnitsetPipDisp AND Business_Unit__c IN: BusinessUnitsetPipDisp]);
                  
		
        AOPforPipelineEquip= new set<AOP__c>([SELECT id,Sales_Rep__c,Fiscal_Year__c,Fiscal_Month__c,Fiscal_Period__c,Product_Line__c,Product_Type__c,Management_Unit__c,Business_Unit__c,Operating_Unit__c FROM 
                                                                                        AOP__c
                                                                                         WHERE Sales_Rep__c!=NULL AND Product_Line__c IN: prodLinesPipEquip AND Product_type__c IN: prodTypePipEquip ]);
	   		
        AOPforExistDisp= new set<AOP__c>([SELECT id,Sales_Rep__c,Fiscal_Year__c,Fiscal_Month__c,Fiscal_Period__c,Product_Line__c,Product_Type__c,Management_Unit__c,Business_Unit__c,Operating_Unit__c FROM 
                                                                                        AOP__c
                                                                                         WHERE Sales_Rep__c!=NULL AND Sales_Rep__c IN: OppOwnerIdsSetExistDisp AND Product_Line__c IN: prodLinesExistDisp AND Product_type__c IN: prodTypeExistDisp AND  Management_Unit__c IN: ManagementUnitSetExistDisp AND Operating_Unit__c IN: OperatingUnitsetExistDisp AND Business_Unit__c IN: BusinessUnitsetExistDisp]);

    		
        AOPforExistEquip= new set<AOP__c>([SELECT id,Sales_Rep__c,Fiscal_Year__c,Fiscal_Month__c,Fiscal_Period__c,Product_Line__c,Product_Type__c,Management_Unit__c,Business_Unit__c,Operating_Unit__c FROM 
                                                                                        AOP__c
                                                                                         WHERE Sales_Rep__c!=NULL AND Product_Line__c IN: prodLinesExistEquip AND Product_type__c IN: prodTypeExistEquip]);

        
        system.debug('Resulting AOP : '+AOPforPipelineEquip.size());
        
        //CALCULATIONS START HERE
        //1. For Pipeline Opportunities and Disposables type of products
        if(!oliForPipelineDisposable.isEmpty() && !AOPforPipelineDisp.isEmpty() && AOPforPipelineDisp !=null){
            list<Monthly_Revenue__c> calPipelineDisposableResult = calcPipeLineDispMR(oliForPipelineDisposable , AOPforPipelineDisp, FYSET , FYPeriod);
            if(calPipelineDisposableResult != null){
                InsertNewMR.addall(calPipelineDisposableResult);
            }
        }
        
        //2. For Pipeline Opportunities and Equipment type of products
        if(!oliForPipelineEquipment.isEmpty() && !AOPforPipelineEquip.isEmpty() && AOPforPipelineEquip != null){
            calPipelineEquipmentResult = calcPipeLineEquipMR(oliForPipelineEquipment, AOPforPipelineEquip, FYSET, FYPeriod);
            if(calPipelineEquipmentResult != null ){
                InsertNewMR.addall(calPipelineEquipmentResult );
            }
        }
        
        //3. For Existing Opportunities and Disposables type of products
        if(!oliForExistingDisposable.isEmpty() && !AOPforExistDisp.isEmpty() && AOPforExistDisp !=null){
            list<Monthly_Revenue__c> calExistingDisposableResult = calcExistingDispMR(oliForExistingDisposable, AOPforExistDisp, FYSET, FYPeriod);
            if(calExistingDisposableResult != null){
                InsertNewMR.addall(calExistingDisposableResult);
            }
        }
        
        //4. For Existing Opportunities and Equipment type of products
        if(!oliForExistingEquipment.isEmpty() && !AOPforExistEquip.isEmpty() && AOPforExistEquip!=null){
            list<Monthly_Revenue__c> calExistingEquipmentResult = calcExistingEquipMR(oliForExistingEquipment, AOPforExistEquip, FYSET, FYPeriod);
            if(calExistingEquipmentResult != null){
                InsertNewMR.addall(calExistingEquipmentResult);
            }
        }
		// added by Satarupa Roy on 30th July 2013 
        if(!SetMrToDel.isEmpty() && SetMrToDel!=null){
                //get the Monthly revenues to delete. 
                list<Monthly_Revenue__c> delMR = [Select id,Opportunity_Product__c from Monthly_Revenue__c where Opportunity_Product__c IN: SetMrToDel];
                
                if(!delMR.isEmpty()){
                    delete delMR; 
                }   
             }
		// code by Satarupa end //
        
		//Insert Newly Created Monthly Revenues. 
        if(!InsertNewMR.isEmpty()){
            insert InsertNewMR;
        }
     }
     
     //Method : To create Montly Revenue for Pipeline Opportunity and Disposable Products added in Opportunity line item.
     public static list<Monthly_Revenue__c> calcPipeLineDispMR(list<OpportunityLineItem> oliForPipelineDisposable, set<AOP__c> AOPforPipelineDisp,set<FiscalYearSettings> FYSET, map<id, list<Period>> FYPeriod){
         System.debug('oli For Pipeline Disposable :' + oliForPipelineDisposable + 'AOP for Pipeline Disp' + AOPforPipelineDisp.SIZE()); 
          
         //List returning the monthly revenues to be inserted based on criteria.
         list<Monthly_Revenue__c> insMR = new list<Monthly_Revenue__c>();

         //Get the opporutnity Line Item fields with the Opporunity fields. 
         for(OpportunityLineItem oli : oliForPipelineDisposable ){
             //List returning the monthly revenues to be inserted based on criteria.
             list<Monthly_Revenue__c> insMRInner = new list<Monthly_Revenue__c>();
             
             // Quantity for oli
             Double OliQuan = oli.quantity;
             
            //Determine which fiscal year the Opportunity close date is. 
            for(FiscalYearSettings FYS : FYSET){
            	
                if( oli.Opportunity.Closedate >= FYS.StartDate && oli.Opportunity.Closedate <= FYS.EndDate){
                    if(oli.Product_Type_Formula__c != null || oli.Product_Type_Formula__c != ''){
                        
                        //Need to count the number of months left until end of fiscal year to create that many number if Montly revenue.
                        Integer count = 0;
                        
                        //Counter to set the date on newly created Monthly Revenue. 
                        Integer fiscalperiodCount = 0; 
                        
                        // Variable to hold the duration of days bewteen FY Start and End Date
                        Integer fiscalYearDays = 0;
                       
                        fiscalYearDays = (FYS.StartDate.daysBetween(FYS.EndDate)+1);
                        //Fiscal Year has appropriate Periods.
                        if(!FYPeriod.get(FYS.id).isEmpty() &&  FYPeriod.get(FYS.id) != null){
                            for(Period prt: FYPeriod.get(FYS.id)){
                                
                                //getting the counter based on Start dates of Period is greater than Opportunity line item.
                                // And also consider the month in which the Date is included. 
                                if( prt.StartDate > oli.Opportunity.Closedate || (oli.Opportunity.Closedate >= prt.StartDate && oli.Opportunity.Closedate <= prt.EndDate)){
                                    count += 1 ;
                                    
                                    //get the days between Fiscal End Date and Opportunity close date so that we can have date setup on new Monthly revenue accordingly. 
                                    if( oli.Opportunity.Closedate >= prt.StartDate && oli.Opportunity.Closedate <= prt.EndDate){
                                        fiscalperiodCount =  oli.Opportunity.Closedate.daysBetween(prt.EndDate); 
                                        system.debug('fiscalperiodCountvalue' + fiscalperiodCount);
                                        
                                    }
                                }
                            }
                        }
                       
                         
                        //check if Duration is more less than 12 then get the correct number of months to calculate Monthly revenue.
                        if(oli.Opportunity.Duration_months__c !=null){
                           if(oli.Opportunity.Duration_months__c < 12 && oli.Opportunity.Duration_months__c < count){
                                count = Integer.valueof(oli.Opportunity.Duration_months__c) ;
                           }
                        } system.debug('COUNT CHECK'+ count);
                        
                        //For Disposable and Equipment Product create Monthly revenues. 
                        if(oli.Product_Type_Formula__c  =='Disposable'){
                           if(!FYPeriod.get(FYS.id).isEmpty() && FYPeriod.get(FYS.id) !=null ){
                           	system.debug('FYPeriod.get(FYS.id)'+ FYPeriod.get(FYS.id));
                                for(Period prd : FYPeriod.get(FYS.id)){
                                                                        
                                    //Avoid Extra number of Monthly Revenues.
                                    if(insMRInner.size() < count){
                                    //  This condition will give us the Periods for current month of Close date and following months until end of that fiscal year. 
                                       if( prd.StartDate > oli.Opportunity.Closedate || (oli.Opportunity.Closedate >= prd.StartDate && oli.Opportunity.Closedate <= prd.EndDate)){
                                            //Associate the Monthly revenues to appropriate AOP's based on criteria explained above.
                                             
                                             Double QuanConsumed = 0.0;
                                             for(AOP__c ap:AOPforPipelineDisp){                                             	
                                                //Condition to create Montly Revenue.
            									
                                                if(ap.Sales_Rep__c == oli.Opportunity.Owner.Id && ap.Product_Line__c == oli.Product_Line_Formula__c && ap.Product_Type__c==oli.Product_Type_Formula__c  && ap.Fiscal_Period__c == prd.Number && ap.Fiscal_Year__c == Integer.valueof('20'+FYS.Name) && ap.Management_Unit__c == oli.Opportunity.Management_Unit__c && ap.Business_Unit__c == oli.Opportunity.Business_Unit__c && ap.Operating_Unit__c == oli.Opportunity.Operating_Unit__c){
                                                                                                          
                                                     Monthly_Revenue__c mr= new Monthly_Revenue__c(CurrencyIsoCode=oli.Opportunity.CurrencyIsoCode,Opportunity_Product__c= oli.id,AOP__c = ap.id, Opportunity__c = oli.OpportunityId, Fiscal_Period__c = prd.Number, Fiscal_Year__c = Integer.valueof('20'+FYS.Name) , Product_Code__c = oli.Product_Code_Formula__c );
                                                      
                                                     //For Current Month set the Monthly revenue date and the quantity 
                                                     if( oli.Opportunity.Closedate >= prd.StartDate && oli.Opportunity.Closedate <= prd.EndDate){
                                                        mr.Date__c = oli.Opportunity.Closedate;
                                                        Decimal MonthlyRev = CalMonthlyRevDispPipeline(prd.startdate,prd.EndDate,fiscalYearDays,oli.TotalPrice,oli.Opportunity.Closedate);
                                                        mr.Revenue__c = MonthlyRev;                                                        
                                                        Integer daysForFirstMonth = (oli.Opportunity.Closedate.daysBetween(prd.EndDate)+1);
                                                        Integer QuantityProRata = Integer.valueOf(Math.Round(OliQuan*((Decimal.valueOf(daysForFirstMonth)/Decimal.valueOf(fiscalYearDays)).setScale(2))));
                                                        mr.Quantity_yr__c = QuantityProRata;
                                                     }
                                                     // For Month after that till the FY end. Revenue and Quantity ProRata
                                                     else{
                                                        //mr.Date__c = prd.EndDate - fiscalperiodCount;
                                                        mr.Date__c = prd.StartDate;
                                                        Integer fiscalPeriodDays = (prd.StartDate.daysBetween(prd.EndDate) + 1);       
                                                        mr.Revenue__c = (oli.TotalPrice *(Decimal.valueOf(fiscalPeriodDays)/Decimal.valueOf(fiscalyeardays))).setScale(2);
                                                        Integer QuantityProRata = Integer.valueOf(Math.Round(OliQuan*((Decimal.valueOf(fiscalPeriodDays)/Decimal.valueOf(fiscalYearDays)).setScale(2))));
                                                        mr.Quantity_yr__c = QuantityProRata;
                                                     }
                                                     insMRInner.add(mr);
                                                     break;
                                                }
                                             }
                                             
                                        } 
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(!insMRInner.isEmpty()){
                insMR.addall(insMRInner);
            }
        }
        
        //Insert the Created Monthly Revenues
        if(!insMR.isEmpty()){
            return insMR;
        }
        
        //if no monthly revenue's created. 
        return null;
    }
    
    public static list<Monthly_Revenue__c> calcPipeLineEquipMR(list<OpportunityLineItem> oliForPipelineEquipment, set<AOP__c> AOPforPipelineEquip,set<FiscalYearSettings> FYSET, map<id, list<Period>> FYPeriod){
        // System.debug('oli For Pipeline Disposable :' + oliForPipelineDisposable + 'AOP for Pipeline Disp' + AOPforPipelineDisp.SIZE());
         
          
         //List returning the inserted monthly revenues based on criteria.
         list<Monthly_Revenue__c> insMR = new list<Monthly_Revenue__c>();

         //Get the opporutnity Line Item fields with the Opporunity fields. 
         for(OpportunityLineItem oli : oliForPipelineEquipment){
            
            //Determine which fiscal year the Opportunity close date is. 
            for(FiscalYearSettings FYS : FYSET){
                if( oli.Opportunity.Closedate >= FYS.StartDate && oli.Opportunity.Closedate <= FYS.EndDate){
                    if(oli.Product_Type_Formula__c != null || oli.Product_Type_Formula__c != ''){

                        //For Pipeline and Equipment Product create Monthly revenues. 
                        if(oli.Product_Type_Formula__c  == 'Equipment'){
                            
                             Monthly_Revenue__c mr;
                             if(!FYPeriod.get(FYS.id).isEmpty() && FYPeriod.get(FYS.id) !=null ){
                                  for(Period prd : FYPeriod.get(FYS.id)){
                                      if(MR == null){
                                          
                                          //get the fical Period in which the Opportunity close date fall in. 
                                          if( oli.Opportunity.Closedate >= prd.StartDate && oli.Opportunity.Closedate <= prd.EndDate){
                                              //Associate the Monthly revenues to appropriate AOP's based on criteria explained below.
                                              for(AOP__c ap:AOPforPipelineEquip){                                
                                                
                                                 if(ap.Product_Line__c == oli.Product_Line__c && ap.Product_Type__c==oli.Product_Type__c && ap.Fiscal_Period__c == prd.Number && ap.Fiscal_Year__c == Integer.valueof('20'+FYS.Name) && ap.Management_Unit__c == oli.Opportunity.Management_Unit__c && ap.Business_Unit__c == oli.Opportunity.Business_Unit__c && ap.Operating_Unit__c == oli.Opportunity.Operating_Unit__c){
                                                     mr= new Monthly_Revenue__c(CurrencyIsoCode=oli.Opportunity.CurrencyIsoCode,Opportunity_Product__c= oli.id,AOP__c = ap.id,Revenue__c = oli.TotalPrice ,Date__c = oli.Opportunity.Closedate, Opportunity__c = oli.OpportunityId,Fiscal_Period__c = prd.Number, Fiscal_Year__c = Integer.valueof('20'+FYS.Name) , Quantity_yr__c = oli.quantity ,Product_Code__c = oli.Product_Code_Formula__c);
                                                     insMR.add(mr);
                                                     break;
                                                 }
                                             }
                                         }
                                      }else{
                                            break;
                                      }
                                  }
                             }  
                             
                             //If no Montly revenue found then try match criteria without Management Unit. 
                            
                             if(MR == null){                              
                                if(!FYPeriod.get(FYS.id).isEmpty() && FYPeriod.get(FYS.id) !=null ){
                                     for(Period prd : FYPeriod.get(FYS.id)){ 
                                         if(mr == null){        
                                             
                                           //get the month in which the start and end date of Period fall in. 
                                            if(oli.Opportunity.Closedate >= prd.StartDate && oli.Opportunity.Closedate <= prd.EndDate){
                                                 //For Pipeline and Equipment Product create Monthly revenues. 
                                                 for(AOP__c ap:AOPforPipelineEquip){
                                                    
                                                     if(ap.Product_Line__c == oli.Product_Line__c && ap.Product_Type__c==oli.Product_Type__c && ap.Fiscal_Period__c == prd.Number && ap.Fiscal_Year__c == Integer.valueof('20'+FYS.Name) ){
                                                             mr= new Monthly_Revenue__c(CurrencyIsoCode=oli.Opportunity.CurrencyIsoCode,Opportunity_Product__c= oli.id,AOP__c = ap.id,Revenue__c = oli.TotalPrice ,Date__c = oli.Opportunity.Closedate, Opportunity__c = oli.OpportunityId,Fiscal_Period__c = prd.Number, Fiscal_Year__c = Integer.valueof('20'+FYS.Name) , Quantity_yr__c = oli.quantity ,Product_Code__c = oli.Product_Code_Formula__c);
                                                             insMR.add(mr);
                                                             break;
                                                     }
                                                }
                                            }
                                         }else{
                                            break;
                                         }
                                    }
                                 }
                             }     
                         }
                    }
                }
            }
        }
        
        //Insert the Created Monthly Revenues
        if(!insMR.isEmpty()){
            return insMR;
        }
        
        //Return null if no Montly revenues found. 
        return null;
    }
    
    public static list<Monthly_Revenue__c> calcExistingDispMR(list<OpportunityLineItem> oliForExistingDisposable, set<AOP__c> AOPforExistDisp,set<FiscalYearSettings> FYSET,map<id, list<Period>> FYPeriod){
         System.debug('oli For Existing Disposable :' + oliForExistingDisposable+ 'AOP for Exsting Disp' + oliForExistingDisposable.SIZE());
         
          
         //List returning the inserted monthly revenues based on criteria.
         list<Monthly_Revenue__c> insMR = new list<Monthly_Revenue__c>();

         //Get the opporutnity Line Item fields with the Opporunity fields. 
         for(OpportunityLineItem oli : oliForExistingDisposable){
            
            //List returning the monthly revenues to be inserted based on criteria.
             list<Monthly_Revenue__c> insMRInner = new list<Monthly_Revenue__c>();
             
             // Quantity for oli
             Double OliQuan = oli.quantity;
             
             // Duration between Oli Start and End Date
             Integer DurationOliStartEnd  = oli.start_date__c.daysBetween(oli.End_Date__c)+1;
             
            //Determine which fiscal year the Opportunity close date is. 
            for(FiscalYearSettings FYS : FYSET){
                if( oli.start_date__c >= FYS.StartDate && oli.start_date__c <= FYS.EndDate){ 
                    if(oli.Product_Type_Formula__c != null || oli.Product_Type_Formula__c != ''){
                        
                        
                        //get number of months between OpportuintyLineitem Start Date and OpportuintyLineitem  End date.
                        Integer count = 0;
                        
                        //Counter to set the date on newly created Monthly Revenue. 
                        Integer fiscalperiodCount = 0; 
                        
                        //Fiscal Year has appropriate Periods.
                        if(!FYPeriod.get(FYS.id).isEmpty() &&  FYPeriod.get(FYS.id) != null){
                            for(Period prt: FYPeriod.get(FYS.id)){
                                //get the days between Fiscal End Date and Opportunity close date so that we can have date setup on new Monthly revenue accordingly. 
                                if( oli.Start_Date__c >= prt.StartDate && oli.Start_Date__c <= prt.EndDate){
                                    fiscalperiodCount =  oli.Start_Date__c.daysBetween(prt.EndDate); 
                                    system.debug('fiscalperiodCountvalue' + fiscalperiodCount);
                                }
                            }
                        }
                        
                        //ASK VP: What about this count ? How should we consider this scenario?
                        
                        if( oli.Start_Date__c != null && oli.End_Date__c != null){
                            count = oli.Start_Date__c.monthsBetween(oli.End_Date__c) + 1;
                        }
                        
                        //check if Duration is more less than 12 then get the correct number of months to calculate Monthly revenue.
                        if(oli.Opportunity.Duration_months__c !=null){
                           if(oli.Opportunity.Duration_months__c < 12 && oli.Opportunity.Duration_months__c < count){
                                count = Integer.valueof(oli.Opportunity.Duration_months__c) ;
                           }
                        }
                        
                        //For Disposable and Equipment Product create Monthly revenues. 
                        if(oli.Product_Type_Formula__c  =='Disposable'){
                            
                            if(!FYPeriod.get(FYS.id).isEmpty() && FYPeriod.get(FYS.id) !=null ){
                                 Integer QuanConsumed = 0;
                                 for(Period prd : FYPeriod.get(FYS.id)){
                                     //Avoid Extra number of Monthly Revenues.
                                     if(insMRInner.size() < count){     
                                       
                                        //  This condition will give us the Periods for current month of Close date and following months until end of that fiscal year. 
                                        
                                        if( prd.StartDate > oli.Start_Date__c || (oli.Start_Date__c >= prd.StartDate && oli.Start_Date__c  <= prd.EndDate)){
                                          	
                                            //Associate the Monthly revenues to appropriate AOP's based on criteria explained above.
                                            
                                            for(AOP__c ap:AOPforExistDisp){                               
                                                if(ap.Sales_Rep__c == oli.Opportunity.Owner.Id && ap.Product_Line__c ==oli.Product_Line_Formula__c && ap.Product_Type__c==oli.Product_Type_Formula__c  && ap.Fiscal_Period__c == prd.Number && ap.Fiscal_Year__c == Integer.valueof('20'+FYS.Name) && ap.Management_Unit__c == oli.Opportunity.Management_Unit__c && ap.Business_Unit__c == oli.Opportunity.Business_Unit__c && ap.Operating_Unit__c == oli.Opportunity.Operating_Unit__c){
                                                    
                                                    Monthly_Revenue__c mr= new Monthly_Revenue__c(CurrencyIsoCode=oli.Opportunity.CurrencyIsoCode,Opportunity_Product__c= oli.id,AOP__c = ap.id, Opportunity__c = oli.OpportunityId,Fiscal_Period__c = prd.Number, Fiscal_Year__c = Integer.valueof('20'+FYS.Name) , Product_Code__c = oli.Product_Code_Formula__c);
                                                    //For Current Month set the Monthly revenue date ,Revenue and Quantity
                                                     if( oli.Start_Date__c >= prd.StartDate && oli.Start_Date__c <= prd.EndDate){
                                                       
                                                        mr.Date__c = oli.Start_Date__c;
                                                        if(oli.End_Date__c >= prd.EndDate)
                                                        {
	                                                        Integer daysForFirstMonth = oli.Start_Date__c.daysBetween(prd.EndDate)+1;                                                        
	                                                        Integer QuantityProRata = Integer.valueOf(Math.Round(OliQuan*((Decimal.valueOf(daysForFirstMonth)/Decimal.valueOf(DurationOliStartEnd)).setScale(2))));
	                                                        mr.Quantity_yr__c = QuantityProRata;
	                                                        Decimal MonthlyRev = CalMonthlyRevDispExistingFirstMonth(oli.Start_Date__c,prd.EndDate,DurationOliStartEnd,oli.TotalPrice);
	                                                        mr.Revenue__c = MonthlyRev;                                            
	                                                        QuanConsumed = QuanConsumed+QuantityProRata;
                                                        }
                                                        else
                                                        {
                                                        	Integer daysForFirstMonth = oli.Start_Date__c.daysBetween(oli.End_Date__c)+1;
                                                        	Integer QuantityProRata = Integer.valueOf(Math.Round(OliQuan*((Decimal.valueOf(daysForFirstMonth)/Decimal.valueOf(DurationOliStartEnd)).setScale(2))));
	                                                        mr.Quantity_yr__c = QuantityProRata;
	                                                        Decimal MonthlyRev = (oli.TotalPrice * (Decimal.valueOf(daysForFirstMonth)/Decimal.valueOf(DurationOliStartEnd))).setScale(2); 
	                                                        mr.Revenue__c = MonthlyRev;  
                                                        }
                                                     }
                                                     else if(oli.End_Date__c<=prd.EndDate) //For the Period between period start date and Oli End date
                                                     {                                           	
                                                     	//mr.Date__c = oli.End_Date__c;
                                                     	mr.Date__c = prd.StartDate;
                                                     	Integer daysForLastMonth = prd.startdate.daysBetween(oli.End_Date__c)+1;                                                    	
                                                     	Integer QuantityProRata = Integer.valueOf(Math.Round(OliQuan*((Decimal.valueOf(daysForLastMonth)/Decimal.valueOf(DurationOliStartEnd)).setScale(2))));
                                                     	if((OliQuan - QuanConsumed) == QuantityProRata)
                                                     		mr.Quantity_yr__c = QuantityProRata;
                                                     	else
                                                     		mr.Quantity_yr__c = (OliQuan - QuanConsumed);
                                                     	Decimal MonthlyRev = CalMonthlyRevDispExistingLastMonth(prd.startdate,oli.End_Date__c,DurationOliStartEnd,oli.TotalPrice);
                                                        mr.Revenue__c = MonthlyRev;                                                   
                                                     }
                                                     else{ // For the period which are in between Oli start and End date and completely covered
                                                     	
                                                        //mr.Date__c = prd.EndDate - fiscalperiodCount;
                                                        mr.Date__c = prd.StartDate;                                                        
														Integer periodDuration = (prd.StartDate.daysBetween(prd.EndDate) + 1) ;
														mr.Revenue__c = (oli.TotalPrice * (Decimal.valueOf(periodDuration)/Decimal.valueOf(DurationOliStartEnd))).setScale(2);														
														Integer QuantityProRata = Integer.valueOf(Math.Round(OliQuan*((Decimal.valueOf(periodDuration)/Decimal.valueOf(DurationOliStartEnd)).setScale(2))));		
														mr.Quantity_yr__c = QuantityProRata;						
														QuanConsumed = QuanConsumed+QuantityProRata;
                                                        //mr.Revenue__c = oli.TotalPrice / 12;
                                                     }
                                                     insMRInner.add(mr);
                                                     break;
                                                } 
                                            }                                             
                                         }
                                     }
                                 }
                             }
                         }
                    }
                }
            }
            if(!insMRInner.isEmpty()){
            insMR.addall(insMRInner);
            }
        }
        
        //Insert the Created Monthly Revenues
        if(!insMR.isEmpty()){
            return insMR;
        }
        return null;
    }
    
    public static list<Monthly_Revenue__c> calcExistingEquipMR(list<OpportunityLineItem> oliForExistingEquipment, set<AOP__c> AOPforExistEquip,set<FiscalYearSettings> FYSET,map<id, list<Period>> FYPeriod){
        // System.debug('oli For Pipeline Disposable :' + oliForPipelineDisposable + 'AOP for Pipeline Disp' + AOPforPipelineDisp.SIZE());
         
          
         //List returning the inserted monthly revenues based on criteria.
         list<Monthly_Revenue__c> insMR = new list<Monthly_Revenue__c>();

         //Get the opporutnity Line Item fields with the Opporunity fields. 
         for(OpportunityLineItem oli : oliForExistingEquipment){
            for(FiscalYearSettings FYS : FYSET){
                if( oli.Start_Date__c >= FYS.StartDate && oli.Start_Date__c <= FYS.EndDate){
                    if(oli.Product_Type_Formula__c != null || oli.Product_Type_Formula__c != ''){
                
                        //get number of months between OpportuintyLineitem Start Date and OpportuintyLineitem  End date.
                     /*   Integer count = 0;
                        if( oli.Start_Date__c != null && oli.End_Date__c != null){
                            count = oli.Start_Date__c.monthsBetween(oli.End_Date__c);
                        }
                        
                        //check if Duration is more less than 12 then get the correct number of months to calculate Monthly revenue.
                        if(oli.Opportunity.Duration_months__c !=null){
                           if(oli.Opportunity.Duration_months__c < 12 && oli.Opportunity.Duration_months__c < count){
                                count = Integer.valueof(oli.Opportunity.Duration_months__c) ;
                           }
                        }*/
                
                        //For Disposable and Equipment Product create Monthly revenues. 
                        if(oli.Product_Type_Formula__c  =='Equipment'){
                                 
                             //Associate the Monthly revenues to appropriate AOP's based on criteria explained above.
                             Monthly_Revenue__c mr;
                             
                             if(!FYPeriod.get(FYS.id).isEmpty() && FYPeriod.get(FYS.id) !=null ){
                                 for(Period prd : FYPeriod.get(FYS.id)){
                                     if(mr == null){   
                                         //get the month in which the start and end date of Period fall in. 
                                         if(oli.Start_Date__c >= prd.StartDate && oli.Start_Date__c <= prd.EndDate){
                                             //Associate the Monthly revenues to appropriate AOP's based on criteria explained above.
                                             for(AOP__c ap:AOPforExistEquip){
                                                 if(ap.Product_Line__c == oli.Product_Line__c && ap.Product_Type__c==oli.Product_Type__c && ap.Fiscal_Period__c == prd.Number && ap.Fiscal_Year__c == Integer.valueof('20'+FYS.Name) && ap.Management_Unit__c == oli.Opportunity.Management_Unit__c && ap.Business_Unit__c == oli.Opportunity.Business_Unit__c && ap.Operating_Unit__c == oli.Opportunity.Operating_Unit__c){
                                                     mr= new Monthly_Revenue__c(CurrencyIsoCode=oli.Opportunity.CurrencyIsoCode,Opportunity_Product__c= oli.id,AOP__c = ap.id,Revenue__c = oli.TotalPrice ,Date__c = oli.Start_Date__c, Opportunity__c = oli.OpportunityId,Fiscal_Period__c = prd.Number, Fiscal_Year__c = Integer.valueof('20'+FYS.Name) , Quantity_yr__c = oli.quantity ,Product_Code__c = oli.Product_Code_Formula__c);
                                                     insMR.add(mr);
                                                     break;
                                                 }
                                             }  
                                         }
                                     }else{
                                        break;
                                     }
                                 }
                             }
                            
                             if(mr == null){
                                 if(!FYPeriod.get(FYS.id).isEmpty() && FYPeriod.get(FYS.id) !=null ){
                                     for(Period prd : FYPeriod.get(FYS.id)){
                                         if(mr == null){
                                             //get the month in which the start and end date of Period fall in. 
                                             if(oli.Start_Date__c >= prd.StartDate && oli.Start_Date__c <= prd.EndDate){
                                                 //Associate the Monthly revenues to appropriate AOP's based on criteria explained above.
                                                 for(AOP__c ap:AOPforExistEquip){
                                                     if(ap.Product_Line__c == oli.Product_Line__c && ap.Product_Type__c==oli.Product_Type__c && ap.Fiscal_Period__c == prd.Number && ap.Fiscal_Year__c == Integer.valueof('20'+FYS.Name)){
                                                         mr= new Monthly_Revenue__c(CurrencyIsoCode=oli.Opportunity.CurrencyIsoCode, Opportunity_Product__c= oli.id,AOP__c = ap.id,Revenue__c = oli.TotalPrice ,Date__c = oli.Start_Date__c, Opportunity__c = oli.OpportunityId,Fiscal_Period__c = prd.Number, Fiscal_Year__c = Integer.valueof('20'+FYS.Name) , Quantity_yr__c = oli.quantity ,Product_Code__c = oli.Product_Code_Formula__c);
                                                         insMR.add(mr);
                                                         break;
                                                     }
                                                 }  
                                             }
                                         }else{
                                            break;
                                         }
                                     }
                                 }
                             }
                        }
                    }
                }
            }
        }


        //Insert the Created Monthly Revenues
        if(!insMR.isEmpty()){
            return insMR;
        }
        return null;
    }
    
    //Added by Avinash Bari<abari@innoveer.com>
    // Modifed by Staraupa Roy for latest requirements
    public static decimal CalMonthlyRevDispPipeline(date startdate, date enddate, integer fiscalYearDays, Decimal totalprice ,date opptyclosedate){
        Decimal monthlyrev;
        //Getting total days of period.
        integer totalperioddays=((startdate).daysBetween(EndDate))+1;
        fiscalYearDays = fiscalYearDays; //days between FY Start and FY End Date
		Integer periodDurationInWeeks = totalperioddays/ 7;
		Integer closefiscaldays = (opptyclosedate.daysBetween(enddate))+1;															
        system.debug('****totalperioddays*****'+totalperioddays+'****fiscalperiodcount*****'+fiscalYearDays+'****totalprice*****'+totalprice);
        monthlyrev = ((Decimal.valueof(closefiscaldays)/Decimal.valueof(fiscalyeardays))*totalprice).setScale(2);
        system.debug('****monthlyrev*****'+monthlyrev);
        return monthlyrev;
        
    }
    
    // Added by Satarupa Roy to handle the first month case for Existing Opportunity
    public static decimal CalMonthlyRevDispExistingFirstMonth(date startdate, date enddate, integer DurationOliStartEnd, Decimal totalprice){
        Decimal monthlyrev;
        //Getting total days of period.
        integer totalperioddays=((startdate).daysBetween(enddate))+1;
        integer remainingfiscalperiodcount = DurationOliStartEnd; //days between closedate of opportunity and fiscal year end date
		Integer periodDurationInWeeks = totalperioddays/ 7;
																
        system.debug('****totalperioddays*****'+totalperioddays+'****remainingfiscalperiodcount*****'+remainingfiscalperiodcount+'****totalprice*****'+totalprice);
        //Calculating the monthly Revenue.
		monthlyrev = (totalprice*(Decimal.valueOf(totalperioddays)/Decimal.valueOf(remainingfiscalperiodcount))).setScale(2);
        system.debug('****monthlyrev*****'+monthlyrev);
        return monthlyrev;
        
    }
    
    // Added By Satarupa Roy to handle the last month case for Existing Opportunity
    public static decimal CalMonthlyRevDispExistingLastMonth(date startdate, date enddate, integer DurationOliStartEnd, Decimal totalprice){
        Decimal monthlyrev;
        //Getting total days of period.
        integer totalperioddays=((startdate).daysBetween(enddate))+1;
        integer remainingfiscalperiodcount = DurationOliStartEnd; //days between closedate of opportunity and fiscal year end date
		Integer periodDurationInWeeks = totalperioddays/ 7;
																
        system.debug('****totalperioddays*****'+totalperioddays+'****remainingfiscalperiodcount*****'+remainingfiscalperiodcount+'****totalprice*****'+totalprice);
        //Calculating the monthly Revenue.
        monthlyrev = (totalprice*(Decimal.valueOf(totalperioddays)/Decimal.valueOf(remainingfiscalperiodcount))).setScale(2);
        system.debug('****monthlyrev*****'+monthlyrev);
        return monthlyrev;
        
    }
    
}