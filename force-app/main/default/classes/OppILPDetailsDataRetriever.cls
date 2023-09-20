/** 
@Author Team AKITA
@Name OppILPDetailsDataRetriever
@CreateDate 10/15/2021  
@description class that queries all the ILP Object data for lwcOppILPDetails
@Version 1.0
Copyright © StateFarm  
*/
public with sharing class OppILPDetailsDataRetriever {
    static List<List<SObject>> allILPObjects = new List<List<SObject>>();
    static List<Opportunity> emptyObjectList = new List<Opportunity>();

    /**
    * @description Method to get all the ILP Object data for a single Opp record
    * @param oppRecord
    * @return 2-dimensional List of Lists of SObjects
    */
    @AuraEnabled(cacheable=true)
    public static List<List<SObject>> getAllILPObjects(Id oppRecord) {
        List<Opportunity> combinedQueryData = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT (SELECT FirstName__c, LastName__c, Designation__c, MilitaryService__c, Citizenship__c,
                            HomePhone__c, MobilePhone__c, WorkPhone__c, Email__c, ContactPreference__c, Language__c,
                            NameOfCarrier__c, MonthsWithCarrier__c, InsuranceCancellationReason__c FROM General_Party_Infos__r), 
                    (SELECT Type__c, Address1__c, Address2__c, City__c, State__c, Zip__c, Country__c FROM Opportunity_Addresses__r),
                    (SELECT Description__c, Type__c, Limit__c, Deductible__c FROM OpportunityCoverages__r),
                    (SELECT FirstName__c, LastName__c, BirthDate__c, LicenseNumber__c, LicenseStateIssued__c,
                            LicenseDateIssued__c, MaritalStatus__c, RelationToOpportunity__c, Gender__c,
                            Occupation__c, Education__c, Employed__c, GoodStudent__c, Training__c, TrainingCompleteDate__c FROM Drivers__r),
                    (SELECT Type__c, Date__c FROM Moving_Violations__r),
                    (SELECT Type__c, JobDuties__c, YearsInBusiness__c, AnnualGrossSales__c, NumEmployees__c, PayrollCosts__c,
                            SubcontractedDuties__c, TotalCosts__c, HasRentedLeasedVehicles__c, EstimatedAnnualRentLeaseCosts__c FROM BusinessInfos__r),
                    (SELECT YearBuilt__c, Type__c, NumUnits__c, ConstructionType__c, RoofType__c, PurchaseDate__c, FoundationType__c, 
                            HasCarportOrGarage__c, DistanceFireStation__c, DistanceFireHydrant__c, NumFloors__c, NumBathrooms__c, NumFireplaces__c, 
                            WiringType__c , HeatingType__c, HasPool__c, HasPoolFence__c, HasCentralAir__c, HasDog__c, HasSmokeAlarm__c,
                            HasFireExtinguisher__c, HasFireSprinkler__c FROM Dwellings__r),
                    (SELECT Description__c, TypeOfLoss__c, Date__c, AmountPaid__c FROM Claims__r),
                    (SELECT Year__c, Make__c, Model__c, VIN__c, EstimatedAnnualMileage__c, MileageOneWay__c, OdometerReading__c, CustomizationAmount__c FROM Vehicles__r),
                    (SELECT FirstName__c, MiddleName__c, LastName__c, BirthDate__c, Gender__c, MaritalStatus__c, RelationshipToOpportunity__c FROM LifeInsuredInfos__r)
            FROM Opportunity
            WHERE Id =: oppRecord Limit 1]
        ).getRecords();
        
        if (combinedQueryData[0].General_Party_Infos__r.size() > 0) {
            allILPObjects.add(combinedQueryData[0].General_Party_Infos__r);
        }
        else {
            throw new DataNotFoundException('Apex returned no records');
        }
        
        addToAllSObjectsList(combinedQueryData[0].Opportunity_Addresses__r.size(), (List<SObject>)combinedQueryData[0].Opportunity_Addresses__r);
        addToAllSObjectsList(combinedQueryData[0].OpportunityCoverages__r.size(), (List<SObject>)combinedQueryData[0].OpportunityCoverages__r);
        addToAllSObjectsList(combinedQueryData[0].Drivers__r.size(), (List<SObject>)combinedQueryData[0].Drivers__r);
        addToAllSObjectsList(combinedQueryData[0].Moving_Violations__r.size(), (List<SObject>)combinedQueryData[0].Moving_Violations__r);
        addToAllSObjectsList(combinedQueryData[0].BusinessInfos__r.size(), (List<SObject>)combinedQueryData[0].BusinessInfos__r);
        addToAllSObjectsList(combinedQueryData[0].Dwellings__r.size(), (List<SObject>)combinedQueryData[0].Dwellings__r);
        addToAllSObjectsList(combinedQueryData[0].Claims__r.size(), (List<SObject>)combinedQueryData[0].Claims__r);
        addToAllSObjectsList(combinedQueryData[0].Vehicles__r.size(), (List<SObject>)combinedQueryData[0].Vehicles__r);
        addToAllSObjectsList(combinedQueryData[0].LifeInsuredInfos__r.size(), (List<SObject>)combinedQueryData[0].LifeInsuredInfos__r);
        
        return allILPObjects;
    }

    /**
    * @description Method to get the required parameters for Bundle API
    * @param sObjectSize size of the SObject list
    * @param ilpSObject the actual SObject list
    */
    public static void addToAllSObjectsList(Integer sObjectSize, List<SObject> ilpSObject) {
        if (sObjectSize > 0) {
            allILPObjects.add(ilpSObject);
        } else {
            allILPObjects.add(emptyObjectList);
        }
    }
}