/**
* Author : Team Astro
* Date Created : 08/22/2023
* @description : Retrieves policy parent object data for JOT related to field
* Version : 1.0
*/ 
public with sharing class JustOneThingPolicyController {

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdInsurancePolicies(String householdId) {
        List<InsurancePolicy> policies = new List<InsurancePolicy>();
        try{
            String queryToExecute = JOTConstants.INSURANCE_POLICY_FIELDS + JOTConstants.INSURANCE_POLICY_FROM_OBJECT + JOTConstants.FINSERV_HOUSEHOLD_WHERE;
            policies = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformInsurancePolicies(policies);
    }

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountInsurancePolicies(String accountId) {
        List<InsurancePolicy> policies = new List<InsurancePolicy>();
        try{
            String queryToExecute = JOTConstants.INSURANCE_POLICY_FIELDS + JOTConstants.INSURANCE_POLICY_FROM_OBJECT + JOTConstants.NAMED_INSURED_WHERE;
            policies = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformInsurancePolicies(policies);
    }

    public static List<ActivityOutlineSObjectWrapper> transformInsurancePolicies(List<InsurancePolicy> policyList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(InsurancePolicy policyRecord : policyList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = policyRecord.Id;
            soWrapper.status = policyRecord.Status;
            soWrapper.sobjectType = String.valueOf(policyRecord.getSObjectType());

            String policySubject = policyRecord.PolicyDescription;
            if(String.isBlank(policySubject)) {
                policySubject = '[No Description]';
            }
            soWrapper.recordSubject = policySubject + ' - ' + policyRecord.Name;
            soWrapper.displayIconName = 'standard:work_plan';
            soWrapper.isClosed = policyRecord.Status == 'Terminated';

            if(!soWrapper.isClosed){
                sobjectList.add(soWrapper);
            }
            
        }
        return sobjectList;
    }
}