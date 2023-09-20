/**
* @author Team NSYNC
* @date 12/1/2021
* @description Replays share records
*/
public with sharing class AT3_ShareReplay implements Schedulable { 
/**
* @description execute Replays share records from that Failed
* @param sc a SchedulableContext object
* TPTransactionID__c contains ParentId
* Trigger__c contains UserOrGroupId
* Stack_Trace__c is only for deletes and it constains the InsurancePolicyShare Id
* Skip specific errors that can not be reprocessed
* 
*/    
    public void execute(SchedulableContext sc) {
        List<InsurancePolicyShare> insurancePolicyShareInsertList = new List<InsurancePolicyShare>();
        List<InsurancePolicyShare> insurancePolicyShareDeleteList = new List<InsurancePolicyShare>();
        List<ExceptionLog__c> exceptionLogList = [SELECT Id,Method__c,Stack_Trace__c,Exception_message__c,TPTransactionId__c,Trigger__c FROM ExceptionLog__c  where Class__c = 'UTIL_InsurancePolicyShares' WITH SECURITY_ENFORCED LIMIT 1000];
        for (ExceptionLog__c anExceptionLog:exceptionLogList) {
            if ('unable to obtain exclusive access to this record'.equalsIgnoreCase(anExceptionLog.Exception_message__c)) {
                if ('insertInsurancePolicyShares'.equalsIgnoreCase(anExceptionLog.Method__c)) {
                    insurancePolicyShareInsertList.add(createShare(anExceptionLog));
                }	
                else {
                    insurancePolicyShareDeleteList.add(addId(createShare(anExceptionLog), anExceptionLog));
                }
            }
        }
        UTIL_InsurancePolicyShares.insertInsurancePolicyShares(insurancePolicyShareInsertList);
        UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(insurancePolicyShareDeleteList);
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPSERTABLE, exceptionLogList);
        delete decision.getRecords();
    }
    private InsurancePolicyShare addId(InsurancePolicyShare anInsurancePolicyShare, ExceptionLog__c anExceptionLog) {
        anInsurancePolicyShare.Id = anExceptionLog.Stack_Trace__c;
		return anInsurancePolicyShare;        
    }
    private InsurancePolicyShare createShare(ExceptionLog__c anExceptionLog) {
        InsurancePolicyShare anInsurancePolicyShare = new InsurancePolicyShare();
        anInsurancePolicyShare.ParentId = anExceptionLog.TPTransactionId__c;
        anInsurancePolicyShare.UserOrGroupId = anExceptionLog.Trigger__c;
        anInsurancePolicyShare.AccessLevel = 'Read';
        anInsurancePolicyShare.RowCause = 'Manual';
		return anInsurancePolicyShare;       
    }
}