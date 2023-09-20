/**
 * @description Case matching Rules
 * @Owner CATs
 */
public without sharing class SR_MatchingRules {
    
    @TestVisible private Map<SR_MatchKey, List<Case>> tierMap = new Map<SR_MatchKey, List<Case>>();
    @TestVisible private Map<Id, Case> caseMap = new Map<Id, Case>();
    @TestVisible private SR_Payload payload;
    @TestVisible private Case matchingCase = null;
    @TestVisible private boolean mockOwnerIsAMatch = false;
    /**
     * @description SR_MatchingRules
     * @param payload 
     * @param cases 
     */
    public SR_MatchingRules(SR_Payload payload, List<Case> cases){
        this.payload = payload;
        this.caseMap = new Map<Id,Case>(cases);
        sortCases(cases);
    }
    /**
     * @description handleMatching
     * @return  `Case`
     */
    public Case handleMatching(){
        if(SR_MatchingRulesUtil.isTier1Payload(this.payload)){
            handleTier();
        }else if(SR_MatchingRulesUtil.isTier2Payload(this.payload)){
            handleTier(this.tierMap.get(SR_MatchKey.TIER_2), SR_MatchKey.TIER_2);
        }else if(SR_MatchingRulesUtil.isMultiTierPayload(this.payload)){
            handleMultiTierPayload();
        }else if(SR_MatchingRulesUtil.isTier3Payload(this.payload)){
            handleTier(this.tierMap.get(SR_MatchKey.TIER_3), SR_MatchKey.TIER_3);
        }else if(SR_MatchingRulesUtil.isTier4Payload(this.payload)){
            handleTier(this.tierMap.get(SR_MatchKey.TIER_4), SR_MatchKey.TIER_4);
        }
        return this.matchingCase;     
    }
    
    private void handleTier(){
        SR_MatchingTier match = new SR_MatchingTier(this.payload, this.caseMap);
        if(Test.isRunningTest() && mockOwnerIsAMatch){
            match.util.mockOwnerIsAMatch = true;
        }
        this.matchingCase = match.handleTier1();
    }
    
    private void handleTier(List<Case> cases, SR_MatchKey tier){
        SR_MatchingTier match = new SR_MatchingTier(this.payload, cases, tier);
        if(Test.isRunningTest() && mockOwnerIsAMatch){
            match.util.mockOwnerIsAMatch = true;
        }
        this.matchingCase = match.handleTier();
    }
   
    @TestVisible
    private void handleMultiTierPayload(){
        if(mapTierIsPopulated(SR_MatchKey.TIER_3)){ 
           handleTier(this.tierMap.get(SR_MatchKey.TIER_3), SR_MatchKey.TIER_3);
        }
        if(this.matchingCase == null){
           handleTier(this.tierMap.get(SR_MatchKey.TIER_4), SR_MatchKey.TIER_4);
        }
    }
    
    @TestVisible
    private void sortCases(List<Case> cases){
        for(Case caseRecord : cases){
            populateTier2(caseRecord);
            populateTier3(caseRecord);
            populateTier4(caseRecord);
        }
    }
    
    @TestVisible
    private void populateTier2(Case caseRecord){
        if(caseRecord.Policy_Identifier__c != null && caseRecord.Vehicle_Identifier__c != null){
            setTierMap(SR_MatchKey.TIER_2, caseRecord);
        }
    }
    
    @TestVisible
    private void populateTier3(Case caseRecord){
        if(caseRecord.Policy_Identifier__c != null){
            setTierMap(SR_MatchKey.TIER_3, caseRecord);
        }
    }
    
    @TestVisible
    private void populateTier4(Case caseRecord){
        if(caseRecord.ProductDescription__c != null){
            setTierMap(SR_MatchKey.TIER_4, caseRecord);
        }
    }
    
    @TestVisible
    private boolean mapTierIsPopulated(SR_MatchKey key){
        return this.tierMap.containsKey(key) && !this.tierMap.get(key).isEmpty();
    }
    
    @TestVisible
    private void setTierMap(SR_MatchKey key, Case caseRecord){
        List<Case> cases = (tierMap.containsKey(key)) ? tierMap.get(key) : new List<Case>();
        cases.add(caseRecord);
        this.tierMap.put(key, cases);
    }
    
}