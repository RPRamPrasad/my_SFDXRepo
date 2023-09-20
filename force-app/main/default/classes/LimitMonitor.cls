/**
* Author : Team Simpli Fi
* @description : Class for monitoring cpu, dml, queries, future calls, heap size, queue jobs, aggregate queries, callouts, email invocations, and other calls.
*/ 
public without sharing class LimitMonitor {

    @TestVisible private String className;
    @TestVisible private Double threshold;
    @TestVisible private CS_Limit_Monitoring__c limitMonitorCS;
    @TestVisible private List<String> limitsHit = new List<String>();
    private List<Limit_Monitoring__c> lms = new List<Limit_Monitoring__c>();
	
    /**
     * @description Constructor for LimitMonitor
     * @param limitMonitorCS 
     */ 
    public LimitMonitor(CS_Limit_Monitoring__c limitMonitorCS){
        if(isToggledOn() && limitMonitorCS != null){
            this.limitMonitorCS = limitMonitorCS;
            this.className = limitMonitorCS.Apex_Class_Name__c;
            this.threshold = (limitMonitorCS.Limit_Threshold_Percentage__c == null) ? 75.0 : limitMonitorCS.Limit_Threshold_Percentage__c;
        }
    }
  
    private boolean isToggledOn(){
        return FeatureManagement.checkPermission('Limit_Monitoring');
    }
    
    /**
     * @description Calls monitoring methods
     */ 
    public void monitor(){
        if(this.limitMonitorCS != null && this.limitMonitorCS.Monitor_Class__c){
            monitorCPU();
            monitorDML();
            monitorQueries();
            monitorFutureCalls();
            monitorHeapSize();
            monitorQueueJobs();
            monitorAggregateQueries();
            monitorCallouts();
            monitorEmailInvocations();
            monitorFindSimilarCalls();
            buildMonitoringObjects();
            handleLimitMonitorRecord();
        }
    }
    
    private void monitorCPU(){
        if(this.limitMonitorCS.Include_CPU__c){
            monitorLimit('CPU Time', Limits.getLimitCpuTime(), Limits.getCpuTime()); 
        }
    }
    
    private void monitorDML(){
        if(this.limitMonitorCS.Include_DML__c){
            monitorLimit('DML Statements', Limits.getLimitDmlStatements(), Limits.getDmlStatements());
            monitorLimit('DML Rows', Limits.getLimitDmlRows(), Limits.getDmlRows());
            monitorDatabaseTime();
        }
    }
    
    private void monitorQueries(){
        if(this.limitMonitorCS.Include_Queries__c){
            monitorLimit('Query Count', Limits.getLimitQueries(), Limits.getQueries());
            monitorLimit('Query Rows', Limits.getLimitQueryRows(), Limits.getQueryRows());
            monitorDatabaseTime();
        }
    }
    
    private void monitorDatabaseTime(){
        monitorLimit('Database Time', Limits.getLimitDatabaseTime(), Limits.getDatabaseTime());
    }
    
    private void monitorFutureCalls(){
        if(this.limitMonitorCS.Include_Future_Calls__c){
            monitorLimit('Future Calls', Limits.getLimitFutureCalls(), Limits.getFutureCalls());
        }
    }
    
    private void monitorHeapSize(){
        if(this.limitMonitorCS.Include_Heap_Size__c){
            monitorLimit('Heap Size', Limits.getLimitHeapSize(), Limits.getHeapSize());
        }
    }
    
    private void monitorQueueJobs(){
        if(this.limitMonitorCS.Include_Queue_Jobs__c){
            monitorLimit('Queueable Jobs', Limits.getLimitQueueableJobs(), Limits.getQueueableJobs());
        }
    }
    
    private void monitorAggregateQueries(){
        if(this.limitMonitorCS.Include_Aggregate_Queries__c){
            monitorLimit('Aggregate Queries', Limits.getLimitAggregateQueries(), Limits.getAggregateQueries());
        }
    }
    
    private void monitorCallouts(){
        if(this.limitMonitorCS.Include_Callouts__c){
           monitorLimit('Callouts', Limits.getLimitCallouts(), Limits.getCallouts()); 
        }
    }
    
    private void monitorEmailInvocations(){
        if(this.limitMonitorCS.Include_Email_Invocations__c){
           monitorLimit('Email Invocations', Limits.getLimitEmailInvocations(), Limits.getEmailInvocations()); 
        }
    }
    
    private void monitorFindSimilarCalls(){
        if(this.limitMonitorCS.Include_Find_Similar_Calls__c ){
            monitorLimit('Find Similar Calls', Limits.getLimitFindSimilarCalls(), Limits.getFindSimilarCalls());
        }
    }
    
    private void monitorLimit(String limitMonitored, Integer availableLimit, Integer currentUsage){
        if(availableLimit == 0){
            return;
        }
        checkUsage(limitMonitored, availableLimit, currentUsage);
    }
    
    private void checkUsage(String limitMonitored, Integer availableLimit, Integer currentUsage){
        Double percentUsage = (Double.valueOf(currentUsage)/Double.valueOf(availableLimit) * 100);
        if(percentUsage >= this.threshold){
            this.limitsHit.add(limitMonitored);
        }
        printUsage(limitMonitored, percentUsage);
    }
    
    private void printUsage(String limitMonitored, Double percentUsage){
        if(this.limitMonitorCS.Print_Usage_To_Console__c){
            System.debug(LoggingLevel.WARN, limitMonitored + ' Percent Usage = ' + percentUsage + '%');
        }
    }
    
    private void buildMonitoringObjects(){
        if(!this.limitsHit.isEmpty()){
            Limit_Monitoring__c lm = new Limit_Monitoring__c();
            lm.Class_Name__c = this.className;
            lm.Limits__c = String.join(this.limitsHit, ';');
            lm.Threshold_Percentage__c = this.threshold;
            lm.Transaction_Id__c = Request.getCurrent().getRequestId();
            this.lms.add(lm);
        }        
    }
    
    private void handleLimitMonitorRecord(){
        if(!this.lms.isEmpty()){
            LimitMonitoringFuture.handleLimitMonitoring(JSON.serialize(this.lms, true)); 
        } 
    }

}