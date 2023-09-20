/*****
 * Factory class for generating Journey and JourneySteps in Test classes
 * V2.0 Refactor - Team Incognito   08/22/2022
 **/
@isTest
/**
 * @description TestDataFactory_Journey
 * @author 
 * @since 
 */

public with sharing class TestDataFactory_Journey {
    private static final String SECONDS_FORMAT= 'ssSSS';
    private static final String LOCALE_KEY = 'en_US';

    //method to build Journey record with the given parameter value
    /**
     * @description buildLeadJourneyRecord
     * @param paramVendorCode 
     * @param paramCreatorRoleCode 
     * @return  `Journey__c`
     */
    
    public static Journey__c buildLeadJourneyRecord( Integer paramVendorCode, String paramCreatorRoleCode) {
        Journey__c journey = new Journey__c(JourneyName__c='JourneyName'+String.valueOf(paramVendorCode), Journey_External_ID__c ='111'+paramVendorCode,BusinessLineCode__c = 'Auto',CategoryName__c = 'Lead campaigns',
                            JourneyDescription__c='Journeydescription', VendorCode__c= paramVendorCode, JourneyNumber__c = '1', 
                            CreatorRoleCode__c = paramCreatorRoleCode, CustomDemographicsInd__c = false, JourneyFundingID__c = '0'+String.valueOf(paramVendorCode), StateCode__c='13',
                            EffectiveDate__c = date.today()-8, ExpirationDate__c = date.today()+8,TargetGroupCode__c='01',TimingTypeCode__c = 1);
        return journey;
    }  
/**
 * @description buildCustomerProspectJourneyRecord
 * @param paramVendorCode 
 * @param paramCreatorRoleCode 
 * @return  `Journey__c`
 */

    public static Journey__c buildCustomerProspectJourneyRecord(Integer paramVendorCode, String paramCreatorRoleCode) {
        Journey__c journey = new Journey__c(JourneyName__c='JourneyName'+String.valueOf(paramVendorCode), Journey_External_ID__c ='111'+paramVendorCode,BusinessLineCode__c = 'Auto',CategoryName__c = 'customer prospect campaigns',
                            JourneyDescription__c='Journeydescription', VendorCode__c= paramVendorCode, JourneyNumber__c = '1', 
                            CreatorRoleCode__c = paramCreatorRoleCode, CustomDemographicsInd__c = false, JourneyFundingID__c = '1'+String.valueOf(paramVendorCode), StateCode__c='13',
                            EffectiveDate__c = date.today()-8, ExpirationDate__c = date.today()+8,TargetGroupCode__c='01',TimingTypeCode__c = 1);
       
        return journey;
    }
   //String paramJourneyId, integer paramJourneyStepID, String paramJourneyNumber, integer paramVendorCode, integer paramDaysNum, String paramContactMethodName, String paramMailClassCode
   
    //method to build Journey steps record with the given parameter value
    /**
     * @description buildJourneyStepsRecord
     * @param journeyStepValues 
     * @return  `Journey_Step__c`
     */
    
    public static Journey_Step__c buildJourneyStepsRecord(Map<String, Object> journeyStepValues) {
        Journey_Step__c journeyStep = new Journey_Step__c(JourneyID__c = String.valueOf(journeyStepValues.get('paramJourneyId')) , JourneyStepID__c = Integer.valueOf(journeyStepValues.get('paramJourneyStepID')), VendorCode__c= Integer.valueOf(journeyStepValues.get('paramVendorCode')), 
                                      JourneyNumber__c = String.valueOf(journeyStepValues.get('paramJourneyNumber')), DaysNum__c = Integer.valueOf(journeyStepValues.get('paramDaysNum')), ContactMethodName__c = String.valueOf(journeyStepValues.get('paramContactMethodName')),
                                      Cost__c= '0.28', MailClassCode__c = String.valueOf(journeyStepValues.get('paramMailClassCode')));  
        return journeyStep;
    }    
    
    //method to create Journey with the given journeyList parameter value
    /**
     * @description createJourneys
     * @param journeyList 
     * @return  `List<Journey__c>`
     */
    
    public static List<Journey__c> createJourneys(List<Journey__c> journeyList) {
        if(journeyList!= null && !journeyList.isEmpty()) {                
            insert journeyList;
        }
        return journeyList;
    }

    /**
    * @description to build user with the given parameter value
    * @param tLastName 
    * @param testProfile
    * @return testUser user record
    */
    public static User buildtestUser(String tLastName, Profile testProfile) {
        return new User(alias = 'test', email= 'testuser@statefarm.com', profileid = testProfile.id,
                                emailencodingkey='UTF-8', lastname=tLastName, languagelocalekey=LOCALE_KEY, 
                                localesidkey=LOCALE_KEY, timezonesidkey='America/Chicago', username= tLastName+'@statefarm.com');
    }
    
    /**
    * @description method for building Journey Records
    * @param sampleJny 
    * @return Journey__c
    */
    public static Journey__c buildJourneyRecord(Journey__c sampleJny) {
        return new Journey__c(JourneyName__c=sampleJny.JourneyName__c, BusinessLineCode__c = sampleJny.BusinessLineCode__c,CategoryName__c = sampleJny.CategoryName__c,
                                        JourneyDescription__c='Jnydescription',CustomDemographicsInd__c = true,EffectiveDate__c = System.today(),
                                        ExpirationDate__c = System.today()+60, ApplicableStates__c = sampleJny.ApplicableStates__c, AppliestoAllStates__c = sampleJny.AppliestoAllStates__c,Type__c = sampleJny.Type__c );
    }

    /**
    * @description method for setting up admin and corporate users
    * @return List<User>
    */
    public static List<User> seupAdminAndCorporateUser() {
        //create system Admin user and croporate marketing user to insert records
        Profile sysProfile = [Select Id from Profile WHERE name = 'System Administrator' LIMIT 1];
        User sysAdminUser = TestDataFactory_Journey.buildtestUser('remCmpMemSysAd@statefarm.com', sysProfile);
        Database.insert(sysAdminUser);
        Profile corpMktingProfile = [Select Id from Profile WHERE name = '5.04 Corporate Marketing'];
        User corpMktingUser = TestDataFactory_Journey.buildtestUser('corpMarketing@statefarm.com', corpMktingProfile);

        return new List<User> { sysAdminUser, corpMktingUser };
    }
    /**
    * @description method for building Journey Records
    * @param consentStartDate
    * @param consentEndDate
    * @return signedWrittenConsentRecord
    */

// this method is added here which was removed from Batch_HandleSwcNoResponse_Test.apxc
	/** @Refactor
    * @method- buildSwcRecord
    * @date modified - 24/08/2022
    * @description - Use this method in those classes where it is used(buildSwcRecord)Verify the parameter while using this method.
    * @param consentStartDate
    * @param consentEndDate
    * @param oppval
    * @return - SignedWrittenConsent__c
    */
    public static SignedWrittenConsent__c buildSwcRecord(Date consentStartDate, Date consentEndDate, Opportunity oppval) {
        //Opportunity oppForSwc;
        SignedWrittenConsent__c signedWrittenConsentRecord = new SignedWrittenConsent__c();
        signedWrittenConsentRecord.InitiatedFromId__c = oppval.Id;
        signedWrittenConsentRecord.Account__c = oppval.AccountId;
        signedWrittenConsentRecord.Status__c = 'Requested';
        signedWrittenConsentRecord.RequestStartDate__c = consentStartDate;
        signedWrittenConsentRecord.RequestEndDate__c = consentEndDate;
        signedWrittenConsentRecord.RequestedDate__c = System.Today();
      
        return signedWrittenConsentRecord;
    }

    /** Refactor
    * @method- createJourney
    * @description - Use this method in those classes where it is used(createJourney).
    */
    public static void createJourney(){
        List<Journey__c> journeyList=new List<Journey__c>();
        Journey__c jour1 = TestDataFactory_Journey.buildCustomerProspectJourneyRecord(12345,'0');
        jour1.BusinessLineCode__c = 'General';
        jour1.Categoryname__c = 'Prospect Customers';
        jour1.MasterJourneyId__c = '12345';
        journeyList.add(jour1);
        journeyList.add(TestDataFactory_Journey.buildLeadJourneyRecord(4567,'1'));
        insert journeyList;

        List<Journey_Step__c> journeyStepList = new List<Journey_Step__c>();
        Map<String, Object> journeyStringValues = new Map<String, Object>();

        for(Journey__c journeyRecord:journeyList){
            for(Integer i=0;i<=2;i++){
                journeyStringValues.put('paramJourneyId',journeyRecord.id);
                journeyStringValues.put('paramJourneyStepID',i);
                journeyStringValues.put('paramJourneyNumber',String.valueOf(i));
                journeyStringValues.put('paramVendorCode',1111+i);
                journeyStringValues.put('paramDaysNum',i * 10);
                journeyStringValues.put('paramMailClassCode',String.valueOf(i));
                if(i==3){
                    journeyStringValues.put('paramContactMethodName','Call');
                   
                }else{
                    journeyStringValues.put('paramContactMethodName','Mailing'); 
                }
                Journey_Step__c journey = TestDataFactory_Journey.buildJourneyStepsRecord(journeyStringValues);
                journey.BusinessLineCode__c = 'General';
                journey.StateCode__c = 'IL';
                journey.Categoryname__c = 'Prospect Customers';
                journeyStepList.add(journey);
            }
        }
        insert journeyStepList;
    }

       /**  Refactor
    * @method- getProfileId
    * @param profileName
    * @description - Use this method in those classes where it is used(getProfileId).
    * @return - String
    */
    public static String getProfileId(String profileName) {
        String profileId = TestDataFactory_Helper_ProfileLookup.lookupProfileID(profileName);
        return profileId;
    }  

       /** Refactor
    *  @method- buildUser
    * @param profileId
    * @param associateId
    * @param servicingAgentAssociateId
    * @description - Use this method in those classes where it is used(buildUser).
    * @return - User
    */
    public static User buildUser(String profileId, String associateId, String servicingAgentAssociateId) {
        User testUser = new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey=LOCALE_KEY,localesidkey=LOCALE_KEY, timezonesidkey='America/Chicago',
            username= UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + Integer.valueOf(math.rint(math.random()*100)) + '@sfa222.test.com', 
            profileId = profileId, Associate_ID__c = associateId, Servicing_Agent_Associate_ID__c = servicingAgentAssociateId ,
            State_Agent_Code__c = '13-2935'
        );
        return testUser;
    }

        /**  Refactor
    * @method- buildSimpleConversationRecord
    * @param param_accountId
    * @param param_conductedBy
    * @description - Use this method in those classes where it is used(buildSimpleConversationRecord).
    * @return - SimpleConversation__c
    */
    public static SimpleConversation__c buildSimpleConversationRecord(String param_accountId, String param_conductedBy) {
        SimpleConversation__c simpleConvRecord = new SimpleConversation__c (Account__c = param_accountId,
                            Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv',Appointment_Location__c='Virtual Meeting',
                            AppointmentStartDateTime__c = datetime.now().addHours(1), AppointmentEndDateTime__c = datetime.now().addHours(2));
        return simpleConvRecord;
    }

       /** Refactor
    * @method- buildRoleWithParentRole
    * @param roleName
    * @param parentrole
    * @description - Use this method in those classes where it is used(buildRoleWithParentRole).
    * @return - UserRole
    */
    public static UserRole buildRoleWithParentRole(String roleName, String parentrole) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentrole);
        return role;
    }
    
       /** Refactor
    * @method- buildCustomSettingRecord
    * @param  userId
    * @description - Use this method in those classes where it is used(buildCustomSettingRecord).
    * @return - AccountOwnerSystemUserCustomSetting__c
    */
    public static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        return actOwnerCs;
    }
}