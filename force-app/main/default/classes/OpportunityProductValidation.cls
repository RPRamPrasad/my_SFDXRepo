/**
 * Author : ScrumDwags
 * Date Created : 12/25/2021
 * @description : This is a helper class to validate Opportunity Product and LOB using Requested Effective Date
 */
public with sharing class OpportunityProductValidation {
    public static final String OPPORTUNITY_PRODUCT_FIELDS = ' SELECT Category_Name__c, CreatedById, Is_Created_From_UI__c, LastModifiedById, Lob_Cd__c, Lob_Name__c, Name, OwnerId, Product_Description__c, Product_Form_Num__c, Product_Id__c, Product_Line__c, Product_System_Name__c, Product_End_Date__c, Product_Postal_State__c, Product_Start_Date__c,  Product_Type__c, Status__c, ErrorFutureDays__c, ErrorPastDays__c ';
    public static final String OPPORTUNITY_PRODUCT_FROM_OBJECT = ' FROM OpportunityProduct__c ';
    private static final List<String> LINE_OF_BUSINESS_FILTER = new String[] {'Auto', 'Fire', 'Life','Health'};
    private static final String OPPORTUNITY_PRODUCT_FIELDS_ORDERBY = ' ORDER BY Product_Description__c,Product_System_Name__c';


    /**
     * @description Inner class wrapper to describe Opportunity Details object
     */
    public with sharing class OpportunityDetails {
        /** @description effectiveDate */
        @AuraEnabled 
        public Date effectiveDate {get; set;}
        /** @description stateCode */
        @AuraEnabled
        public String stateCode {get; set;}
        /** @description lob */
        @AuraEnabled
        public String lob {get; set;}
        /** @description productDescription */
        @AuraEnabled
        public String productDescription {get; set;}
        /** @description productSystemName */
        @AuraEnabled
        public String productSystemName {get; set;}        
   }
    
     /**
     * @name getOpportunityProducts
     * @description Method to get opportunity products
	 * @param lob
     * @param stateCode
	 * @param effectiveDate
     * @return productDetails list
     */ 
   @AuraEnabled(cacheable=true)
   public static List<OpportunityProduct__c> getOpportunityProducts(String lob, String stateCode, Date effectiveDate) {
       String whereCondition = ' WHERE Lob_Name__c =: lob AND Product_Start_Date__c <=: effectiveDate AND Product_End_Date__c >=: effectiveDate';   
       
       if(String.isBlank(lob) || effectiveDate == null) {
           return null;
       } 
            
       if((LINE_OF_BUSINESS_FILTER).contains(lob)) {
           whereCondition += ' AND Product_Postal_State__c =: stateCode';
       }
       
       String queryToExecute = OPPORTUNITY_PRODUCT_FIELDS + OPPORTUNITY_PRODUCT_FROM_OBJECT + whereCondition + OPPORTUNITY_PRODUCT_FIELDS_ORDERBY;
       List<OpportunityProduct__c> productDetails = new List<OpportunityProduct__c> ();  
       try {
           productDetails = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
       }
       catch(Exception e) {
            LoggingService.logHandledException(e, 'OpportunityProductValidation','getOpportunityProducts', System.LoggingLevel.ERROR);
        }
       
       if(productDetails.size()>0) {
           return productDetails;
       }
       return null;
    }
 
    /**
     * @name validateOpportunityProduct
     * @description Method to validate if Product is Active or not
     * @param oppDetails
     * @return OpportunityProduct Object
     */    
    @AuraEnabled(cacheable=true)
   public static OpportunityProduct__c validateOpportunityProduct(OpportunityProductValidation.OpportunityDetails oppDetails) {
      
       Date effectiveDate = oppDetails.effectiveDate;
       String stateCode = oppDetails.stateCode;
       String lob = oppDetails.lob;
       String productDescription = oppDetails.productDescription;
       String productSystemName = oppDetails.productSystemName; 
      
       if( String.isBlank(lob) || String.isBlank(productDescription) || effectiveDate == null) {
           return null;
       }
          
       String queryToExecute = OPPORTUNITY_PRODUCT_FIELDS + OPPORTUNITY_PRODUCT_FROM_OBJECT + buildWhereCondition(oppDetails) + ' LIMIT 1 ';  
       List<OpportunityProduct__c> opportunityProductList = new List<OpportunityProduct__c>();
       try {     
           opportunityProductList = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        
           if(opportunityProductList != null && !opportunityProductList.isEmpty()){
            return opportunityProductList.get(0);
        }
        } catch(Exception e) {
            LoggingService.logHandledException(e, 'OpportunityProductValidation','validateOpportunityProduct', System.LoggingLevel.ERROR);
        }
       
       return null;
	}  

    /**
     * @name getProductInformation
     * @description Method to get Productinformation
     * @param oppDetails
     * @return OpportunityProduct Object
     */  

    @AuraEnabled(cacheable=true)
    public static OpportunityProduct__c getProductInformation(OpportunityProductValidation.OpportunityDetails oppDetails) {
        String stateCode = oppDetails.stateCode;
     	String lob = oppDetails.lob;
     	String productDescription = oppDetails.productDescription;
        String whereCondition = ' WHERE Lob_Name__c =: lob AND Product_Description__c =: productDescription ';
        
        if( String.isBlank(lob) || String.isBlank(productDescription)) {
           return null;
        }
        
		if((LINE_OF_BUSINESS_FILTER).contains(lob)) {
           whereCondition += ' AND Product_Postal_State__c =: stateCode';
        }
        
        String queryToExecute = OPPORTUNITY_PRODUCT_FIELDS + OPPORTUNITY_PRODUCT_FROM_OBJECT + whereCondition;
        List<OpportunityProduct__c> productsIdentified = new List<OpportunityProduct__c>();
        try {     
           productsIdentified = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        
           if(productsIdentified != null && !productsIdentified.isEmpty()){
            return productsIdentified.get(0);
        }
        } catch(Exception e) {
            LoggingService.logHandledException(e, 'OpportunityProductValidation','getProductInformation', System.LoggingLevel.ERROR);
        }
       
       return null;
	}    
    /**
     * @name Mehod to buildWhereCondition for opportunityproduct validation method for different lob's.
     * @description Method to validate if Product is Active or not
     * @param  oppDetails
     * @return whereCondition
     */
	public static String buildWhereCondition(OpportunityProductValidation.OpportunityDetails oppDetails) {
        String whereCondition = ' WHERE Lob_Name__c = :lob AND Product_Description__c = :productDescription AND Product_Start_Date__c <= :effectiveDate AND Product_End_Date__c >= :effectiveDate ';
		
        if(String.isNotBlank(oppDetails.productSystemName)){
            whereCondition += ' AND Product_System_Name__c = :productSystemName ';   
        }
       
        if((LINE_OF_BUSINESS_FILTER).contains(oppDetails.lob)) {
            whereCondition += ' AND Product_Postal_State__c = :stateCode';
        }	
        return whereCondition;
    }
}