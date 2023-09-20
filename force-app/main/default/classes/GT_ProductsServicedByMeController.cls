/**
* Author : Team Kraken
* Date Created : 9/5/2018
* @description GT_ProductsServicedByMeController: retrieves OData for GT_ProductsServicedByMe lightning component
* Version : 1.0
*/

public with sharing class GT_ProductsServicedByMeController {
    
    @TestVisible
    private static List<ProductsServicedByMe__c> mockedList = new List<ProductsServicedByMe__c>();
    @TestVisible private static Boolean isCatch = false;
    /**
     * @description ProductsServicedByMeWrapper
     */
    public with sharing class ProductsServicedByMeWrapper { 
        /**
         * @description productType
         */
        @AuraEnabled
        public String productType{get;set;}
        /**
         * @description expirationDate
         */
        @AuraEnabled
        public String expirationDate{get;set;}
        /**
         * @description productLine
         */
        @AuraEnabled       
        public String productLine{get; set;}
        /**
         * @description carrierName
         */
        @AuraEnabled
        public String carrierName{get; set;}
        /**
         * @description id 
         */
        @AuraEnabled
        public String id{get; set;}
        /**
         * @description name
         */
        @AuraEnabled
        public String name{get; set;}
    }
    /**
     * @description getProductsServicedByMe
     * @param recordId 
     * @return  `List<ProductsServicedByMeWrapper>`
     * @exception 
     */
    @AuraEnabled
    public static List<ProductsServicedByMeWrapper> getProductsServicedByMe(String recordId) {
        List<ProductsServicedByMe__c> oDataProductsServicedByMeList = new List<ProductsServicedByMe__c>();
        List<ProductsServicedByMeWrapper> aProductsServicedByMeWrapperList;
        
        Map<String,Account> clientIdNameMap;
        if (Test.isRunningTest()) {
            String accId = '001q000000tG5BFAA0';
            Account tempAccount = new Account(Id = accId, Name = 'ERROR', ClientIdentifier__c  = '12345678901');
            clientIdNameMap = new Map<String, Account>{'12345678901' => tempAccount};
		} else {
            clientIdNameMap = UTIL_CustomerGroupData.getClientIdsForGroup(recordId);
        }
        List<String> clientIdList = new List<String>(clientIdNameMap.keyset());
        
        try {
            if (Test.isRunningTest()) {
                oDataProductsServicedByMeList = mockedList;
                if (null != oDataProductsServicedByMeList && !oDataProductsServicedByMeList.isEmpty() && oDataProductsServicedByMeList[0].ProductType__c.equals('ERROR')) {
                    throw new DMLException('THIS IS AN ERROR');    
                }
            } else {
                
                oDataProductsServicedByMeList = Security.stripInaccessible(AccessType.READABLE, [
                    SELECT 
                    	Id,
                        ProductType__c,
                        ExpirationDate__c,
                        ProductLine__c, 
                        CarrierName__c,
                        CarrierNameOther__c,
                        Customer__r.ClientIdentifier__c 
                    FROM 
                    	ProductsServicedByMe__c 
                    WHERE 
                    	Customer__r.ClientIdentifier__c In :clientIdList
                    ORDER BY 
                    	ProductLine__c, CreatedDate DESC
                ]).getRecords();
            }
            ProductsServicedByMeWrapper aProductsServicedByMeWrapper = new ProductsServicedByMeWrapper();
            aProductsServicedByMeWrapper.carrierName = '';
            aProductsServicedByMeWrapper.expirationDate = '';
            aProductsServicedByMeWrapper.productLine = '';
            aProductsServicedByMeWrapper.productType = '';
            aProductsServicedByMeWrapper.name = '';
            aProductsServicedByMeWrapperList = new List<ProductsServicedByMeWrapper>();
            GetProductsServicedByMeMethodWrapper getProductsWrap = new GetProductsServicedByMeMethodWrapper();
            getProductsWrap.aProductsServicedByMeWrapperList = aProductsServicedByMeWrapperList;
            getProductsWrap.clientIdNameMap = clientIdNameMap;
            aProductsServicedByMeWrapperList = getProductsServicedByMeMethod(oDataProductsServicedByMeList, aProductsServicedByMeWrapper, getProductsWrap);
        }
        catch (Exception e) {
            LoggingService.logHandledException(e, 'GT_ProductsServicedByMeController', 'getProductsServicedByMe', System.LoggingLevel.ERROR);
            throw new AuraHandledException('QUERY ERROR');
        }
        return aProductsServicedByMeWrapperList;  
    }

    private class GetProductsServicedByMeMethodWrapper{
        List<ProductsServicedByMeWrapper> aProductsServicedByMeWrapperList;
        Map<String,Account> clientIdNameMap;
    }

    private static List<ProductsServicedByMeWrapper> getProductsServicedByMeMethod(List<ProductsServicedByMe__c> oDataProductsServicedByMeList,  ProductsServicedByMeWrapper aProductsServicedByMeWrapper, GetProductsServicedByMeMethodWrapper getWrap){
        ProductsServicedByMeWrapper aProductsWrapper = aProductsServicedByMeWrapper;
        for(ProductsServicedByMe__c selectProductsServicedByMe : oDataProductsServicedByMeList) {
            aProductsWrapper = new ProductsServicedByMeWrapper();
            aProductsWrapper.id = selectProductsServicedByMe.Id;
            aProductsWrapper.productType = selectProductsServicedByMe.ProductType__c;
            aProductsWrapper.expirationDate = formatDate(selectProductsServicedByMe.ExpirationDate__c);
            aProductsWrapper.productLine = selectProductsServicedByMe.ProductLine__c;
            aProductsWrapper.name = toProperCase(getWrap.clientIdNameMap.get(selectProductsServicedByMe.Customer__r.ClientIdentifier__c).Name);
            
            if ('Other'.equalsIgnoreCase(selectProductsServicedByMe.CarrierName__c)) {
                aProductsWrapper.carrierName = selectProductsServicedByMe.CarrierNameOther__c;
            }
            else {
                aProductsWrapper.carrierName = selectProductsServicedByMe.CarrierName__c;
            }
            getWrap.aProductsServicedByMeWrapperList.add(aProductsWrapper);  
        }
        return getWrap.aProductsServicedByMeWrapperList;
    }

    /**
     * @description formatDate
     * @param dateToFormat 
     * @return  `string`
     */
    public static string formatDate(Date dateToFormat) {
        if(null != dateToFormat) { 
            Datetime dateTimeObject =  Datetime.newInstanceGmt(dateToFormat.year(),dateToFormat.month(),dateToFormat.day());
            return dateTimeObject.formatGmt('MM/dd/yyyy');
        }
        else {
            return '';
        }
    }
    /**
     * @description toProperCase
     * @param value 
     * @return  `String`
     */
    public static String toProperCase(String value) {
            String val = value;
            // Normalize - Convert to lowercase
            val = val.toLowerCase();
            // Hold each word
            List<String> pieces = new List<String>();
            // Split
            for(String s : val.split(' ')) {
                // Capitalize each piece
                s = s.capitalize();
                // Add to pieces
                pieces.add(s);
            }
            // Join
            return String.join(pieces, ' ');
        }
     /**
      * @description canViewNewButton
      * @return  `Boolean`
      */
    @AuraEnabled
    public static Boolean canViewNewButton() {
        try{
            if(isCatch){
            throw new DMLException();
        }
        return AT_ProfileAccess.hasCreateNewPSBMAccess();
        }
        catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
            logHolder.info('InsurancePolicyController', e.getMessage() + System.now());
            logHolder.writeToLogExceptionObject();
            return null;
          }
    }
    
}