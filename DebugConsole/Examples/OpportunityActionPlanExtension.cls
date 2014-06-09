public class OpportunityActionPlanExtension {

    public list<OpportunityActionManager.Objective> stageObjectives{
        get{return manager.stageObjectives; }
    }

    public OpportunityActionManager.Objective advancementCriteria{
        get{return manager.advancementCriteria;}
    }
    
    public list<SelectOption> viewOptions{
        get{
            return new list<SelectOption>{new SelectOption('all',System.Label.View_All_Actions), new SelectOption('commit',System.Label.View_Committed_Actions)};
        }
    }
    
    public boolean render{get;set;}
    
    public String currentStage{get;set;}
    
    private list<SelectOption> mstages;
    public list<SelectOption> stages{
        get{
            if(mstages==null){
                mstages = new list<SelectOption>();
                map<String,Schema.PicklistEntry> stageMap = new map<String,Schema.PicklistEntry>();
                for(Schema.PicklistEntry ple:Opportunity.sObjectType.getDescribe().fields.getMap().get('StageName').getDescribe().getPicklistValues()){
                    stageMap.put(ple.getValue(),ple);   
                }
                for(Opportunity_Stage__c stage:[select Id, Name ,Opportunity_Type__c 
                        from Opportunity_Stage__c
                        where Opportunity_Type__c =: opp.Stage_Opportunity_Type__c and Id in (select Opportunity_Stage__c from Stage_Objective__c)
                        order by Stage_Number__c]){
                    mstages.add(new SelectOption(stage.name,stageMap.get(stage.name).getLabel()));
                  
                }
            }
            return mstages;
        }
    }
    
    public String currentView{get;
        set{
            manager.commitOnly = value=='commit';
            currentView = value;
        }
    }
    
    public String blockTitle{
        get{return showTitle ? opp.name + ' - ' + opp.StageName : '';}
    }
    
    public boolean showTitle{
        get{
            map<String,String> params = ApexPages.CurrentPage().getParameters();
            return params.containsKey('showOptions')&&params.get('showOptions')=='1';
        }
    }
    
    public Opportunity opp{get;
        set{
            if(currentStage==null){ currentStage = value.StageName; }
            init(value);
            opp = value;
        }
    }

    private OpportunityActionManager manager{
        get{return managermap.get(currentStage);}
    }
    
    private map<String,OpportunityActionManager> managermap;

    public OpportunityActionPlanExtension(ApexPages.StandardController std){
        this.opp = (Opportunity) std.getRecord();
        render = false;
        for(SelectOption stage:stages){
            render = render||stage.getValue()==opp.StageName;
        }
        if(!render){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.INFO,System.Label.No_Objectives));
        }
        this.currentStage = opp.StageName;
        init(opp);
    }

    public OpportunityActionPlanExtension(){
        
    }

    private void init(Opportunity opp){
        this.managermap = new map<String,OpportunityActionManager>();
        map<String,list<Stage_Objective__c>> so = queryStageObjectives(opp);
        map<String,list<Task>> oa = queryOppActions(opp);
        map<Id,Objective_Action__c> objActions = queryObjectiveActions(opp);
        set<String> stagesSet = new set<String>();
        stagesSet.addAll(so.keySet());
        stagesSet.addAll(oa.keySet());
        for(String stage:stagesSet){
            managermap.put(stage,new OpportunityActionManager(so.get(stage),oa.get(stage),objActions,opp.Id));
        }
        system.debug('managermap'+managermap);
    }

    private map<Id,Objective_Action__c> queryObjectiveActions(Opportunity opp){
        return new map<Id,Objective_Action__c>([select Id, name,Order__c from Objective_Action__c]);
    }

    private map<String,list<Stage_Objective__c>> queryStageObjectives(Opportunity opp){
        map<String,list<Stage_Objective__c>> result = new map<String,list<Stage_Objective__c>>();
        set<Id> oaIds = sCollection.IdSet([select ObjectiveActionID__c from Task where WhatId = :opp.Id],Task.ObjectiveActionId__c);
        list<Stage_Objective__c> so;
        String stage;
        for(Stage_Objective__c obj:[select Id, name, Advancement_Criteria__c, Opportunity_Stage__r.name,Opportunity_Stage__r.Opportunity_Type__c,
                                    (select Id, name, Description__c, Order__c, Stage_Objective__r.Opportunity_Stage__r.name, Stage_Objective__c
                                    from Objective_Action__r 
                                    where Id not in :oaIds
                                    order by Order__c desc)
                                        from Stage_Objective__c where Opportunity_Stage__r.Opportunity_Type__c  =:  opp.Stage_Opportunity_Type__c
                                        order by Order__c desc]){
            
            stage = obj.Opportunity_Stage__r.name;
            so = result.containsKey(stage) ? result.get(stage) : new list<Stage_Objective__c>();
            so.add(obj);
            result.put(stage,so);
        }
        return result;
    }
    
    private map<String,list<Task>> queryOppActions(Opportunity opp){
        map<String,list<Task>> result = new map<String,list<Task>>();
        list<Task> actions;
        String stage;
        for(Task act:[select Id, Subject, ActivityDate, IsClosed, ObjectiveActionID__c,
            Key_Action__c, StageObjectiveID__c, Description, Related_Stage__c, WhatId, Status
            from Task
            where whatId = :opp.Id
            and StageObjectiveID__c != null
            and ObjectiveActionID__c != null]){
            stage = act.Related_Stage__c;
            actions = result.containsKey(stage) ? result.get(stage) : new list<Task>();
            actions.add(act); 
            result.put(stage,actions);
        }
        return result;
    }
    
    public PageReference saveActions(){
        list<Task> actions = new list<Task>();
        for(OpportunityActionManager man:managerMap.values()){
            actions.addAll(man.oppActions);
        }
        database.upsert(actions);
        //for(OpportunityActionManager man:managerMap.values()){
        //    man.resetTasks(this.tasks);
        //}
        this.init(opp);
        return null;
    }
    
    public PageReference cancelActions(){
        for(OpportunityActionManager man:managerMap.values()){
            man.clear();
        }
        return null;
    }
    
    
    
}