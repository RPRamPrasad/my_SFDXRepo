/**
@author CustomerView
@owner Team Atlas
@name CCV_AccountNoteAlertsStrip
@createDate 12/12/2022
@ModifiedDate 
@description This class is used by LWC accountNoteAlerts to fetch Account data on load
@version 1.0
*/
public with sharing class CCV_AccountNoteAlertsStrip {
    /**
    * @description This method is used to retrieve account notes alerts
    * @name : fetchAccountNoteAlerts
    * @param recordId : input record id
    * @param objectApiName : input object api name
    * @return List<AccountAlert> : output AccountAlert
    */
    @AuraEnabled (cacheable=true)
    public static List<AccountAlert> fetchAccountNoteAlerts(String recordId, String objectApiName) {
        try{
            String accountId;
            List<AccountAlert> allAlerts = new List<AccountAlert>();
            List<Account_Note__c> retAccountNotes = new List<Account_Note__c>();
            List<Case_Note__c> retCaseNotes = new List<Case_Note__c>();
            List<Opportunity_Note__c> retOpportunityNotes = new List<Opportunity_Note__c>();
            switch on objectApiName {
                when 'Account' {
                    accountId = recordId;
                    retAccountNotes = getAccountNoteDetails(recordId);
                    retCaseNotes = getCaseNoteDetails(recordId);
                    retOpportunityNotes = getOpportunityNoteDetails(recordId);
                }
                when 'Case' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromCase(recordId);
                    retAccountNotes = getAccountNoteDetails(accountId);
                    retCaseNotes = getCaseNoteDetails(accountId);
                    retOpportunityNotes = getOpportunityNoteDetails(accountId);
                }
                when 'Opportunity' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromOpportunity(recordId);
                    retAccountNotes = getAccountNoteDetails(accountId);
                    retCaseNotes = getCaseNoteDetails(accountId);
                    retOpportunityNotes = getOpportunityNoteDetails(accountId);
                }
                when 'InsurancePolicy' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromInsurancePolicy(recordId);
                    retAccountNotes = getAccountNoteDetails(accountId);
                    retCaseNotes = getCaseNoteDetails(accountId);
                    retOpportunityNotes = getOpportunityNoteDetails(accountId);
                }
                when 'Billing_Account__c' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromBillingAccount(recordId);
                    retAccountNotes = getAccountNoteDetails(accountId);
                    retCaseNotes = getCaseNoteDetails(accountId);
                    retOpportunityNotes = getOpportunityNoteDetails(accountId);
                }
                when 'Claim' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromClaim(recordId);
                    retAccountNotes = getAccountNoteDetails(accountId);
                    retCaseNotes = getCaseNoteDetails(accountId);
                    retOpportunityNotes = getOpportunityNoteDetails(accountId);
                }
                when 'FinancialAccount__c' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromFinancialAccount(recordId);
                    retAccountNotes = getAccountNoteDetails(accountId);
                    retCaseNotes = getCaseNoteDetails(accountId);
                    retOpportunityNotes = getOpportunityNoteDetails(accountId);
                }
            }
            allAlerts.addAll(createAccountAlertList(retAccountNotes, accountId));
            allAlerts.addAll(createCaseAlertList(retCaseNotes, accountId));
            allAlerts.addAll(createOpportunityAlertList(retOpportunityNotes, accountId));
            return allAlerts;
        }
        catch(Exception e){
            throw new AuraHandledException('Please refresh/reload page again');
        }
    }

    private static List<AccountAlert> createAccountAlertList(List<Account_Note__c> accountNoteList, String accountId) {
        List<AccountAlert> accountAlerts = new List<AccountAlert>();
        for (Account_Note__c note : accountNoteList){
            AccountAlert alert = new AccountAlert();
            alert.description = note.Comments__c;
            alert.accountName = 'Account'; //note.Account__r.Name
            alert.createdBy = note.CreatedBy.name;
            alert.setCreatedDate(note.CreatedDate);
            alert.setLink('/one/one.app#/sObject/' + note.Id);
            alert.id = accountId;
            accountAlerts.add(alert);
        }
        return accountAlerts;
    }

    private static List<Account_Note__c> getAccountNoteDetails(String accountId) {
        List<Account_Note__c> accounttNoteAlerts = new List<Account_Note__c>();
        SObjectAccessDecision  securityDecision = Security.stripInaccessible(
                AccessType.READABLE,
                [
                    SELECT Id, Comments__c, Account__c, Account__r.Name, CreatedDate, CreatedBy.name
                    FROM Account_Note__c
                    WHERE Account__c = :String.escapeSingleQuotes(accountId) AND Alert__c = TRUE
                ],
            	false
            );
        if(securityDecision.getRemovedFields().get('Account_Note__c') == null){ 
            accounttNoteAlerts = securityDecision.getRecords();
        }
        return accounttNoteAlerts;
    }

    private static List<AccountAlert> createCaseAlertList(List<Case_Note__c> caseNoteList, String accountId) {
        List<AccountAlert> accountAlerts = new List<AccountAlert>();
        for (Case_Note__c note : caseNoteList) {
            AccountAlert alert = new AccountAlert();
            alert.description = note.Comments__c;
            alert.accountName = 'Case'; //note.Account__r.Name
            alert.createdBy = note.CreatedBy.name;
            alert.setCreatedDate(note.CreatedDate);
            alert.setLink('/one/one.app#/sObject/' + note.Id);
            alert.id = accountId;
            accountAlerts.add(alert);
        }
        return accountAlerts;
    }

    private static List<Case_Note__c> getCaseNoteDetails(String accountId) {
        List<Case_Note__c> caseNotesAlerts = new List<Case_Note__c>();
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', accountId, Account.class);
        List<Case> caseIds = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Id FROM Case WHERE AccountId = :String.escapeSingleQuotes(accountId)]
            )
            .getRecords();

        if (caseIds.size() > 0) {
            List<Id> caseParentIds = new List<Id>();
            for (Case caseId : caseIds) {
                caseParentIds.add(caseId.Id);
            }
            SObjectAccessDecision  securityDecision = Security.stripInaccessible(
                    AccessType.READABLE,
                    [
                        SELECT Id, CreatedBy.name, Case__r.CaseNumber, CreatedDate, Comments__c, Alert__c
                        FROM Case_Note__c
                        WHERE Case__c IN :caseParentIds AND Alert__c = TRUE
                        LIMIT 200
                    ],
                	false
                );
        	if(securityDecision.getRemovedFields().get('Case_Note__c') == null){ 
            	caseNotesAlerts = securityDecision.getRecords();
            }
        }
        return caseNotesAlerts;
    }

    private static List<AccountAlert> createOpportunityAlertList(
        List<Opportunity_Note__c> opptyNotesList,
        String accountId
    ) {
        List<AccountAlert> accountAlerts = new List<AccountAlert>();
        for (Opportunity_Note__c note : opptyNotesList) {
            AccountAlert alert = new AccountAlert();
            alert.description = note.Comments__c;
            alert.accountName = 'Opportunity'; //note.Account__r.Name
            alert.createdBy = note.CreatedBy.name;
            alert.setCreatedDate(note.CreatedDate);
            alert.setLink('/one/one.app#/sObject/' + note.Id);
            alert.id = accountId;
            accountAlerts.add(alert);
        }
        return accountAlerts;
    }

    private static List<Opportunity_Note__c> getOpportunityNoteDetails(String accountId) {
        List<Opportunity_Note__c> oppAlertList = new List<Opportunity_Note__c>();
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', accountId, Account.class);
        List<Opportunity> opptys = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Id FROM Opportunity WHERE AccountId = :String.escapeSingleQuotes(accountId)]
            )
            .getRecords();

        if (opptys.size() > 0) {
            List<Id> parentOpptyIds = new List<Id>();
            for (Opportunity opp : opptys) {
                parentOpptyIds.add(opp.Id);
            }

            SObjectAccessDecision  securityDecision = Security.stripInaccessible(
                    AccessType.READABLE,
                    [
                        SELECT Id, CreatedBy.name, Opportunity__r.Name, CreatedDate, Comments__c, Alert__c
                        FROM Opportunity_Note__c
                        WHERE Opportunity__c IN :parentOpptyIds AND Alert__c = TRUE
                        LIMIT 200
                    ],
                	false
                );
        	if(securityDecision.getRemovedFields().get('Opportunity_Note__c') == null){ 
            	oppAlertList = securityDecision.getRecords();
            }
        }
        return oppAlertList;
    }

    /**
    * @description a wrapper for the AccountAlert
    */
    public with sharing class AccountAlert{
        
        /**
        * @description gets/sets id
        */
        @AuraEnabled
        public String id{get;set;}
        
        /**
        * @description gets/sets link
        */
        @AuraEnabled
        public String link{get;set;}
        
        /**
        * @description gets/sets description
        */
        @AuraEnabled
        public  String description{get;set;}
        
        /**
        * @description gets/sets accountName
        */
        @AuraEnabled
        public  String accountName{get;set;}
        
        /**
        * @description gets/sets createdBy
        */
        @AuraEnabled
        public  String createdBy{get;set;}
        
        /**
        * @description gets/sets createdDate
        */
        @AuraEnabled
        public DateTime createdDate{get;set;} 

        /**
        * @description sets Link
        * @param link
        */
        public void setLink(String link){
            this.link = link;
        }

        /**
        * @description get Link
        * @return link
        */
        public String getLink(){
            return link;
        }
        
        /**
        * @description set CreatedDate
        * @param createdDate
        */
        public void setCreatedDate(DateTime createdDate){
            this.createdDate = createdDate;
        }
        
        /**
        * @description get CreatedDate
        * @return createdDate
        */
        public Datetime getCreatedDate(){
            return createdDate;
        }        
    } 
}