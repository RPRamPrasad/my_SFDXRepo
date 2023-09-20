/**
 * @name TestDataFactory_Claim
 * @author Moneyball
 * @description Utility class that creates Claim related records for testing purposes
 */

@isTest
public class TestDataFactory_Claim extends UTIL_AgencyShares {
    
    /**
     * @name: generateClaim
     * @description Calls generateClaims to create a single test claim
     * @param account
     * @param policy
     * @return Claim 
     */
    public static Claim generateClaim(Account account, InsurancePolicy policy) {
        return generateClaims(1, account, policy).get(0);
    }
    
    /**
     * @name: generateClaims
     * @description Generates x number of claims (based on param value passed in)
     * @param numberOfClaims
     * @param account
     * @param policy
     * @return List<Claim> 
     */
    public static List<Claim> generateClaims(Integer numberOfClaims, Account account, InsurancePolicy policy) {
        List<Claim> claims = new List<Claim>();
        for (Integer i = 0; i < numberOfClaims; i++) {
            claims.add(generateClaim('Claim ' + i, account, policy));
        }
        return claims;
    }

    /**
     * @name: generateClaim
     * @description Method used to generate the test claim (called by generateClaims)
     * @param claimNumber
     * @param account
     * @param policy
     * @return Claim 
     */
    public static Claim generateClaim(String claimNumber, Account account, InsurancePolicy policy) {
        Claim claim = new Claim();
        claim.Name = claimNumber;
        claim.AccountId = account.Id;
        if (policy != null) {
            claim.PolicyNumberId = policy.Id;
        }
        return claim;
    }
    
    /**
     * @name: insertClaim
     * @description Inserts a single claim
     * @param claim
     * @return Claim 
     */
    public static Claim insertClaim(Claim claim) {
        List<Claim> claims = new List<Claim> {claim};
        return insertClaims(claims).get(0);
    }
    
    /**
     * @name: insertClaims
     * @description Inserts a list of claims
     * @param claims
     * @return List<Claim> 
     */
    public static List<Claim> insertClaims(List<Claim> claims) {
        insert claims;        
        return claims;
    }

    /**
     * @name: updateClaim
     * @description Updates a single claim
     * @param claim
     * @return Claim 
     */
    public static Claim updateClaim(Claim claim) {
        List<Claim> claims = new List<Claim> {claim};
        return updateClaims(claims).get(0);
    }

    /**
     * @name: updateClaims
     * @description Updates a list of claims
     * @param claims
     * @return List<Claim> 
     */
    public static List<Claim> updateClaims(List<Claim> claims) {
        update claims;        
        return claims;
    }
    
    /**
     * @name: byPassClaimAfterTriggers
     * @description Method to bypass the normal claim after insert/update triggers
     */
    public static void byPassClaimAfterTriggers() {
        CS001_ByPassTriggerAtoF__c byPassUserTrigger = CS001_ByPassTriggerAtoF__c.getInstance(UserInfo.getUserId());
        if (byPassUserTrigger.Override_ClaimAfterInsert__c == false || byPassUserTrigger.Override_ClaimAfterUpdate__c == false) {
            byPassUserTrigger.Override_ClaimAfterInsert__c = true;
            byPassUserTrigger.Override_ClaimAfterUpdate__c = true;
            upsert byPassUserTrigger;
        }
    }

    /**
     * @name: createInsurancePolicy
     * @description create insurance policy for the given account
     * @param name insurance policy name
     * @param account account to associate policy with
     * @return InsurancePolicy
     */
    public static InsurancePolicy createInsurancePolicy(String name, Account account) {
        InsurancePolicy policy = new InsurancePolicy();
        policy.NameInsuredId = account.Id;
        policy.Name = name;
        insert policy;

        return policy;
    }

    /**
     * @name: createProxyAgent
     * @description create a proxy agent
     * @param uniqueValue unique value for the proxy agent
     * @return User
     */
    public static User createProxyAgent(String uniqueValue) {
        User testProxyUser1 = new User(Alias='Proxy123',LastName='TaskProxy123',Username='TaskProxy123@statefarm.com.bad',UserExternalID__c=uniqueValue + 'P',Servicing_Agent_Associate_ID__c=uniqueValue);
        User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
        insert proxyUser;
        return proxyUser;
    }


