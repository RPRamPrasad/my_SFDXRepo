/**
 * @author Team STARK
 * @owner Team STARK
 * @name UTIL_HouseholdMemberHelper_Additional
 * @CreateDate 10/27/2021
 * @modifiedDate
 * @description Common Helper class to access various account and AccontContactRelation related queries.
 *  Class is udated with Account and related objects operations created or edited through Household page.
 *  Class is used by Manage Household Members operations - add, move and remove
 *  This is a without sharing class which is used to query all accounts needed to display on members page
 *  note that no SPI, PII, HIPPA complince fields are being query and shared for visibility
 *  @version 1.0
*/
public without sharing class UTIL_HouseholdMemberHelper_Additional {
   /**
    * @description To retrieve members when HHAcctid is provided
    * @name : getAllActiveMembersFromHousehold
    * @param hhAcctId : input account household id
    * @return List<AccountContactRelation> : output AccountContactRelation record
    */
    public static List<AccountContactRelation> getAllActiveMembersFromHousehold(String hhAcctId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhAcctId, Account.class);
        return Security.stripInaccessible( 
            AccessType.READABLE, [
            SELECT Id, AccountId, ContactId, Contact.ClientIdentifier__c, Contact.name, IsActive,
                Contact.FirstName, Contact.LastName, Contact.Suffix, Contact.MiddleName, Contact.Salutation,
                FinServ__SourceSystemId__c, FinServ__PrimaryGroup__c, FinServ__Primary__c, Roles
		    FROM AccountContactRelation  
            WHERE AccountId = :String.escapeSingleQuotes(hhAcctId) AND IsActive = true AND FinServ__PrimaryGroup__c = true
        ])
        .getRecords();
        
    }

    /**
    * @description To retrieve all members when contactRecordId is provided
    * @name : getAllActiveMembersFromContactId
    * @param contactRecordId : input account household id
    * @return List<AccountContactRelation> : output AccountContactRelation record
    */
    public static List<AccountContactRelation> getAllActiveMembersFromContactId(String contactRecordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', contactRecordId, Contact.class);
        return Security.stripInaccessible(
            AccessType.READABLE,
            [ 
                SELECT Id, AccountId, IsActive,
                    FinServ__SourceSystemId__c, FinServ__PrimaryGroup__c, FinServ__Primary__c
                FROM AccountContactRelation  
                WHERE ContactId = :String.escapeSingleQuotes(contactRecordId) 
                AND IsActive = true AND FinServ__PrimaryGroup__c = true
            ]
        )
        .getRecords();
    }

}
