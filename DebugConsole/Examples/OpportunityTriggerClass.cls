public without sharing class  OpportunityTriggerClass {
  
    public static void beforeInsert(List<Opportunity> triggerNew){
      //  syncOpportunityStage(triggerNew);
    }
    
    public static void beforeUpdate(Map<Id,Opportunity> triggerOld, Map<Id,Opportunity> triggerNew){
       // syncOpportunityStage(triggerOld,triggerNew);
        validateStageChanges(triggerOld,triggerNew);                      
    }
    

    public static void afterInsert(Map<Id,Opportunity> triggerNew){
        createActions(triggerNew);
    }
   
  
    public static void afterUpdate(Map<Id,Opportunity> triggerOld, Map<Id,Opportunity> triggerNew){
        createActions(triggerNew);
    }
    
    public static void beforeDelete(Map<Id,Opportunity> triggerNew){
        
    } 
    public static void afterDelete(Map<Id,Opportunity> triggerNew){
        
    }

    private static void syncOpportunityStage(map<Id, Opportunity> oldMap, map<Id, Opportunity> newMap) {
       /* list<Opportunity> opps = new list<Opportunity>();
        for(Diff oppDiff : Diff.getDiffs(oldMap,newMap)) {
            if(oppDiff.isChanged('StageName')) {
                opps.add((Opportunity) oppDiff.getNewObject());
            }
        }
        syncOpportunityStage(opps);*/
    }
  
    private static void syncOpportunityStage(list <Opportunity> opps) {
      /*  map<string,SObject> stages = sCollection.stringMap([select Id, Name from Opportunity_Stage__c], 'Name');
        for (Opportunity opp : opps) {
            opp.Opportunity_Stage__c = stages.containsKey(opp.StageName) ? stages.get(opp.StageName).Id : null;
        }
       */
    }
    
    private static void validateStageChanges(map<Id,Opportunity> oldMap, map<Id,Opportunity> newMap){
        list<Opportunity> oppsToCheck = new list<Opportunity>();
        map<String,sObject> stages = sCollection.StringMap([select Id, Name, Stage_Number__c from Opportunity_Stage__c],Opportunity_Stage__c.Name);
        list<Opportunity> oppsToRollbackActions = new list<Opportunity>();
            for(Id oppId:newMap.keyset()){
                if(oldMap.get(oppId).StageName=='Closed Lost'){
                    if(newMap.get(oppId).StageName=='Closed Won'){newMap.get(oppId).StageName.addError(System.Label.Stage_Error);}
                    continue;
                }
                decimal oldStage = oldMap.get(oppId)==null||stages.get(oldMap.get(oppId).StageName)==null||((Opportunity_Stage__c)stages.get(oldMap.get(oppId).StageName)).Stage_Number__c==null ? 0 :  ((Opportunity_Stage__c)stages.get(oldMap.get(oppId).StageName)).Stage_Number__c;
                decimal newStage = newMap.get(oppId)==null||stages.get(newMap.get(oppId).StageName)==null||((Opportunity_Stage__c)stages.get(newMap.get(oppId).StageName)).Stage_Number__c==null ? 0 :  ((Opportunity_Stage__c)stages.get(newMap.get(oppId).StageName)).Stage_Number__c;
                System.debug('New Stage: ' + newMap.get(oppId).StageName  + ' Old Stage: ' + oldMap.get(oppId).StageName );
                System.debug('New Stage Number: ' + newStage + ' Old Stage Number: ' + oldStage);
                if(newStage > 1+oldStage && oldMap.get(oppId).StageName != 'Targeting' ){ // is beyond next stage
                    //Forbid moving to stage beyond next stage
                   newMap.get(oppId).StageName.addError(System.Label.Stage_Error);
                } else if(newStage==1+oldStage){ // Is next stage
                    //Validate Advancement
                    oppsToCheck.add(newMap.get(oppId));
                } else if(newStage<oldStage){ // Is prior stage
                    //set prior Opp Actions to incomplete
                    oppsToRollbackActions.add(newMap.get(oppId));
                }
            }
            set<Id> oppIds = sCollection.idSet(oppsToCheck,Opportunity.Id);
            oppIds.addAll(sCollection.idSet(oppsToRollbackActions,Opportunity.Id));
            map<Id,Stage_Objective__c> sos = new map<Id,Stage_Objective__c>([select Id from Stage_Objective__c where Advancement_Criteria__c = true]);
            set<String> soIds = new set<String>();
            for(Id soId:sos.keySet()){
                soIds.add((String) soId);
            }
            map<Id,list<sObject>> actions = sCollection.idListMap(
                                        [select Id
                                        , Subject
                                        , IsClosed
                                        , Status
                                        , WhatId
                                        , Related_Stage__c
                                        from Task 
                                        where WhatId in :newMap.keySet() 
                                            and StageObjectiveID__c in :soIds]
                                        ,Task.WhatId);
            list<Task> toRollBack = new list<Task>();
            list<Task> rollBackActions;
            for(Opportunity opp:oppsToRollbackActions){
                rollBackActions = (list<Task>) actions.get(opp.Id);
                if(rollBackActions!=null){
                    sCollection.puts(rollBackActions,Task.Status,'Not Started');
                    toRollback.addAll(rollBackActions);
                }
            }
            database.update(toRollBack);
            list<Task> oppActions;
            map<String,list<sObject>> stageActions;
            list<Task> oldActions;
            for(Opportunity opp:oppsToCheck){
                oppActions = actions.get(opp.Id);
                if(oppActions!=null){
                    stageActions = sCollection.stringListMap(oppActions,Task.Related_Stage__c);
                    oldActions = stageActions.get(oldMap.get(opp.Id).StageName)==null ? new list<Task>() : (list<Task>) stageActions.get(oldMap.get(opp.Id).StageName);
                    for(Task act:oldActions){
                        if(!act.IsClosed){
                            opp.StageName.addError(System.Label.Advancement_Error);
                            break;
                        }
                    }
                }
            }
    }

    private static ID oppActionTaskRTID = RecordTypeManager.getIdByName('Opportunity_Action','Task');
   
    private static void createActions(map<Id,Opportunity>opps){
        map<String,list<Objective_Action__c>> stageToObjMap = (map<String,list<Objective_Action__c>>) sCollection.stringListMap([select Id,Stage_Name__c , Name, Stage_Objective__r.Opportunity_Stage__r.Name 
                from Objective_Action__c 
                where Stage_Name__c in :sCollection.stringSet(opps.Values(),'StageName')
                and Stage_Objective__r.Advancement_Criteria__c = true]
                    ,Objective_Action__c.Stage_Name__c);
        list<Task> existingActionList = [select Id, WhatId, ObjectiveActionID__c from Task where WhatId in :opps.keySet() and RecordTypeId = :oppActionTaskRTID];
        map<String,Task> existingActionMap = new map<String,Task>();
        for(Task action:existingActionList){
            existingActionMap.putall(makeOppAction(action));
        }
        
        map<String,Task> toInsert = new map<String,Task>();
        for(Opportunity opp:opps.values()){
            if(stageToObjMap.get(opp.StageName)!=null){
                for(Objective_Action__c act:stageToObjMap.get(opp.StageName)){
                    if(!existingActionMap.containsKey(opp.Id+''+act.Id)){
                        toInsert.putAll(makeOppAction(opp,act));
                    }
                }
            }
        }
        insert(toInsert.values());
    }
    
    //private static Translation trans = new Translation();
    
    private static map<String,Task> makeOppAction(Opportunity opp,Objective_Action__c act){
        map<String,Task> result = new map<String,Task>();
        Task t = new Task();
        t.WhatId = opp.Id;
        t.ObjectiveActionID__c = act.Id;
        t.StageObjectiveID__c = act.Stage_Objective__c;
        //t.subject = trans.getTranslatedValue(act.Id,act.name,opp.OwnerId);
        t.subject = act.name;
        t.Related_Stage__c = opp.StageName;
        t.RecordTypeId = oppActionTaskRTID;
        t.ActivityDate = opp.CloseDate;
        t.Un_Translated_Action__c = act.Name;
        t.OwnerId = opp.OwnerId;
        result.put(opp.Id+''+act.Id,t);
        return result;
    }
    
    private static map<String,Task> makeOppAction(Task oppAct){
        map<String,Task> result = new map<String,Task>();
        result.put(oppAct.WhatId+''+oppAct.ObjectiveActionID__c,oppAct);
        return result;
    }   
}