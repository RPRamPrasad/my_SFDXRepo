/**
 * @description common methods used in ClaimAdaFastTrackSelectPolicy component
 */
public with sharing class ClaimAdaFTSelectPolicyController {

    private static final String CLASS_NAME = 'ClaimAdaFTSelectPolicyController';

    /**
     * @description Retrieves the Insurance Policy and Insurance Policy Participants associated to the person account id
     * @param accountId person account record id
     * @param svcAgentAssocId logged in user's servicing agent associate id
     * @return Map<String, InsurancePolicyAndParticipants> Map of InsurancePolicyAndParticipants associated to the account
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, InsurancePolicyAndParticipants> getPoliciesAndParticipants(String accountId,String svcAgentAssocId){
        List<InsurancePolicyParticipant> policyAndParticipantRecords;
        try {
            policyAndParticipantRecords = [
                                        SELECT InsurancePolicyId, InsurancePolicy.Name, InsurancePolicy.NameInsuredId, 
                                                InsurancePolicy.PolicyDescription, InsurancePolicy.PolicyName, InsurancePolicy.ProdLineCd__c,
                                                InsurancePolicy.Status,  InsurancePolicy.EffectiveDate, InsurancePolicy.CancellationDate,InsurancePolicy.PlcyTypeCd__c,
                                                InsurancePolicy.AgreAccessKey__c, InsurancePolicy.AgreSourceSysCd__c
                                        FROM InsurancePolicyParticipant 
                                        WHERE PrimaryParticipantAccountId = :accountId
                                                AND (Policy_Type__c = 'Auto' OR Policy_Type__c = 'Fire') 
                                                AND (InsurancePolicy.IsActive = true OR InsurancePolicy.CancellationDate >= LAST_N_DAYS:180)
                                                AND InsurancePolicy.PlcyTypeCd__c NOT IN('M','L')
                                                AND InsurancePolicy.Servicing_Agent__r.Servicing_Agent_Associate_ID__c =: svcAgentAssocId
            							WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException('Insurance Policy and Participants retrieval failed');
        }

        Map<String, InsurancePolicyAndParticipants> policiesAndParticipants;

        if(!policyAndParticipantRecords.isEmpty() && policyAndParticipantRecords != null){
            List<Id> policyIds = new List<Id>();
            List<InsurancePolicy> policyRecords = new List<InsurancePolicy>();
            for(InsurancePolicyParticipant p : policyAndParticipantRecords){
                policyIds.add(p.InsurancePolicyId);
                policyRecords.add(separatePolicyFromParticipant(p));
            }
            Map<Id, List<InsurancePolicyParticipant>> participantsMap = getInsurancePolicyParticipants(policyIds);
            policiesAndParticipants = mapInsurancePolicyAndParticipants(policyRecords, participantsMap);
        }

        return policiesAndParticipants;
    }

    /**
     * @description Creates an Insurance Policy out of the Participant results
     * @param p
     * @return InsurancePolicy
     */
    private static InsurancePolicy separatePolicyFromParticipant(InsurancePolicyParticipant p){
        InsurancePolicy policyRecord = new InsurancePolicy(Id = p.InsurancePolicyId, Name = p.InsurancePolicy.Name,
                                                            NameInsuredId = p.InsurancePolicy.NameInsuredId, 
                                                            PolicyDescription = p.InsurancePolicy.PolicyDescription,
                                                            PolicyName = p.InsurancePolicy.PolicyName,
                                                            ProdLineCd__c = p.InsurancePolicy.ProdLineCd__c,
                                                            Status = p.InsurancePolicy.Status,
                                                            EffectiveDate = p.InsurancePolicy.EffectiveDate,
                                                            CancellationDate = p.InsurancePolicy.CancellationDate,
                                                            PlcyTypeCd__c = p.InsurancePolicy.PlcyTypeCd__c,
                                                            AgreAccessKey__c = p.InsurancePolicy.AgreAccessKey__c,
                                                            AgreSourceSysCd__c = p.InsurancePolicy.AgreSourceSysCd__c);
        return policyRecord;
    }

    /**
     * @description handleSpi
     * @param fieldValue 
     * @param fieldName 
     * @return  string
     */
    @AuraEnabled
    public static String handleSpi(String fieldValue, String fieldName){
        AP_SPISecurityValidator spiSecurity = new AP_SPISecurityValidator();
        return spiSecurity.handle(fieldValue, fieldName);
    }

    /**
     * @description logException creates an exception log when errors occur
     * @param message 
     * @param method 
     */
    @AuraEnabled
    public static void logException(String message, String method){
        LoggingService.logHandledException(new InvalidInputException(message), CLASS_NAME, method, System.LoggingLevel.ERROR);
    }

    /**
     * @description performs callout to tpar service
     * @param searchKey - string keyword user is attempting to perform the search with
     * @return List<String> of http status code and body
     */
    @AuraEnabled
    public static List<String> httpReq(String searchKey){
        List<String> response = new List<String>();
        try{
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/graphql');
            req.setEndpoint('callout:CcfaClaimsExperience/tpar-api/thirdparties');

            String requestObj = 'searchByPhone(reqObj: "{\'inputs\' : {\'phoneNumber\': \'' + searchKey + '\', \'includeOutOfBusiness\' : \'Y\'}}")';
            String jsonInput = '{' + requestObj + ' {'
                                    + ' statusCode'
                                    + ' transactionId'
                                    + ' errors'
                                    + ' message { info error warning }'
                                    + ' data {'
                                    + '     thirdPartyId'
                                    + '     walletDetails {'
                                    + '         names { lastName usage }'
                                    + '         postalAddresses { address city state postalZipCode addressUsage }'
                                    + '         telephones { areaCode lineNumber extensionNumber usage equipmentType }'
                                    + '     }'
                                    + '     partyExternalReferences { externalReferenceId externalReferenceType externalReferenceValue }'
                                    + ' } } }';
            req.setBody(jsonInput);
            req.setMethod('POST');
            Http h = new Http();
            HttpResponse res = h.send(req);
            response.add(String.valueOf(res.getStatusCode()));
            response.add(res.getBody());
        }catch(Exception err){
            logException(err.getMessage(), 'ClaimAdaFTSelectPolicyController.httpReq - call failed');
            throw new AuraHandledException(err.getMessage());
        }

        return response;
    }

    /**
     * @description Retrieves the Insurance Policy Assets associated to the policy id
     * @param policyId - policy id
     * @return List<InsurancePolicyAsset>
     */
    @AuraEnabled
    public static List<InsurancePolicyAsset> getInsurancePolicyAssets(Id policyId){
        List<InsurancePolicyAsset> riskList;
        try {
                riskList = Security.stripInaccessible(AccessType.READABLE,[
                        SELECT City__c,Description__c,PostalCode__c,RiskStatusText__c,State__c,Street__c,
                                VIN__c,RiskNumber__c,PhysicalObjectId__c 
                        FROM InsurancePolicyAsset 
                        WHERE InsurancePolicyId = :policyId
                        ]).getRecords();
        } catch (Exception e) {
            throw new AuraHandledException('Insurance Policy Assets retrieval failed');
        }
        
        return riskList;
    }

    /**
     * @description returns a map of Insurance Policy Participants that's related to the list of policy ids
     * @param policyIds
     * @return Map<Id, List<InsurancePolicyParticipant>> map of Insurance Policy Participants
     */
    private static Map<Id, List<InsurancePolicyParticipant>> getInsurancePolicyParticipants(List<ID> policyIds){
        List<InsurancePolicyParticipant> participants = null;
        try {
            participants = Security.stripInaccessible(AccessType.READABLE,[
                        SELECT InsurancePolicyId, PrimaryParticipantAccount.Name, PrimaryParticipantAccount.ClientIdentifier__c
                        FROM InsurancePolicyParticipant
                        WHERE InsurancePolicyId IN :policyIds
            ]).getRecords();
        } catch (Exception e) {
            throw new AuraHandledException('Insurance Participants retrieval failed');
        }

        Map<Id, List<InsurancePolicyParticipant>> participantsMap = new Map<Id, List<InsurancePolicyParticipant>>();

        for(InsurancePolicyParticipant p : participants){
            List<InsurancePolicyParticipant> pList = participantsMap.get(p.InsurancePolicyId);
            if(pList == null){
                pList = new List<InsurancePolicyParticipant>();
            }
            pList.add(p);
            participantsMap.put(p.InsurancePolicyId, pList);
        }

        return participantsMap;
    }

    /**
     * @description map policy id to policy and participant records. returns a list of Insurance Policy and Participants
     * @param policies
     * @param participantsMap
     * @return Map<String, InsurancePolicyAndParticipants> Map of InsurancePolicyAndParticipants associated to the account
     */
    private static Map<String, InsurancePolicyAndParticipants> mapInsurancePolicyAndParticipants(List<InsurancePolicy> policies, Map<Id, List<InsurancePolicyParticipant>> participantsMap){
        Map<String, InsurancePolicyAndParticipants> policiesAndParticipantsMap = new Map<String, InsurancePolicyAndParticipants>();
        for(InsurancePolicy p : policies){
            InsurancePolicyAndParticipants policyAndParticipants = new InsurancePolicyAndParticipants();
            policyAndParticipants.policyId = p.Id;
            policyAndParticipants.policyNumber = p.Name;
            policyAndParticipants.policyParticipants = participantsMap.get(p.Id);
            policyAndParticipants.policyParticipantNames = returnParticipantNames(participantsMap.get(p.Id));
            policyAndParticipants.policyDescription = p.PolicyDescription;
            policyAndParticipants.policyName = p.PolicyName;
            policyAndParticipants.lineOfBusiness = p.ProdLineCd__c;
            policyAndParticipants.policyStatus = p.Status;
            policyAndParticipants.effectiveDate = p.EffectiveDate;
            policyAndParticipants.cancellationDate = p.CancellationDate;
            policyAndParticipants.policyType = p.PlcyTypeCd__c;
            policyAndParticipants.agreAccessKey = p.AgreAccessKey__c;
            policyAndParticipants.agreSourceSysCd = p.AgreSourceSysCd__c;
            policiesAndParticipantsMap.put(p.Id, policyAndParticipants);
        }

        return policiesAndParticipantsMap;
    }

    /**
     * @description adds all participant names to a string and returns it
     * @param participants
     * @return String of participant names
     */
    private static String returnParticipantNames(List<InsurancePolicyParticipant> participants){
        String names = '';
        for(InsurancePolicyParticipant p : participants){
            if(names.length() > 0){
                names =  names + ', ' + p.PrimaryParticipantAccount.Name;
            }else{
                names = p.PrimaryParticipantAccount.Name;
            }
        }
        return names;
    }

    /**
     * @description properties that define a InsurancePolicyAndParticipants item
     */
    public with sharing class InsurancePolicyAndParticipants {
        @AuraEnabled
        public Id policyId;
        @AuraEnabled
        public String policyNumber;
        @AuraEnabled
        public List<InsurancePolicyParticipant> policyParticipants;
        @AuraEnabled
        public String policyParticipantNames;
        @AuraEnabled
        public String policyDescription;
        @AuraEnabled
        public String policyName;
        @AuraEnabled
        public String lineOfBusiness;
        @AuraEnabled
        public String policyStatus;
        @AuraEnabled
        public Datetime effectiveDate;
        @AuraEnabled
        public Datetime cancellationDate;
        @AuraEnabled
        public String policyType;
        @AuraEnabled
        public String agreAccessKey;
        @AuraEnabled
        public String agreSourceSysCd;

        /**
         * @description constructor that initializes that default values for InsurancePolicyAndParticipants items
         */
        public InsurancePolicyAndParticipants(){
            this.policyId = null;
            this.policyNumber = '';
            this.policyParticipants = null;
            this.policyParticipantNames = '';
            this.policyDescription = '';
            this.policyName = '';
            this.lineOfBusiness = '';
            this.policyStatus = '';
            this.effectiveDate = null;
            this.cancellationDate = null;
            this.policyType= '';
            this.agreAccessKey= '';
            this.agreSourceSysCd= '';
        }
    }
}