/**
  * @Name Batch_UpdateOppStagemanagement
  * @Author QuadCore
  * @description Batch Class that pulls the data from the insurance policy object, compares the data with the opportunity object based on client identifier, agent associated with the client, line of business, and product. 
    If any matches found, then the stage of the opportunity will be updated to closed won. 
  */
  global without sharing class Batch_UpdateOppStagemanagement implements Database.Batchable<sObject>, Database.StateFul{
    private static final String BATCH_CLASS_NAME = 'Batch_UpdateOppStagemanagement';
     private static final String EXECUTE_METHOD_NAME = 'execute';    
     private static final String EMAIL_SENDER = 'QC-AutoCloseLoadJob';
     private static final String EMAIL_SUBJECT = 'Opportunity Auto Close Product Update Needed';
     private static final String RICH_TEXT_NEW_LINE = '<br/> <br/> ';
     global List<String> productsNotFoundMap = new List<String>();
     private static Integer count = 0;
     private static String status = 'In Force';
     static final String PROXY_CONCAT = 'P';
 
     static final String CLOSED_WON = 'Closed Won';
     static final String SUB_STATUS_VALUE = 'Policy Issued';
     static final String STATUS_VALUE = 'System Closed Won';
   
     public static List<CM_AgreeSfProductMapping__mdt> mdtNames =[SELECT AgreeProductDescValue__c,SfProductDescValue__c FROM CM_AgreeSfProductMapping__mdt limit 1000];
     static  Map<String, List<String>> finalproductMap = convertTOMap(mdtNames);
     
     CS_AutoCloseBatch__c autoClosebatch = CS_AutoCloseBatch__c.getInstance();
      /**
     * @description This method is used to convert the custom metadata values to map.
     * @param  mdtNames List of CM_AgreeSfProductMapping__mdt values.
     * @return Map<String,String>
     */
     public static Map<String,List<String>> convertTOMap(List<CM_AgreeSfProductMapping__mdt> mdtNames){
         Map<String, List<String>> finalproductMap1 = new Map<String,List<String>>();
         for(CM_AgreeSfProductMapping__mdt mdd:mdtNames){
             List<String> values= new List<String>();
             if(finalproductMap1.containsKey(mdd.AgreeProductDescValue__c.toLowerCase())){
                finalproductMap1.get(mdd.AgreeProductDescValue__c.toLowerCase()).add(mdd.SfProductDescValue__c.toLowerCase());
             }
             else{
                 values.add(mdd.SfProductDescValue__c.toLowerCase());
                 finalproductMap1.put(mdd.AgreeProductDescValue__c.toLowerCase(),values);
             }
         }
         return finalproductMap1;
     }
     
     /**
      * @description start
      * @param bc 
      * @return  `Database.Querylocator`
      */
     global Database.Querylocator start(Database.BatchableContext bc) {
         Integer daysToLookBackIPData = (Integer)autoClosebatch.DaysToLookBackForIPData__c;
         String query = 'select id,EffectiveDate, NameInsured.ClientIdentifier__c,status,PolicyType,PolicyName,Servicing_Agent__r.Servicing_Agent_Associate_ID__c from InsurancePolicy where EffectiveDate = LAST_N_DAYS:'+daysToLookBackIPData+' and PolicyName !=null and PolicyType !=null and status=:status';
         return Database.getQueryLocator(query);        
     }
     private Map<String,String> getProductOwnerDetailsMap(Map<String,String> nameInsureClientProductMap,OpportunityWrapper oppWrapper,List<String> prodList){
         for(String prod:prodList){
             if(prod.equals(oppWrapper.product)){
                 nameInsureClientProductMap.put(oppWrapper.ownerId+'~'+oppWrapper.clientIdentifier+'~'+oppWrapper.product.toLowerCase(), oppWrapper.product.toLowerCase());
             }else{
                 nameInsureClientProductMap.put(oppWrapper.ownerId+'~'+oppWrapper.clientIdentifier+'~'+prod.toLowerCase(), prod.toLowerCase());
             }
         }
         return nameInsureClientProductMap;
     }
     /**
      * @description execute
      * @param bc 
      * @param insurancyPolicyList 
      */
      global void execute(Database.BatchableContext bc, List<InsurancePolicy> insurancyPolicyList){ 
         List<opportunity> identifiedOppList = new List<opportunity>();
         Set<Opportunity> oppListToUpdate = new Set<Opportunity>();
         Set<String> clientList = new Set<String>(); 
         Set<String> lobList = new Set<String>();
         Set<String> productTypeList = new Set<String>();
         Set<String> externalIdList = new Set<String>();     
         Map<String, String> agentOwnerMap = new Map<String,String>();  
         Map<String,String> nameInsureClientProductMap1 = new Map<String,String>();
            for(InsurancePolicy insurancePolicy: insurancyPolicyList){
                 Map<String,String> nameInsureClientProductMap = new Map<String,String>();
                 OpportunityWrapper oppWrapper = new OpportunityWrapper();
                 String ownerId = insurancePolicy.Servicing_Agent__r.Servicing_Agent_Associate_ID__c+PROXY_CONCAT;
                 agentOwnerMap.put(ownerId,insurancePolicy.Servicing_Agent__c);
                 externalIdList.add(ownerId);
                 oppWrapper.ownerId=ownerId;
                 oppWrapper.clientIdentifier=insurancePolicy.NameInsured.ClientIdentifier__c;
                 clientList.add(insurancePolicy.NameInsured.ClientIdentifier__c);              
                 lobList.add(insurancePolicy.PolicyType);
                 List<String> productList = validateProductMapping(insurancePolicy.PolicyName, insurancePolicy);
                 oppWrapper.product=insurancePolicy.PolicyName;
                 if(productList.size()>0){
                     nameInsureClientProductMap = getProductOwnerDetailsMap(nameInsureClientProductMap,oppWrapper,productList);
                 }
                 nameInsureClientProductMap1.putAll(nameInsureClientProductMap);
                 //productTypeList.add(product);
                 productTypeList.addAll(productList);
        }
         identifiedOppList = [select stageName,id,Assigned_To__c,OppAssignedDateTime__c,ownerId,
         owner.UserExternalID__c,Account.ClientIdentifier__c ,lob__c,
         Product__c from opportunity where owner.UserExternalID__c in :externalIdList and 
         Account.ClientIdentifier__c in :clientList and product__c in :productTypeList and lob__c in :lobList and 
          stageName Not In ('Closed','Closed Won')];   
          Set<Opportunity> finalList = getFinalList(identifiedOppList);
             DateTime timestampValue = System.now();
             for(Opportunity opp : finalList){
                 String matchOpp = opp.owner.UserExternalID__c +'~'+ opp.Account.ClientIdentifier__c+'~'+opp.Product__c.toLowerCase();
                 String product = nameInsureClientProductMap1.get(matchOpp);
              
                 if(product!=null && product.equalsIgnoreCase(opp.Product__c) ){
                    Opportunity oppIdentified = new Opportunity();                      
                    oppIdentified.StageName= CLOSED_WON;
                    oppIdentified.Sub_Status__c= SUB_STATUS_VALUE;
                    oppIdentified.Status__c= STATUS_VALUE;
                    if(opp.OppAssignedDateTime__c == null){
                        String agentId = agentOwnerMap.get(opp.owner.UserExternalID__c);
                         oppIdentified.Assigned_To__c= agentId;
                         oppIdentified.OppAssignedDateTime__c = timestampValue;
                    }
                    oppIdentified.Id = opp.Id;
                    oppIdentified.OppAutoCloseWonDatetime__c = timestampValue;
                    oppListToUpdate.add(oppIdentified);
                }
 
             }
         
         try{
             List<Opportunity> finalOppList = new List<Opportunity>();
             finalOppList.addAll(oppListToUpdate);
             Database.SaveResult[] srList = Database.update(finalOppList, false);
             LoggingService.logDatabaseResult(srList, finalOppList, BATCH_CLASS_NAME, EXECUTE_METHOD_NAME, System.LoggingLevel.ERROR);
          }
         catch(Exception e){
             LoggingService.logHandledException(e,BATCH_CLASS_NAME,EXECUTE_METHOD_NAME+'Updating  Oppportunity',System.LoggingLevel.ERROR);
         }
     }
     /**
      * @description validateProductMapping
      * @param originalValue 
      * @param insurancePolicy 
      * @return  List<String>
      */
     public List<String> validateProductMapping(String originalValue,InsurancePolicy insurancePolicy){
         List<String> prodList= new List<String>();
         if(!String.isEmpty(originalValue)){ 
             if((!finalproductMap.containsKey(originalValue.toLowerCase()))){
                 //Generate an alert to QuadCore team that there is a new value populated         
                 String test = 'ClientIdentifer : '+insurancePolicy.NameInsured.ClientIdentifier__c +': Lob :'+ insurancePolicy.policyType+ ' : Product not present in Salesforce: '+ originalValue+RICH_TEXT_NEW_LINE;
                 productsNotFoundMap.add(test);  
                 prodList.add(originalValue);
                 }
             else{
                 List<String> productValues = finalproductMap.get(originalValue.toLowerCase());
                 if(productValues.size()>0){
                     prodList.addAll(productValues);
                     //productDescription = getProductValue(productValues,originalValue);
                 }
                 else{
                     prodList.add(originalValue);
                 }
             }
         }
         return prodList;
     }
     /**
      * @description getProductValue
      * @param productValues 
      * @param originalValue 
      * @return  `String`
      */
     private String getProductValue(List<String> productValues, string originalValue){
         String productDescription='';
         for(String prodIdentified: productValues){
             if(prodIdentified.equalsIgnoreCase(originalValue.toLowerCase())){
                 productDescription = originalValue.toLowerCase();
                 break;
             }
             else{
                 productDescription=prodIdentified;
             }
         }
         return productDescription;
     }
 
     /**
      * @description finish
      * @param bc
      */
     global void finish(Database.BatchableContext bc){
        sendEmail();
     }
     private void sendEmail() {
         if(productsNotFoundMap!=null && productsNotFoundMap.size()>0){
                 String[] toAddresses = new List<String> {autoClosebatch.BatchEmailRecipient__c};
                 String bodyData = '';
                 for(String data: productsNotFoundMap){
                         bodyData = bodyData+ data;
                 }
                 String emailTitleBody = 'Unmapped Product description values were provided to Agreement for review. '+RICH_TEXT_NEW_LINE;
                  String finalEmailBody = emailTitleBody+bodyData+RICH_TEXT_NEW_LINE+ '<b> Action Needed: <b>'+RICH_TEXT_NEW_LINE +' Please review this new product value for inclusion in the field mapping for Opportunity automated Closed Won processing. ';
                 Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                 emailMessage.setToAddresses(toAddresses);
                 if(String.isNotBlank(EMAIL_SENDER)) {
                     emailMessage.setSenderDisplayName(EMAIL_SENDER);
                 }
                 emailMessage.setSubject(EMAIL_SUBJECT);
                 emailMessage.setHTMLBody(finalEmailBody);
                 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMessage });
         }
     }
     
     private static Set<Opportunity> getFinalList( List<Opportunity> identifiedOppList){
         Map<Opportunity,String> mapOfOpp = new Map<Opportunity,String>();
         List<String> removeList = new List<String>();
         Set<String> uniqueSet = new Set<String>();
         for(Opportunity opp : identifiedOppList){ 
             String matchOpp = opp.owner.UserExternalID__c +'~'+ opp.Account.ClientIdentifier__c+'~'+opp.Product__c+'~'+opp.lob__c;
                 if(uniqueSet.contains(matchOpp)){   
                     removeList.add(matchOpp);
                 }
                 else{
                    uniqueSet.add(matchOpp); 
                    mapOfOpp.put(opp,matchOpp);
                   
                 }
         }
         return getFinalUpdatedList(mapOfOpp, removeList);
     }
 
     private static Set<Opportunity> getFinalUpdatedList(Map<Opportunity,String> mapOfOpp, List<String> removeList){
         for(Opportunity opps : mapOfOpp.keySet()){
              String value = mapOfOpp.get(opps);
              if(removeList.contains(value)){
                  mapOfOpp.remove(opps);
              }
         }
         return mapOfOpp.keySet();
     }
 
     private class OpportunityWrapper{
         private String ownerId;
         private String clientIdentifier;
         private String product;
     }
 }