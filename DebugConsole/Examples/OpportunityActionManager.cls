public with sharing class OpportunityActionManager{
    
    private transient list<Objective> mstageObjectives;
    //private list<Objective> mCommitObjectives;
    public list<Objective> stageObjectives{
        get{
            if(mstageObjectives==null||commitObjectives==null){
                makeObjectivesAndAdvancementCriteria();
            }
            return commitOnly ? commitObjectives : mstageObjectives;
      //      return mStageObjectives;      
        }
    }

    private transient list<Objective> mcommitObjectives;
    public list<Objective> commitObjectives{
        get{
            if(mcommitObjectives==null){
                makeObjectivesAndAdvancementCriteria();
            }
            return mcommitObjectives;
        }
    }

    public boolean commitOnly{get;set;}

    private transient Objective madvancementCriteria;
    public Objective advancementCriteria{
        get{
            if(madvancementCriteria==null){
                makeObjectivesAndAdvancementCriteria();
            }
            return madvancementCriteria;
        }
    }

    private list<Task> moppActions;
    public list<Task> oppActions{
        get{
            if(moppActions==null){
                moppActions = new list<Task>();
                moppActions.addAll(getCommitActions(stageObjectives));
               // moppActions.addAll(getCommitActions(new list<Objective>{advancementCriteria}));
                system.debug('moppActions' + moppActions);
            }
            return moppActions;
        }
    }

    private list<Task> getCommitActions(list<Objective> objs){
        list<Task> oppact = new list<Task>();
        for(Objective obj:objs){
            for(Action act:obj.actions){
                if(act.committed){
                    oppact.add(act.action);
                }
            }
        }
        return oppact;
    }

    private static Id taskRecordTypeId = RecordTypeManager.getIdByName('Opportunity_Action','Task');
    //private static Translation trans = new Translation();
    private map<Id,sObject> objMap;
    private map<Id,list<sObject>> actionMap;
    private map<id,Objective_Action__c> objActions;
    private Id oppId;
    
    public OpportunityActionManager(list<Stage_Objective__c> objs,list<Task> acts, map<Id,Objective_Action__c> objActions,Id oppId){
        this.commitOnly = false;
        this.objMap = objs!=null ? sCollection.IdMap(objs,Stage_Objective__c.Id) : new map<Id,sObject>();
        this.actionMap = acts!=null ? sCollection.IdListMap(acts,Task.StageObjectiveID__c) : new map<Id,list<sObject>>();
        this.objActions = objActions;
        this.oppId = oppId;
    }

    public void resetTasks(list<Task> tsk){
        this.actionMap= tsk!=null ? sCollection.IdListMap(tsk,Task.StageObjectiveID__c) : new map<Id,list<sObject>>();
    }

    public void clear(){
        mStageObjectives = null;
        mCommitObjectives = null;
        madvancementCriteria = null;
    }
    
    private void makeObjectivesAndAdvancementCriteria(){
        mstageObjectives = new list<Objective>();
        mCommitObjectives = new list<Objective>();
        Objective obj;
        Objective comObj;
        Stage_Objective__c stageObj;
        integer order;
        Id objId;
        list<Task> actions;
        list<Objective> objectives = new list<Objective>();
        for(Id objKey:objMap.keySet()){
            stageObj = (Stage_Objective__c) objMap.get(objKey);
            comObj = new Objective(stageObj,oppId,true);
            obj = new Objective(stageObj,oppId);
            actions = actionMap.containsKey(objKey) ? (list<Task>) actionMap.get(objKey) : new list<Task>();
            for(Task action:actions){
                objId = action.ObjectiveActionID__c;
                order = objActions.containsKey(objId)&&objActions.get(objId).Order__c!=null ? objActions.get(objId).Order__c.intValue() : -1;
                obj.add(action,objActions.get(objId),order);
                comObj.add(action,objActions.get(objId),order);
            }
            if(stageObj.Advancement_Criteria__c){
                madvancementcriteria = obj;
            } else {
                mstageObjectives.add(obj);
                mcommitObjectives.add(comObj);
                //objectives.add(obj);
            }
        }
    }
    
    public class Objective{
        
        private list<Action> mactions;
        public list<Action> actions{//get{return actionMap.values();}}
        
            get{
                
                if(mactions==null){
                    list<integer> order = new list<integer>(actionMap.keySet());
                    order.sort();
                    mactions = new list<Action>();
                    for(integer place:order){
                        if(place!=null){ mactions.add(actionMap.get(place)); }
                    }
                }
                return mactions;
            }    
        }
        
        public boolean isEmpty{
            get{return actionMap.values().isEmpty();}
        }

        public String name{get;private set;}
        private map<integer,Action> actionMap;
        private list<Action> unordered;
        private Stage_Objective__c obj;
        private Id oppId;
        
        public Objective(Stage_Objective__c obj,Id oppId){
            this(obj,oppId,false);
        }

        public Objective(Stage_Objective__c obj,Id oppId,boolean committed){
            //name = trans.getTranslatedValue(obj.Id,obj.name);
            name = obj.name;
            this.obj = obj;
            this.oppId = oppId;
            actionMap = new map<integer,Action>();
            unordered = new list<Action>();
            if(!committed){
                for(Objective_Action__c act:obj.Objective_Action__r){
                    if(act.Order__c==null){
                        unordered.add(new Action(act,oppId));
                    } else {
                        actionMap.put(act.Order__c.intValue(),new Action(act,oppId));
                    }
                }
            }
        }

        public void add(Task tsk,Objective_Action__c act,integer order){
            if(order!=null&&order!=-1){
                actionMap.put(order,new Action(tsk,act));
            } else {
                unordered.add(new Action(tsk,act));
            }
        }
    }
    
    public class Action{
    
        public String subject{
            //get{return trans.getTranslatedValue(act.Id,act.name);}
            get{return act.name;}
        }

//        public boolean committed{get;set;}
        public boolean committed{
            get{return completed||action.ActivityDate!=null||action.Description!=null;}
        }
        public boolean completed{
            get{return action.isClosed||action.status=='Completed';}
            set{action.Status = value ? 'Completed' : action.Status;}
        }
        public Task action{get;set;}
        private Objective_Action__c act;
        
        public Action(Objective_Action__c act,Id oppId){
            this();
            this.act=act;
            //this.committed = false;
            //action.subject = trans.getTranslatedValue(act.Id,act.name);
            
            action.subject = act.name;
            action.subject = act.name;
            action.WhatId = oppId;
            action.ObjectiveActionID__c = act.Id;
            action.StageObjectiveID__c = act.Stage_Objective__c;
            action.Related_Stage__c = act.Stage_Objective__r.Opportunity_Stage__r.Name;
            action.RecordTypeId = taskRecordTypeId;
            action.Status = 'Not Started';
            action.Un_Translated_Action__c = act.Name;
        }

        public Action(Task tsk,Objective_Action__c act){
            this();
            //this.committed = true;
            this.act = act;
            action = tsk;
        }
        
        public Action(){
            action = new Task();
        }
        
        public PageReference linkToView(){
            return new ApexPages.PageReference('/'+action.Id);
        }
    }
    
    
    

    
    
    
    
    
}