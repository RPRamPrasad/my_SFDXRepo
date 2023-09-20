/**
* @Author         : Journey Builder
* @description    : HLPR_OpportunityTriggerMCJourney - Trigger handler class for Opportunity Object.
* @Last Updated   : 
*/
public without sharing class HLPR_OpportunityTriggerMCJourney {
    private static String allowTexting = 'Allow_Texting_in_Journeys';
    private static String ilpJourney = 'ILP_Journey';
    /**   * @description marketingCloudFieldUpdates
         * @param opportunityList 
         */
    public static void marketingCloudFieldUpdates(List<Opportunity> opportunityList){
        setDonotAllowText(opportunityList);
        setTextOptin(opportunityList);
    
    }
    /**   * @description setDonotAllowText
         * @param opportunityList 
         */
    
    
     private static void setDonotAllowText(List<Opportunity> opportunityList){
        Map<String,List<CS_MarketingCloudTextPreference__c>> mcTextPrefMap = new Map<String,List<CS_MarketingCloudTextPreference__c>>();   
        List<CS_MarketingCloudTextPreference__c> mcPrefList = new List<CS_MarketingCloudTextPreference__c>([SELECT Id,EndTime__c,Name,
                                                        SkipSunday__c,Holiday__c,StartTime__c,StateCode__c,GMT_Difference__c 
                                                        FROM CS_MarketingCloudTextPreference__c]); 
    
        String day=system.now().format('EEEE');
        mcTextPrefMap = setmcTextPrefMap(mcPrefList);
        
        
        for(Opportunity opportunityObj : opportunityList) {
            
            If(verifyBillingAddressType(opportunityObj, mcTextPrefMap )){
                List<CS_MarketingCloudTextPreference__c> mcpList = mcTextPrefMap.get(opportunityObj.BillingAddressType__c);        
                for(CS_MarketingCloudTextPreference__c mcp : mcpList){
                    if(setDoNotAllowText(day,mcp,opportunityObj)){
                        break;
                    }
                }  
            }   
        }
       }
       
       private static Boolean verifyBillingAddressType(Opportunity opportunityObj,Map<String,List<CS_MarketingCloudTextPreference__c>> mcTextPrefMap ){
            return opportunityObj.BillingAddressType__c != NULL && 
                    mcTextPrefMap.containsKey(opportunityObj.BillingAddressType__c);
        }
        
        private static Boolean setDoNotAllowText(String day, CS_MarketingCloudTextPreference__c mcp, Opportunity opportunityObj)
        {
                if(checkForSunday(day, mcp)){
                    opportunityObj.DONOT_ALLOW_TEXT__c = true;
                    return opportunityObj.DONOT_ALLOW_TEXT__c;
                }
                else if(mcp.StartTime__c != NULL){
                    opportunityObj.DONOT_ALLOW_TEXT__c = timeCheck(mcp.StartTime__c, mcp.EndTime__c,mcp.GMT_Difference__c);
                }
                if(mcp.Holiday__c!= NULL){
                    opportunityObj.DONOT_ALLOW_TEXT__c = holidayCheck(mcp.Holiday__c);
                    return opportunityObj.DONOT_ALLOW_TEXT__c;
                }
                return opportunityObj.DONOT_ALLOW_TEXT__c;
        }
        
        private static boolean checkForSunday(String day, CS_MarketingCloudTextPreference__c mcp){
            return day=='Sunday' && mcp.SkipSunday__c;
        }
    
       private static Map<String,List<CS_MarketingCloudTextPreference__c>> setmcTextPrefMap(List<CS_MarketingCloudTextPreference__c> mcPrefList){ 		
            Map<String,List<CS_MarketingCloudTextPreference__c>> mcTextPrefMap = new Map<String,List<CS_MarketingCloudTextPreference__c>>(); 
            for(CS_MarketingCloudTextPreference__c mcp : mcPrefList){
                if(mcTextPrefMap.containsKey(mcp.StateCode__c) && mcTextPrefMap.get(mcp.StateCode__c) != null) {
                    List<CS_MarketingCloudTextPreference__c> mcpList = mcTextPrefMap.get(mcp.StateCode__c);
                    mcpList.add(mcp);
                    mcTextPrefMap.put(mcp.StateCode__c,mcpList); 
                }   
                else {
                    mcTextPrefMap.put(mcp.StateCode__c, new List<CS_MarketingCloudTextPreference__c> {mcp});
                }
            }
            return mcTextPrefMap;
        }
    /**   * @description timeCheck
        * @param startTime  
        * @param endTime
        * @param gmtDifference
        * @return currentLocalTime
        */
        private static Boolean timeCheck(Decimal startTime, Decimal endTime,Decimal gmtDifference){
            
            Decimal currentLocalTime = system.now().hourGmt() + gmtDifference;
            return (currentLocalTime < startTime || currentLocalTime > endTime);
        }
    /**   * @description holidayCheck
        * @param  holiday
        @return System.today() == holiday
        */
        private static Boolean holidayCheck(Date holiday){
           return (System.today() == holiday);
        }
     /**   * @description setTextOptin
        * @param opportunityList 
        */
        private static void setTextOptin(List<Opportunity> opportunityList) {
            set<Id> oppOwnerSet = new set<Id>();
            Map<String,Boolean> ownerMap = new Map<String,Boolean>();
            for(Opportunity opportunityObj : opportunityList) {            
                oppOwnerSet.add(opportunityObj.ownerId);
            }
            List<MCPreference__c> mcPrefList = new List<MCPreference__c>();
            mcPrefList = [SELECT Id,Journey_Name__c,Journey_Preference__c,Agent_Office_ID__c  
                                                    FROM MCPreference__C 
                                                    WHERE (Journey_Name__c = :allowTexting OR Journey_Name__c = :ilpJourney)
                                                    AND Agent_Office_ID__c in :oppOwnerSet];
             If(!mcPrefList.isEmpty()) {                                       
                 for(MCPreference__c mcp : mcPrefList){
                         ownerMap.put(mcp.Agent_Office_ID__c+mcp.Journey_Name__c,mcp.Journey_Preference__c);
                 } 
                 
                 for(Opportunity opportunityObj : opportunityList) {
                     if(ownerMap.containsKey(opportunityObj.ownerId + allowTexting) &&
                         ownerMap.containsKey(opportunityObj.ownerId + ilpJourney)){  
                         opportunityObj.Text_Optin__c = ownerMap.get(opportunityObj.ownerId + allowTexting) &&
                         ownerMap.get(opportunityObj.ownerId + ilpJourney);
                     }
                 }
             }
         }
    }