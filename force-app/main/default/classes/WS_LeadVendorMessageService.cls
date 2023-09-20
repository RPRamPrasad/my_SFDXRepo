/****************************************************************************************
Name: LeadVendorMessageService
Copyright © State Farm
=========================================================================================
Purpose:
-------
Decription: This class is responsible for taking in leads. It is part of a SOAP call from the TP (Techinal Platform)
Team: ImpactForce
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Wyatt Lansdale (F0AS)     8/31/2016             Initial Development
2.0             Kalimatha Mandadi         9/01/2016             Modified to add logic related to mapping
3.0             Ramya Arikepudi           9/28/2016             Modified to add opportunity
4.0             Jonathan Elliott          9/30/2016             Added Chatter Functionality/ Modified logic
4.1             Zeev Feldbeine            10/21/2016            Change HLPR to UTIL
5.0             Ramya Arikepudi           11/15/2016            Added New file to the ILP
6.0             Kalimatha Mandadi         11/28/2016            Added CustomMetadata logic to get Marketing Source
7.0         Wyatt Lansdale/Joseph Abell   12/08/2016            Added Exceptions   
8.0         zeev feldbeine/Jonathan Elliott 12/22/2016           fixed defect, added logic
9.0             Dhaval Pawar              4/20/2017             Modified to add method for new opportunity detail objects
10.0			Billy Neumann			  5/2/2019				Changed record type id retrieval for FSC
11.0            Krishna Kumari Sanaboina  6/22/2022             Added externalId field
******************************************************************************************/
/**
 * @description WS Lead Vendor Message Service
 */
