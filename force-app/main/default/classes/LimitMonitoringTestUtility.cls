@isTest
public with sharing class LimitMonitoringTestUtility {
    private static String className1 = 'testclassName1';
    private static String className2 = 'testclassName2';
    private static Double threshold = 75.00;
    private static String transactionId1 = 'TID:12121212';

    /**
     * @description Inserts Limit_Monitoring__c record
     */ 
    public static void insertLMS(){
        List<Limit_Monitoring__c> lms = new List<Limit_Monitoring__c>();
        lms.add(buildLM(className1));
        lms.add(buildLM(className2));
        insert lms;
    }

    /**
     * @description Builds and returns a list of Limit_Monitoring__c records
     * @return List<Limit_Monitoring__c>
     */ 
    public static List<Limit_Monitoring__c> getLMS(){
        List<Limit_Monitoring__c> lms = new List<Limit_Monitoring__c>();
        lms.add(buildLM(className1));
        lms.add(buildLM(className2));
        return lms;
    }
    
    private static Limit_Monitoring__c buildLM(String className){
        Limit_Monitoring__c lm = new Limit_Monitoring__c();
        lm.Class_Name__c = className;
        lm.Limits__c = formatMultiselectPicklist(buildStringList());
        lm.Threshold_Percentage__c = threshold;
        lm.Transaction_Id__c = transactionId1;
        return lm;
    }
    
    private static List<String> buildStringList(){
        List<String> limitsHit = new List<String>();
        limitsHit.add('CPU Time');
        limitsHit.add('DML Statements');
        return limitsHit;
    }
    
    private static String formatMultiselectPicklist(List<String> limitsHit){
        return String.join(limitsHit, ';');
    }
}
