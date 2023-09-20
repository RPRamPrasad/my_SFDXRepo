/**
 * @description - Used as an external endpoint to create Billing Request Cases
 */
@RestResource(urlMapping='/ACMT_Case_Rest/*')
global without sharing class ACMT_Case_Rest {

    private static ACMT_Case_Response__mdt res = new ACMT_Case_Response__mdt();
    /**
     * @description - Takes in a Case and User record and if no matching Case is found creates a Case and returns the Case number to the user
     * @param caseRecord : Case the user is trying to create
     * @param userRecord : Agent that the Case is being assigned to
     * @return - string to let the user know if the Case was created or if an error occured
     */
    @HttpPost
    global static ACMT_Case_Response__mdt handleRequest(Case caseRecord, User userRecord) {
        Billing_Participant__c bp = new Billing_Participant__c();
        List<Billing_Participant__c> secureBP = Security.stripInaccessible(AccessType.READABLE, [SELECT ParticipantAccountId__c, BillingAccountID__r.Name FROM Billing_Participant__c WHERE BillingAccountID__r.Name = :caseRecord.PolicyNumber__c limit 1]).getRecords(); //Checks for user permissions to ensure FLS 
        if(secureBP.isEmpty()){
            RestContext.response.statusCode = 404;
            res.Message__c = 'invalid billing account';
            return res;
        }else{
            bp = secureBP[0];
        }

        String nameComp = '%' + userRecord.State_Agent_Code__c + '%';
        List<User> usersComp = new List<User>();
        usersComp = Security.stripInaccessible(AccessType.READABLE, [SELECT id FROM User WHERE alias = :userRecord.Alias AND State_Agent_Code_List__c LIKE :nameComp AND IsActive = true LIMIT 1]).getRecords();
        if(usersComp.isEmpty()){
            RestContext.response.statusCode = 404;
            res.Message__c = 'User not found for selected State Agent Code';
            return res;
        }else{
            userRecord.id = usersComp[0].Id;
        }
        
        List<Case> c = Security.stripInaccessible(AccessType.READABLE, [Select id,CaseNumber,CreatedDate FROM Case WHERE Type = :caseRecord.Type AND Status = 'Open' AND PolicyNumber__c = :caseRecord.PolicyNumber__c]).getRecords(); //Checks for user permissions to ensure FLS 
        
        try{
            if(c.IsEmpty()){
                if(caseRecord.Type == 'Account/Policy Breakdown' || caseRecord.Type == 'Bill Explanation' || caseRecord.Type == 'Hardship' || caseRecord.Type == 'Catastrophe'){
                    String appCode = caseRecord.App_Code__c;
                    Date dateFrom = caseRecord.Date_From__c; 
                    Date dateTo = caseRecord.Date_To__c;
                    Date dueDate = caseRecord.Bill_Due_Date__c;
                    String policyNumber = caseRecord.PolicyNumber__c;
                    CreateBillingRequestOSCCase.CreateECRMCaseWrapper createECRMWrapper = new CreateBillingRequestOSCCase.CreateECRMCaseWrapper();
                    createECRMWrapper.accountId = (String)bp.ParticipantAccountId__c;
                    createECRMWrapper.appCode = appCode;
                    createECRMWrapper.dateFrom = dateFrom;
                    createECRMWrapper.dateTo = dateTo;
                    createECRMWrapper.billDueDate = dueDate;
                    createECRMWrapper.policyNumber = policyNumber;
                    createECRMWrapper.type = caseRecord.Type;
                    createECRMWrapper.userId = userRecord.Id;
                    res.CaseNumber__c = CreateBillingRequestOSCCase.createECRMCase(createECRMWrapper);
                    res.Message__c = 'Case is Successfully created in Salesforce';
                    RestContext.response.statusCode = 201;
                }
                else{
                    res.Message__c = 'The Case type you have entered is not supported.';
                    RestContext.response.statusCode = 200;
                }
            }
            else{
                String createDate = c[0].CreatedDate.format();
                res.CaseNumber__c = c[0].CaseNumber;
                res.Message__c = 'A Case was created on ' + createDate + ' with Case Number ' + c[0].CaseNumber;
                RestContext.response.statusCode = 200;
            }
        } catch (Exception e) {
            LoggingService.logHandledException(e, 'ACMT_Case_Rest', 'handleRequest', System.LoggingLevel.ERROR);
            res.Message__c = 'Case creation failed with error: ' + e.getMessage();
            RestContext.response.statusCode = 400;
        }
        return res;
    }
}