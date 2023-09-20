/****************************************************************************************
Name: UTIL_LtngJourneyProcess 
Copyright © State Farm
=========================================================================================
Purpose: Helper class for Apex class HLPR_JourneyStepProcessing used by JourneyStep Lightning
Component
@description Helper class for Apex class HLPR_JourneyStepProcessing used by JourneyStep Lightning Component

Team: ClubCar
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  10/11/2018              Initial Development
2.0             ClubCar                  02/18/2020              Updated PMD finding for CRUD violations
******************************************************************************************/
public with sharing class UTIL_LtngJourneyProcess {
    /**
	* @description Method to retrieve Logged in user Alias
	* @return loggedInUser.Alias - returns loggedin user alias
	*/
    public static String getUserAlias (){
        return [Select id, Alias from User where id =: Userinfo.getUserId() WITH SECURITY_ENFORCED Limit 1].Alias;
    }
    /**
	* @description retrieve next Journey Step Id based on Journey Id
	* @param journeyId
	* @return stepId
	*/
    public static Integer getJourneyStepId (Id journeyId ) {
        List<Journey_Step__c> jnyStepList = new List<Journey_Step__c>();    
        Integer stepId = 1;
        jnyStepList = [Select id, JourneyStepID__c from Journey_Step__c where JourneyID__c =: journeyId WITH SECURITY_ENFORCED ORDER BY JourneyStepID__c  DESC LIMIT 1];        
        if (!jnyStepList.isEmpty()) {
            Decimal jnyStepId = jnyStepList[0].JourneyStepID__c;
            stepId = Integer.valueOf(jnyStepId);
            stepId ++;
        }      
        return stepId;
    }   
    /**
	* @description Method to retrieve Journey based on Journey Id
	* @param journeyId
	* @return jny - returns Journey record
	*/
    public static Journey__c getMasterJourney (Id journeyId ) {
        return [Select id, JourneyNumber__c, name from Journey__c where id =: journeyId WITH SECURITY_ENFORCED];
    }
}