    /**
     * @name: createOffice
     * @description create a proxy office
     * @param uniqueValue unique value for the proxy office
     * @return User
     */
    public static User createOffice(String uniqueValue) {
        User testProxyUser = new User(Alias=uniqueValue,FirstName='ProxyAccOwner',LastName=uniqueValue + 'p',Associate_ID__c=uniqueValue,UserExternalID__c=uniqueValue,Territory_Associate_ID__c=uniqueValue);
        User proxy = UTIL_UserProvisioning_TEST.buildProxyUserRandomUsername(testProxyUser);
        Database.SaveResult result = Database.insert(proxy);
        proxy.Id = result.getId();
        return proxy;
    }

    /**
     * @name: createClaimParticipants
     * @description create claim participants for a given list of claims, account id and role
     * @param claims list of claims
     * @param participantAccountId participant account id
     * @param roleCode primary role code for participant
     * @return List<ClaimParticipant>
     */
    public static List<ClaimParticipant> createClaimParticipants(List<Claim> claims, Id participantAccountId, String roleCode) {
        List<ClaimParticipant> claimParticipants = new List<ClaimParticipant>();
        for (Claim claim : claims) {
            ClaimParticipant participant = new ClaimParticipant();
            participant.ClaimId = claim.Id;
            participant.ParticipantAccountId = participantAccountId;
            participant.RoleCd__c = roleCode;

            claimParticipants.add(participant);
        }

        insert claimParticipants;
        return claimParticipants;
    }

    /**
     * @name: createAccountShares
     * @description create account shares for each of the proxies
     * @param account account to share
     * @param proxies list of proxy users
     * @return List<AccountShare>
     */
    public static List<AccountShare> createAccountShares(Account account, List<User> proxies) {
        List<AccountShare> accountShares = new List<AccountShare>();
        for (User proxy : proxies) {
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = account.Id;
            accountShare.UserOrGroupId = proxy.Id;
            accountShare.AccountAccessLevel = 'Read';
            accountShare.RowCause = 'Manual';
            accountShare.OpportunityAccessLevel = 'None';
            accountShare.CaseAccessLevel = 'None';
            accountShares.add(accountShare);
        }
        
        insert accountShares;

        return accountShares;
    }

    /**
     * @name: generateAgentRoleData
     * @description generate the AgentRoleData with the account ids and proxy
     * @param accounts list of accounts
     * @param proxy proxy user
     * @return AgentRoleData
     */
    public static AgentRoleData generateAgentRoleData(List<Account> accounts, User proxy) {
        AgentRoleData agentRoleData = new AgentRoleData();
        agentRoleData.agentRoles = new List<AgentRole__c>();
        Map<Id,Id> agentToProxyIds = new Map<Id, Id>();
        for (Account account : accounts) {
            AgentRole__c agentRole = new AgentRole__c();
            agentRole.Customer__c = account.Id;
            agentToProxyIds.putAll(generateAgentToProxyId(agentRole, proxy));
            agentRoleData.agentRoles.add(agentRole);
        }
        
        agentRoleData.agentToProxyIds = agentToProxyIds;
        return agentRoleData;
    }

    private static Map<Id,Id> generateAgentToProxyId(AgentRole__c agentRole, User proxy) {
        Map<Id,Id> agentToProxyIds = new Map<Id, Id>();
        agentRole.Agent__c = proxy.id;
        agentToProxyIds.put(proxy.Id, proxy.Id);

        return agentToProxyIds;
    }
    /**
     * @name: generateClaimParticipants
     * @description generate claim participants for a given list of claims, account id and role
     * @param claims list of claims
     * @param participantAccountId participant account id
     * @param roleCode primary role code for participant
     * @return List<ClaimParticipant>
     */
    public static List<ClaimParticipant> generateClaimParticipants(List<Claim> claims, Id participantAccountId, String roleCode) {
        List<ClaimParticipant> claimParticipants = new List<ClaimParticipant>();
        for (Claim claim : claims) {
            ClaimParticipant participant = new ClaimParticipant();
            participant.ClaimId = claim.Id;
            participant.ParticipantAccountId = participantAccountId;
            participant.RoleCd__c = roleCode;


            claimParticipants.add(participant);
        }

        return claimParticipants;
    }
}