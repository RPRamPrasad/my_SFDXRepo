/** 
* @description case factory used to build retention cases 
* @Owner: Grumpycats
*/
public with sharing class CaseFactoryRetentionCase extends CaseFactory {
    
    private Double shoppingActLast30days;
    private Double shoppingActLast30to90days;
    private Double shoppingActLast90to1year;
    private Double shoppingActLast1to2years; 
    private Double shoppingActLast2to3years;
    private Date firstShoppedDate; 
    private Date lastShoppedDate;
    /**
     * @description setShoppingActLast30days
     * @param caseShoppingActLast30days 
     * @return  `CaseFactoryRetentionCase`
     */
    public CaseFactoryRetentionCase setShoppingActLast30days(Double caseShoppingActLast30days){
        this.shoppingActLast30days = caseShoppingActLast30days;
        return this;
    }
    /**
     * @description setShoppingActLast30to90days
     * @param caseShoppingActLast30to90days 
     * @return  `CaseFactoryRetentionCase`
     */
    public CaseFactoryRetentionCase setShoppingActLast30to90days(Double caseShoppingActLast30to90days){
        this.shoppingActLast30to90days = caseShoppingActLast30to90days;
        return this;
    }
    /**
     * @description setShoppingActLast90to1year
     * @param caseShoppingActLast90to1year 
     * @return  `CaseFactoryRetentionCase`
     */
    public CaseFactoryRetentionCase setShoppingActLast90to1year(Double caseShoppingActLast90to1year){
        this.shoppingActLast90to1year = caseShoppingActLast90to1year;
        return this;
    }
    /**
     * @description setShoppingActLast1to2years
     * @param caseShoppingActLast1to2years 
     * @return  `CaseFactoryRetentionCase`
     */
    public CaseFactoryRetentionCase setShoppingActLast1to2years(Double caseShoppingActLast1to2years){
        this.shoppingActLast1to2years = caseShoppingActLast1to2years;
        return this;
    }
    /**
     * @description setShoppingActLast2to3years
     * @param caseShoppingActLast2to3years 
     * @return  `CaseFactoryRetentionCase`
     */
    public CaseFactoryRetentionCase setShoppingActLast2to3years(Double caseShoppingActLast2to3years){
        this.shoppingActLast2to3years = caseShoppingActLast2to3years;
        return this;
    }
    /**
     * @description setFirstShoppedDate
     * @param caseFirstShoppedDate 
     * @return  `CaseFactoryRetentionCase`
     */
    public CaseFactoryRetentionCase setFirstShoppedDate(Date caseFirstShoppedDate){
        this.firstShoppedDate = caseFirstShoppedDate;
        return this;
    }
    /**
     * @description setLastShoppedDate
     * @param caseLastShoppedDate 
     * @return  `CaseFactoryRetentionCase`
     */
    public CaseFactoryRetentionCase setLastShoppedDate(Date caseLastShoppedDate){
        this.lastShoppedDate = caseLastShoppedDate;
        return this;
    }
    /**
     * @description buildCase
     * @param accountRecord 
     * @param ownerId 
     * @return  `Case`
     */
    public Case buildCase(SObject accountRecord, Id ownerId){
        Case newRetentionCase = new Case();
        if(accountRecord != null){
            newRetentionCase.Subject = ('Auto Shopping Alert - ' + accountRecord.get('Name'));
            newRetentionCase.Description = 'A customer is shopping for auto insurance elsewhere.'; //Change later
            newRetentionCase.ContactId = String.valueOf(accountRecord.get('PersonContactId'));
            newRetentionCase.AccountId = String.valueOf(accountRecord.get('Id'));
            newRetentionCase.OwnerId = ownerId;
            newRetentionCase.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION;
            newRetentionCase.Shopping_Activities_Last_30_Days__c = shoppingActLast30days;
            newRetentionCase.Shopping_Activities_Last_30_90_Days__c = shoppingActLast30to90days;
            newRetentionCase.Shopping_Activities_Last_90_Days_1_Year__c = shoppingActLast90to1year;
            newRetentionCase.Shopping_Activities_Last_1_2_Years__c = shoppingActLast1to2years;
            newRetentionCase.Shopping_Activities_Last_2_3_Years__c = shoppingActLast2to3years;
            newRetentionCase.First_Shopped_Date__c = firstShoppedDate;
            newRetentionCase.Last_Shopped_Date__c = lastShoppedDate;
            newRetentionCase.App_Code__c = 'SFDC Auto Shoppers Feed';
        }
        return newRetentionCase;
    }
}