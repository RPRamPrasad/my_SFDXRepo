/**
 * @description SR_MatchParams
 */
public without sharing class SR_MatchParams {

    public String clientId;//Required
    public String ownerAssociateId;//Required
    public String recordTypeName;//Required
    
    public String secondaryClientId;//This value will be populate in PNI
    
    public String caseId; //Tier 1 Primary Matching field
	public String policyId;//Tier 2 & 3 Primary Matching field (Basic 7 for Auto)
    public String policyDescription; //Tier 4 Primary Matching field
    public String vehicleId;//Tier 2 Supplementary Matching field with Policy Id

}