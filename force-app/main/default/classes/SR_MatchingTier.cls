/**
 * @description SR_MatchingTier
 */
public without sharing class SR_MatchingTier {
    
    @TestVisible private Map<Id,Case> caseMap = new Map<Id,Case>();
    @TestVisible private List<Case> cases = new List<Case>();
    @TestVisible private SR_Payload payload;
    @TestVisible private Case matchingCase = null;
    @TestVisible private SR_MatchKey tier;
    public SR_MatchingTierUtil util = new SR_MatchingTierUtil();
    /**
     * @description SR_MatchingTier
     * @param payload 
     * @param caseMap 
     */
    public SR_MatchingTier(SR_Payload payload, Map<Id,Case> caseMap){
        this.payload = payload;
        this.caseMap = caseMap;
    }
    /**
     * @description SR_MatchingTier
     * @param payload 
     * @param cases 
     * @param tier 
     */
    public SR_MatchingTier(SR_Payload payload, List<Case> cases, SR_MatchKey tier){
        this.payload = payload;
        this.cases = cases;
        this.tier = tier;
    }
    /**
     * @description handleTier1
     * @return  `Case`
     */
    public Case handleTier1(){
        String key = this.payload.matchParams.caseId;
        if(this.caseMap.containsKey(key)){
            runTier1Matching(key);
        }
        return this.matchingCase;
    }
    /**
     * @description handleTier
     * @return  `Case`
     */
    public Case handleTier(){
        if(this.cases !=null && !this.cases.isEmpty()){
            runMatching(this.cases);
        }
        return this.matchingCase;
    }
    
    private void runMatching(List<Case> cases){
        switch on this.tier{
            when TIER_2{
                runTier2Matching(cases);
            }
            when TIER_3{
                runTier3Matching(cases);
            }
            when TIER_4{
                runTier4Matching(cases);
            }
        }
    }
    /**
     * @description runTier1Matching
     * @param key 
     */
    public void runTier1Matching(String key){
        Case caseRecord = this.caseMap.get(key);
        if (caseRecord != null) {
            caseRecord.Tier_Matched__c = SR_Constants.CASE_MATCH_TIER_1;
            this.matchingCase = caseRecord;
        }
    }
    
    @TestVisible
    private void runTier2Matching(List<Case> cases){
        for(Case caseRecord : cases){
            if(util.isPolicyIdAMatch(this.payload, caseRecord) && util.isVehicleIdAMatch(this.payload, caseRecord) && util.ownerIsAMatch(this.payload, caseRecord) && util.recordTypeIsAMatch(this.payload, caseRecord)){
                caseRecord.Tier_Matched__c = SR_Constants.CASE_MATCH_TIER_2;
                this.matchingCase = caseRecord;
                break;
            }
        }
    }

    @TestVisible
    private void runTier3Matching(List<Case> cases){
        for(Case caseRecord : cases){
            if(util.isPolicyIdAMatch(this.payload, caseRecord) && util.ownerIsAMatch(this.payload, caseRecord) && util.recordTypeIsAMatch(this.payload, caseRecord)){
                caseRecord.Tier_Matched__c = SR_Constants.CASE_MATCH_TIER_3;
                this.matchingCase = caseRecord;
                break;
            }
        }
    }
    
    @TestVisible
    private void runTier4Matching(List<Case> cases){
        for(Case caseRecord : cases){
            if((util.hasNoPolicyId(this.payload, caseRecord)) && (util.isPolicyDescAMatch(this.payload, caseRecord) || util.isPolicyDescAMatchOnFirstTwoWords(this.payload, caseRecord)) && util.ownerIsAMatch(this.payload, caseRecord) && util.recordTypeIsAMatch(this.payload, caseRecord)){
                caseRecord.Tier_Matched__c = SR_Constants.CASE_MATCH_TIER_4;
                this.matchingCase = caseRecord;
                break;
            }
        }
    }
    
}