global with sharing class WS_LeadVendorMessageService {
    
    private static final String CLASS_NAME = 'WS_LeadVendorMessageService';
    private static final String CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME = 'createLeadVendorMessage';
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
    private static final Integer SUCCESS_RESPONSE_CODE = 2000;
    private static final Integer FAILED_RESPONSE_CODE = 2001;
    private static final String HYPHEN_SYMBOL='-';
    private static final String SPACE_SYMBOL=' ';
    private static final String NULL_SYMBOL='';
    private static final String TILT_SYMBOL='~';
    private static final Date CLOSED_DATE=Date.today()+60;  
    private static WS_LeadVendorMessageServiceWrapper msgWrap = new WS_LeadVendorMessageServiceWrapper();
    
    /**
     * @description Create Lead Vendor Message
     * @param lvm
     * @return HLPR_LeadVendorResponse
     */
    webservice static HLPR_LeadVendorResponse createLeadVendorMessage(HLPR_LeadVendorMessage lvm) {
        //Prepare and Upsert Account,Agent Role and Insert Opportunity
        HLPR_LeadVendorResponse response = new HLPR_LeadVendorResponse();
           if (lvm != null) 
           {
                Savepoint sp = Database.setSavepoint();

                try{                   
                    List<User> usr= [SELECT id,Name,Alias FROM user WHERE Associate_ID__c <>: NULL_SYMBOL and Associate_ID__c =:lvm.leadagentrole.AgentAssociateID 
                                     and UserExternalId__C=:(lvm.leadagentrole.AgentAssociateID+'_'+lvm.leadagentrole.AgentAssociateID)
                                     and IsActive=true WITH SECURITY_ENFORCED limit 1];                    
                    
                    if(usr != null && !usr.isEmpty()) {
                        Account acc = upsertAccount(lvm);
                        AgentRole__c agr = upsertAgentRole(lvm, usr[0], acc);             
                        Opportunity opportunity = insertOpportunity(lvm, acc, agr);
    
                        response.response_code=SUCCESS_RESPONSE_CODE;
                        response.response_msg =System.Label.CL_Response_Success_Message;
                        
                        try {
                            postMessages(opportunity.Id);
        
                        } catch(Exception ex) {
                            response.response_code=FAILED_RESPONSE_CODE;
                            response.response_msg=System.Label.CL_Response_Success_Message;
                            LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
                        }
                    } else {
                         throw new HLPR_LeadVendorMessageServiceException(System.Label.CL_AgentAssociateID_Invalid_Message);
                    }
                       
                }
                catch(Exception ex){
                       Database.rollback(sp);
                       LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
                       throw new HLPR_LeadVendorMessageServiceException(ex.getMessage(), ex);
                }
            }
            return response;
    }
    
   /**
    *  Sets up and Upserts the Account
    * @description Upsert Account
    *  @name  upsertAccount
    *  @param lvm - The incoming LeadVendorMessage
    *  @return Account
    */
    
    private static Account upsertAccount(HLPR_LeadVendorMessage lvm) {
        
        return msgWrap.upsertAccount(lvm);
    }
    
    private static Account createAccountIndividualName(String tempName)
    {
        Account acc = new Account();
        acc.FirstName= tempName.substringBefore(SPACE_SYMBOL).toUpperCase();
        acc.LastName= tempName.substringAfter(SPACE_SYMBOL).toUpperCase();
        return acc;
    }
    
    private static Account createAccountOrganizationName(String tempName)
    {
       Account acc= new Account();           
        acc.LastName = tempName.toUpperCase();
        return acc;
    }
    
   /**
    *  Sets up and Upserts the AgentRole
    *  @description Upsert Agent Role
    *  @name  upsertAgentRole
    *  @param lvm - The incoming LeadVendorMessage
    *  @param usr
    *  @param acc
    *  @return AgentRole__c - The upserted AgentRole is returned
    */
    
     private static AgentRole__c upsertAgentRole(HLPR_LeadVendorMessage lvm, User usr, Account acc) {
         AgentRole__c agr = new AgentRole__c();
         
         agr.Agent__c = usr.id;
         agr.AgentRoleIdentifier__c= lvm.leadagentrole.AgentAssociateID+TILT_SYMBOL+lvm.leadaccount.ClientID;
         agr.Customer__c = acc.id;        
         UTIL_AgentRoleDAO.upsertUserAgentRoles(new List<AgentRole__c>{agr});         
         return agr;
    }
    
   /**
    *  Sets up and Inserts the Opportunity
    *  @description Insert Opportunity
    *  @name  insertOpportunity
    *  @param lvm - The incoming LeadVendorMessage
    *  @param acc - The upserted account
    *  @param agr - The upserted agentRole
    *  @return opportunity - The inserted Opportunity
    */
    
    private static Opportunity insertOpportunity(HLPR_LeadVendorMessage lvm, Account acc, AgentRole__c agr) {   
        return msgWrap.insertOpportunity(lvm, acc, agr);
    }
    
    
   /**
    *  Sets up and Inserts the General Party Info
    *  @description Insert General Party Info
    *  @name  insertGeneralPartyInfo
    *  @param lvm - The incoming LeadVendorMessage
    *  @param opp - The inserted opportunity
    */
    
    private static void insertGeneralPartyInfo(HLPR_LeadVendorMessage lvm, Opportunity opp) {
        new WS_LeadVendorMessageServiceWrapper2().insertGeneralPartyInfo(lvm, opp);
    }    
        
   /**
    *  Sets up and Inserts the Lead Addresses
    *  @description Insert Addresses
    *  @name  insertAddresses
    *  @param hlgpi - The incoming HLPR_LeadGeneralPartyInfo
    *  @param opp - The inserted opportunity
    *  @param gpi - The inserted general party info
    */
    
    private static void insertAddresses(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
        List<ILP_Opportunity_Address__c> addressList = new List<ILP_Opportunity_Address__c>();
        List<HLPR_LeadAddress> leadAddressList = hlgpi.leadAddressList;

        for(HLPR_LeadAddress hladdress : leadAddressList) {
            ILP_Opportunity_Address__c address = new ILP_Opportunity_Address__c();   
            address.Address1__c = hladdress.Address1;
            address.Address2__c = hladdress.Address2;
            address.CareOf__c = hladdress.CareOf;
            address.City__c = hladdress.City;
            address.Country__c = hladdress.Country;
            address.State__c = hladdress.State;
            address.Type__c = hladdress.Type;
            address.Zip__c = hladdress.zip;
            address.Opportunity__c = opp.Id;
            address.GeneralPartyInfo__c = gpi.Id;
            
            addressList.add(address);
        }

        if(!addressList.isEmpty()) {
            UTIL_LeadAddressDAO.insertOpportunityAddresses(addressList);
        }
    }
    
    
   /**
    *  Sets up and Inserts the Lead Claims
    *  @name  insertClaims
    *  @description Insert Claims
    *  @param hlgpi - The incoming HLPR_LeadGeneralPartyInfo
    *  @param opp - The inserted opportunity
    *  @param gpi - The inserted general party info
    */
    
    private static void insertClaims(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
        List<ILP_Opportunity_Claim__c> claimList = new List<ILP_Opportunity_Claim__c>();
        List<HLPR_LeadClaim> leadClaimList = hlgpi.leadClaimList;

        for(HLPR_LeadClaim hlclaim : leadClaimList) {
            ILP_Opportunity_Claim__c claim = new ILP_Opportunity_Claim__c();
            claim.AmountPaid__c = hlclaim.AmountPaid;
            claim.Date__c = hlclaim.ClaimDate;
            claim.Description__c = hlclaim.Description;
            claim.TypeOfLoss__c = hlclaim.TypeOfLoss;
            claim.Opportunity__c = opp.Id;
            claim.GeneralPartyInfo__c = gpi.Id;
            
            claimList.add(claim);
        }

        if(!claimList.isEmpty()) {
            UTIL_LeadClaimDAO.insertOpportunityClaims(claimList);
        }
    }
    
    
   /**
    *  Sets up and Inserts the Lead Drivers
    *  @name  insertDrivers
    *  @description Insert Drivers
    *  @param hlgpi - The incoming HLPR_LeadGeneralPartyInfo
    *  @param opp - The inserted opportunity
    *  @param gpi - The inserted general party info
    */
    
    private static void insertDrivers(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
        List<ILP_Opportunity_Driver__c> driverList = new List<ILP_Opportunity_Driver__c>();
        List<HLPR_LeadDriver> leadDriverList = hlgpi.leadDriverList;

        for(HLPR_LeadDriver hldriver : leadDriverList) {
            ILP_Opportunity_Driver__c driver = new ILP_Opportunity_Driver__c();  
            driver.AgeFirstLicenseIssued__c = hldriver.AgeFirstDrivingLicenseIssued;
            driver.Bankruptcy__c = hldriver.Bankruptcy;
            driver.BankruptcyDate__c = hldriver.BankruptcyDate;
            driver.BirthDate__c = hldriver.BirthDate;
            driver.CreditStanding__c = hldriver.CreditStanding;
            driver.Discounts__c = hldriver.Discounts;
            driver.Education__c = hldriver.Education;
            driver.Employed__c = hldriver.Employed;
            driver.EmployerAddress__c = hldriver.EmployerAddress;
            driver.EmployerName__c = hldriver.EmployerName;
            driver.FirstName__c = hldriver.FirstName;
            driver.Gender__c = hldriver.Gender;
            driver.GoodStudent__c = hldriver.GoodStudent;
            driver.LastName__c = hldriver.LastName;
            driver.LicenseDateIssued__c = hldriver.DateLicenseWasIssued;
            driver.LicenseNumber__c = hldriver.LicenseNumber;
            driver.LicenseStateIssued__c = hldriver.StateLicenseIssued;
            driver.MaritalStatus__c = hldriver.MaritalStatus;
            driver.MiddleName__c = hldriver.MiddleName;
            driver.Occupation__c = hldriver.Occupation;
            driver.RelationToOpportunity__c = hldriver.RelationToOpportunity;
            driver.TimeWithEmployer__c = hldriver.TimeWithEmployer;
            driver.Training__c = hldriver.Training;
            driver.TrainingCompleteDate__c = hldriver.TrainingCompletedDate;
            driver.Opportunity__c = opp.Id;
            driver.GeneralPartyInfo__c = gpi.Id;
            
            driverList.add(driver);
        }

        if(!driverList.isEmpty()) {
            UTIL_LeadDriverDAO.insertOpportunityDrivers(driverList);
        }
    }
    
    
   /**
    *  Sets up and Inserts the Lead Vehicles
    *  @description Insert Vehicles
    *  @name  insertVehicles
    *  @param hlgpi - The incoming HLPR_LeadGeneralPartyInfo
    *  @param opp - The inserted opportunity
    *  @param gpi - The inserted general party info
    */
    
    private static void insertVehicles(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
        List<ILP_Opportunity_Vehicle__c> vehicleList = new List<ILP_Opportunity_Vehicle__c>();
        List<HLPR_LeadVehicle> leadVehicleList = hlgpi.leadVehicleList;

        for(HLPR_LeadVehicle hlvehicle : leadVehicleList) {
            ILP_Opportunity_Vehicle__c vehicle = new ILP_Opportunity_Vehicle__c();   
            vehicle.AirbagType__c = hlvehicle.AirbagType;
            vehicle.CustomizationAmount__c = hlvehicle.CustomizationAmount;
            vehicle.Discounts__c = hlvehicle.Discounts;
            vehicle.EstimatedAnnualMileage__c = hlvehicle.EstimatedAnnualMileage;
            vehicle.Make__c = hlvehicle.Make;
            vehicle.MileageOneWay__c = hlvehicle.MileageOneWay;
            vehicle.Model__c = hlvehicle.Model;
            vehicle.OdometerReading__c = hlvehicle.OdometerReading;
            vehicle.Ownership__c = hlvehicle.Ownership;
            vehicle.Submodel__c = hlvehicle.Submodel;
            vehicle.VIN__c = hlvehicle.VIN;
            vehicle.Year__c = hlvehicle.Year;
            vehicle.Opportunity__c = opp.Id;
            vehicle.GeneralPartyInfo__c = gpi.Id;
            
            vehicleList.add(vehicle);
        }

        if(!vehicleList.isEmpty()) {
            UTIL_LeadVehicleDAO.insertOpportunityVehicles(vehicleList);
        }
    }
    
    
   /**
    *  Sets up and Inserts the Lead Dwellings
    *  @name  insertDwellings
    *  @description Insert Dwellings
    *  @param hlgpi - The incoming HLPR_LeadGeneralPartyInfo
    *  @param opp - The inserted opportunity
    *  @param gpi - The inserted general party info
    */
    
    private static void insertDwellings(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
        msgWrap.insertDwellings(hlgpi, opp, gpi);
    }
    
    
   /**
    *  Sets up and Inserts the Lead Business Info
    *  @name  insertBusinessInfos
    *  @description Insert Business Infos
    *  @param hlgpi - The incoming HLPR_LeadGeneralPartyInfo
    *  @param opp - The inserted opportunity
    *  @param gpi - The inserted general party info
    */
    
    private static void insertBusinessInfos(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
        msgWrap.insertBusinessInfos(hlgpi, opp, gpi);
    }
    
    
   /**
    *  Sets up and Inserts the Lead Life Insured Info
    *  @name  insertLifeInsuredInfos
    *  @description Insert Life Insured Infos
    *  @param hlgpi - The incoming HLPR_LeadGeneralPartyInfo
    *  @param opp - The inserted opportunity
    *  @param gpi - The inserted general party info
    */
    
    private static void insertLifeInsuredInfos(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
        msgWrap.insertLifeInsuredInfos(hlgpi, opp, gpi);
    }
    
    
   /**
    *  Sets up and Inserts the Lead Coverages
    *  @name  insertCoverages
    *  @description Insert Coverages
    *  @param hlgpi - The incoming HLPR_LeadGeneralPartyInfo
    *  @param opp - The inserted opportunity
    *  @param gpi - The inserted general party info
    */
    
    private static void insertCoverages(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
        msgWrap.insertCoverages(hlgpi, opp, gpi);
    }
    
    
   /**
    *  Sets up and Inserts the Lead Moving Violations
    *  @name  insertMovingViolations
    *  @description Insert Moving Violations
    *  @param hlgpi - The incoming HLPR_LeadGeneralPartyInfo
    *  @param opp - The inserted opportunity
    *  @param gpi - The inserted general party info
    */
    
    private static void insertMovingViolations(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
        msgWrap.insertMovingViolations(hlgpi, opp, gpi);
    }
    
    
   /**
    *  Asynchronous post messages
    *  @name  postMessages
    *  @description Post Messages
    *  @param opportunityId - The opportunity to Post
    */
    private static void postMessages(String opportunityId) {        
        UTIL_OpportunityNotificationManager.postOppNotifications(new List<String>{opportunityId});
    }
    
    private with sharing class WS_LeadVendorMessageServiceWrapper{

        private void insertMovingViolations(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
            List<ILP_Opportunity_Moving_Violation__c> movingViolationList = new List<ILP_Opportunity_Moving_Violation__c>();
            List<HLPR_LeadMovingViolation> hlavList = hlgpi.leadMovingViolationList;

            for(HLPR_LeadMovingViolation hlav : hlavList) {
                ILP_Opportunity_Moving_Violation__c av = new ILP_Opportunity_Moving_Violation__c();   

                av.Date__c = hlav.ViolationDate;
                av.Description__c = hlav.ViolationDescription;
                av.Type__c = hlav.ViolationType;
                av.Opportunity__c = opp.Id;
                av.GeneralPartyInfo__c = gpi.Id;
                
                movingViolationList.add(av);
            }

            if(!movingViolationList.isEmpty()) {
                UTIL_LeadMovingViolationDAO.insertOpportunityMovingViolations(movingViolationList);
            }
        }
        
        private void insertCoverages(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
            List<ILP_Opportunity_Coverage__c> opportunityCoverageList = new List<ILP_Opportunity_Coverage__c>();
            List<HLPR_LeadCoverage> hlocList = hlgpi.leadCoverageList;

            for(HLPR_LeadCoverage hloc : hlocList) {
                ILP_Opportunity_Coverage__c oc = new ILP_Opportunity_Coverage__c();   

                oc.Deductible__c = hloc.Deductible;
                oc.Description__c = hloc.Description;
                oc.Limit__c = hloc.CoverageLimit;
                oc.RequestedOrCurrent__c = hloc.RequestedOrCurrent;
                oc.Type__c = hloc.Type;
                oc.Opportunity__c = opp.Id;
                oc.GeneralPartyInfo__c = gpi.Id;
                
                opportunityCoverageList.add(oc);
            }

            if(!opportunityCoverageList.isEmpty()) {
                UTIL_LeadOpportunityCoverageDAO.insertOpportunityCoverages(opportunityCoverageList);
            }
        }
        
        private void insertLifeInsuredInfos(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
            List<ILP_Opportunity_LifeInsuredInfo__c> lifeInsuredInfoList = new List<ILP_Opportunity_LifeInsuredInfo__c>();
            List<HLPR_LeadLifeInsuredInfo> hlliiList = hlgpi.leadLifeInsuredInfoList;

            for(HLPR_LeadLifeInsuredInfo hllii : hlliiList) {
                ILP_Opportunity_LifeInsuredInfo__c lii = new ILP_Opportunity_LifeInsuredInfo__c();   

                lii.BirthDate__c = hllii.BirthDate;
                lii.Employer__c = hllii.Employer;
                lii.FirstName__c = hllii.FirstName;
                lii.Gender__c = hllii.Gender;
                lii.HealthCategory__c = hllii.HealthCategory;
                lii.Height__c = hllii.Height;
                lii.LastName__c = hllii.LastName;
                lii.MaritalStatus__c = hllii.MaritalStatus;
                lii.MiddleName__c = hllii.MiddleName;
                lii.Occupation__c = hllii.Occupation;
                lii.RelationshipToOpportunity__c = hllii.RelationshipToOpportunity;
                lii.Smoker__c = hllii.Smoker;
                lii.TimeWithEmployer__c = hllii.TimeWithEmployer;
                lii.Weight__c = hllii.Weight;
                lii.Opportunity__c = opp.Id;
                lii.GeneralPartyInfo__c = gpi.Id;
                
                lifeInsuredInfoList.add(lii);
            }

            if (!lifeInsuredInfoList.isEmpty()) {
                UTIL_LeadLifeInsuredInfoDAO.insertOpportunityLifeInsuredInfos(lifeInsuredInfoList);
            }
        }
        
        private void insertBusinessInfos(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
            List<ILP_Opportunity_BusinessInfo__c> businessInfoList = new List<ILP_Opportunity_BusinessInfo__c>();
            List<HLPR_LeadBusinessInfo> leadBusinessInfoList = hlgpi.leadBusinessInfoList;

            for(HLPR_LeadBusinessInfo hlbi : leadBusinessInfoList) {
                ILP_Opportunity_BusinessInfo__c businessInfo = new ILP_Opportunity_BusinessInfo__c();   

                businessInfo.AnnualGrossSales__c = hlbi.AnnualGrossSale;
                businessInfo.Description__c = hlbi.Description;
                businessInfo.EstimatedAnnualRentLeaseCosts__c = hlbi.EstimatedAnnualCostRentLease;
                businessInfo.HasRentedLeasedVehicles__c = hlbi.HasRentedLeasedVehicle;
                businessInfo.JobDuties__c = hlbi.JobDuties;
                businessInfo.NumEmployees__c = hlbi.NumberOfEmployees;
                businessInfo.PayrollCosts__c = hlbi.PayrollCosts;
                businessInfo.SubcontractedDuties__c = hlbi.SubcontractedDuties;
                businessInfo.TotalCosts__c = hlbi.TotalCosts;
                businessInfo.Type__c = hlbi.Type;
                businessInfo.YearsInBusiness__c = hlbi.YearsInBusiness;
                businessInfo.Opportunity__c = opp.Id;
                businessInfo.GeneralPartyInfo__c = gpi.Id;
                
                businessInfoList.add(businessInfo);
            }

            if(!businessInfoList.isEmpty()) {
                UTIL_LeadBusinessInfoDAO.insertOpportunityBusinessInfos(businessInfoList);
            }
        }
        
        private void insertDwellings(HLPR_LeadGeneralPartyInfo hlgpi, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi) {
            List<ILP_Opportunity_Dwelling__c> dwellingList = new List<ILP_Opportunity_Dwelling__c>();
            List<HLPR_LeadDwelling> leadDwellingList = hlgpi.leadDwellingList;

            for(HLPR_LeadDwelling hld : leadDwellingList) {
                ILP_Opportunity_Dwelling__c dwelling = new ILP_Opportunity_Dwelling__c();   
                dwelling.ConstructionType__c = hld.ConstructionType;
                dwelling.DistanceFireHydrant__c = hld.DistanceFireHydrant;
                dwelling.DistanceFireStation__c = hld.DistanceFireStation;
                dwelling.FoundationType__c = hld.FoundationType;
                dwelling.HasCarportOrGarage__c = hld.HasCarportOrGarage;
                dwelling.HasCentralAir__c = hld.HasCentralAir;
                dwelling.HasCoveredPatio__c = hld.HasCoveredPatio;
                dwelling.HasDeadboltLocks__c = hld.HasDeadboltLocks;
                dwelling.HasDog__c = hld.HasDog;
                dwelling.HasFireExtinguisher__c = hld.HasFireExtinguisher;
                dwelling.HasFireSprinkler__c = hld.HasFireSprinkler;
                dwelling.HasPool__c = hld.HasPool;
                dwelling.HasPoolFence__c = hld.HasPoolFence;
                dwelling.HasSecuritySystem__c = hld.HasSecuritySystem;
                dwelling.HasSmokeAlarm__c = hld.HasSmokeAlarm;
                dwelling.HeatingType__c = hld.HeatingType;
                dwelling.NumBathrooms__c = hld.NumberOfBathrooms;
                dwelling.NumBedrooms__c = hld.NumberOfBedrooms;
                dwelling.NumFireplaces__c = hld.NumberOfFireplaces;
                dwelling.NumFloors__c = hld.NumberOfFloors;
                dwelling.NumUnits__c = hld.NumberOfUnits;
                dwelling.PurchaseDate__c = hld.PurchaseDate;
                dwelling.RoofType__c = hld.RoofType;
                dwelling.Type__c = hld.Type;
                dwelling.Value__c = hld.Value;
                dwelling.WiringType__c = hld.WiringType;
                dwelling.WithinCityLimits__c = hld.WithinCityLimits;
                dwelling.YearBuilt__c = hld.YearBuilt;
                dwelling.Opportunity__c = opp.Id;
                dwelling.GeneralPartyInfo__c = gpi.Id;

                dwellingList.add(dwelling);
            }

            if(!dwellingList.isEmpty()) {
                UTIL_LeadDwellingDAO.insertOpportunityDwellings(dwellingList);
            }
        }
        
        private Account upsertAccount(HLPR_LeadVendorMessage lvm) {
                
            //Fetching record type id's available for Account object
            String accountRecordTypeId = '';
            Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
            try {
                accountRecordTypeId = accountRecordTypeMap.get(lvm.leadaccount.AccountType).RecordTypeId;
            } catch (Exception e) {
                throw new HLPR_LeadVendorMessageServiceException(System.Label.CL_AccountType_Invalid_Message);            
            }
            
            if(!(accountRecordTypeId!=null && accountRecordTypeId != NULL_SYMBOL)){
                throw new HLPR_LeadVendorMessageServiceException(System.Label.CL_AccountType_Invalid_Message);  
            }
            
            Account acc = new Account();                 
            String tempName='';
            String oppName = lvm.leadopportunity.Name;
            tempName = oppName.substringAfter(HYPHEN_SYMBOL);
            if(lvm.leadaccount.AccountType != System.Label.CL_Account_Organization)
            {            
            acc = createAccountIndividualName(tempName);       
            }else
            {
            acc = createAccountOrganizationName(tempName);          
            }
            acc.RecordTypeId = accountRecordTypeId;  //Assumption to get record type name for creating account
            acc.ClientIdentifier__c  = lvm.leadaccount.ClientID;
            UTIL_AccountDAO.upsertAccountsByClientIdentifier(new List<Account>{acc});
            return acc;
        }
        
        private Opportunity insertOpportunity(HLPR_LeadVendorMessage lvm, Account acc, AgentRole__c agr) {   
            Opportunity opp = new Opportunity();
            
        
            opp.RecordTypeId = optyRecordTypeId;
            opp.Name = lvm.leadopportunity.Name;
            opp.StageName = lvm.leadopportunity.StageName;
            opp.CloseDate = CLOSED_DATE;
            opp.ProspectCost__c = lvm.leadopportunity.ProspectCost;
            opp.LeadType__c = lvm.leadopportunity.LeadType;
            opp.LOB__c = lvm.leadopportunity.LOB;
            opp.Opportunity_Originator__c = lvm.leadopportunity.Opportunity_Originator;
            opp.Product__c = lvm.leadopportunity.Product;
            opp.OpportunityDetail__c  = lvm.leadopportunity.OpportunityDetail;
            opp.Subsidy__c = lvm.leadopportunity.Subsidy;
            opp.SubsidyAmount__c = lvm.leadopportunity.SubsidyAmount;
            opp.Email__c = lvm.leadopportunity.Email;
            opp.Phone__c = lvm.leadopportunity.Phone;
            opp.Vendor_ID__c = lvm.leadopportunity.VendorId;
            opp.ExternalILPId__c = lvm.leadopportunity.LeadId;
            opp.Transaction_ID__c  = lvm.leadopportunity.LeadTransactionId;
            opp.Validator_ID__c  = lvm.leadopportunity.ValidatorID;
            opp.Lead_Validation_Date__c = Date.today();
            opp.AccountId = acc.Id;
            opp.ExternalID__c = lvm.leadopportunity.ExternalId;
            
            if(!String.isBlank(opp.Vendor_ID__c)){
                List<CM_ILP_Vendor_Name__mdt> mappingForVendorIdProcessor = Security.stripInaccessible(AccessType.READABLE, [select Marketing_Source__c from CM_ILP_Vendor_Name__mdt where Vendor_ID__c =: opp.Vendor_ID__c LIMIT 1]).getRecords();
                if(!mappingForVendorIdProcessor.isEmpty() && mappingForVendorIdProcessor[0].Marketing_Source__c != null){
                    opp.Marketing_Source__c = mappingForVendorIdProcessor[0].Marketing_Source__c;
            
                } else {
                    throw new HLPR_LeadVendorMessageServiceException(System.Label.CL_VendorID_Invalid_Message);
                }

            } else {
                throw new HLPR_LeadVendorMessageServiceException(System.Label.CL_VendorID_Null_Message);
            }

            User proxy = UTIL_AgentProxySelection.retrieveProxyForLoggedInAgentOrATM(agr.Agent__c);
            opp.OwnerId = proxy.Id;
                    
            UTIL_OpportunityDAO.insertOpportunityForAccount(new List<Opportunity>{opp});

            try {
                insertGeneralPartyInfo(lvm, opp);
            } catch (Exception ex) {
                LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            }
            
            return opp;
        }
    }
    
    private class WS_LeadVendorMessageServiceWrapper2{
        private void insertGeneralPartyInfo(HLPR_LeadVendorMessage lvm, Opportunity opp) {
            HLPR_LeadGeneralPartyInfo leadGeneralPartyInfo = lvm.leadopportunity.leadGeneralPartyInfo;
            
            if(leadGeneralPartyInfo != null) {
                ILP_Opportunity_General_Party_Info__c gpi = new ILP_Opportunity_General_Party_Info__c();   
        
                gpi.Citizenship__c = leadGeneralPartyInfo.Citizenship;
                gpi.ContactPreference__c = leadGeneralPartyInfo.ContactPreference;
                gpi.Designation__c = leadGeneralPartyInfo.Designation;
                gpi.Email__c = leadGeneralPartyInfo.Email;
                gpi.FirstName__c = leadGeneralPartyInfo.FirstName;
                gpi.HomePhone__c = leadGeneralPartyInfo.HomePhone;
                gpi.InsuranceCancellation__c = leadGeneralPartyInfo.InsuranceCancellation;
                gpi.InsuranceCancellationDate__c = leadGeneralPartyInfo.InsuranceCancellationDate;
                gpi.InsuranceCancellationReason__c = leadGeneralPartyInfo.InsuranceCancellationReason;
                gpi.InsuranceRenewalDate__c = leadGeneralPartyInfo.InsuranceRenewalDate;
                gpi.Language__c = leadGeneralPartyInfo.Language;
                gpi.LastName__c = leadGeneralPartyInfo.LastName;
                gpi.MiddleName__c = leadGeneralPartyInfo.MiddleName;
                gpi.MilitaryService__c = leadGeneralPartyInfo.MilitaryService;
                gpi.MobilePhone__c = leadGeneralPartyInfo.MobilePhone;
                gpi.MonthsWithCarrier__c = leadGeneralPartyInfo.MonthsWithCarrier;
                gpi.NameOfCarrier__c = leadGeneralPartyInfo.NameOfCarrier;
                gpi.TDDPhone__c = leadGeneralPartyInfo.TDDPhone;
                gpi.TotalYearsInsured__c = leadGeneralPartyInfo.TotalYearsInsured;
                gpi.WorkExt__c = leadGeneralPartyInfo.WorkExtension;
                gpi.WorkPhone__c = leadGeneralPartyInfo.WorkPhone;
                gpi.Opportunity__c = opp.Id;
     
                UTIL_LeadGeneralPartyInfoDAO.insertOpportunityGeneralPartyInfo(gpi);
                
                try {
                    if (leadGeneralPartyInfo.leadAddressList != null) {
                        insertAddresses(leadGeneralPartyInfo, opp, gpi);
                    }
                } catch (Exception ex) {
                    LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
                }
                try {
                    if (leadGeneralPartyInfo.leadClaimList != null) {
                        insertClaims(leadGeneralPartyInfo, opp, gpi);
                    }
                } catch (Exception ex) {
                    LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
                }
                insertDriversVehiclesDwellingsBusinessInfos(leadGeneralPartyInfo, opp, gpi);                            
            }
        }
        
        private void insertDriversVehiclesDwellingsBusinessInfos(HLPR_LeadGeneralPartyInfo leadGeneralPartyInfo, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi){
            try {
                if (leadGeneralPartyInfo.leadDriverList != null) {
                    insertDrivers(leadGeneralPartyInfo, opp, gpi);
                }
            } catch (Exception ex) {
                LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            }
            try {
                if (leadGeneralPartyInfo.leadVehicleList != null) {
                    insertVehicles(leadGeneralPartyInfo, opp, gpi);
                }
            } catch (Exception ex) {
                LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            }
            try {
                if (leadGeneralPartyInfo.leadDwellingList != null) {
                    insertDwellings(leadGeneralPartyInfo, opp, gpi);
                }
            } catch (Exception ex) {
                LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            }
            try {
                if (leadGeneralPartyInfo.leadBusinessInfoList != null) {
                    insertBusinessInfos(leadGeneralPartyInfo, opp, gpi);
                }
            } catch (Exception ex) {
                LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            }
            insertLifeInsuredInfosCoveragesMovingViolations(leadGeneralPartyInfo, opp, gpi);
        }
        
        private void insertLifeInsuredInfosCoveragesMovingViolations(HLPR_LeadGeneralPartyInfo leadGeneralPartyInfo, Opportunity opp, ILP_Opportunity_General_Party_Info__c gpi){
            try {
                if (leadGeneralPartyInfo.leadLifeInsuredInfoList != null) {
                    insertLifeInsuredInfos(leadGeneralPartyInfo, opp, gpi);
                }
            } catch (Exception ex) {
                LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            }
            try {
                if (leadGeneralPartyInfo.leadCoverageList != null) {
                    insertCoverages(leadGeneralPartyInfo, opp, gpi);
                }
            } catch (Exception ex) {
                LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            }
            try {
                if (leadGeneralPartyInfo.leadMovingViolationList != null) {
                    insertMovingViolations(leadGeneralPartyInfo, opp, gpi);
                }
            } catch (Exception ex) {
                LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_VENDOR_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            }
        }
    }
}