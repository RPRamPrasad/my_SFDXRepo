/**
 * @description OppCalJrnyStartDate 
 */
public with sharing class OppCalJrnyStartDate {

    private static final String XDATE_SEARCH_KEYWORD= 'Xdate';
    private static final Integer STEP_ID_ONE = 1;
    private static Integer sunday = 7;
    private static Integer saturday = 6;
    private static Integer nextSunday = 14;
    private static Integer hourOfDayTwelve = 12;
    private static Integer days180 = 180;
    private static Integer daysZero = 0;
    private static Integer addOne = 1;
    private static final String DATETIME_FORMAT_DAYOFWEEK = 'u';
    @TestVisible private static DateTime currentDateTime = DateTime.now();
    private static Date currentdate = System.Today();
    private static DateTime updatedDateTime;
    private static Date toBeUpdatedDate;
/**
 * @description calculateJourneyStartDate
 * @param currentOpp 
 * @param currentJourney 
 * @return  `Date`
 */
    @AuraEnabled
    public static Date calculateJourneyStartDate(Opportunity currentOpp, Journey__c currentJourney){
        Date journeyStartDate;
        try {
            if (currentJourney.Type__c.equals(XDATE_SEARCH_KEYWORD)) {
                Integer firstJnyStepdaysNum = getJourneyStepDaysNum(currentJourney.id);
                journeyStartDate = calXdateOppJourneyStartDate(currentOpp, firstJnyStepDaysNum);
            }
            else {                
                journeyStartDate = calculateOppStartDate();                
            }
            return journeyStartDate;
        } catch (Exception e) {
            return null;
        }
    }
    
    private static Date calculateOppStartDate() {            
 
        Integer dayOfWeek = Integer.valueOf(currentDateTime.format(DATETIME_FORMAT_DAYOFWEEK));
        Integer hourOfDay = Integer.valueOf(currentDateTime.hour());            
        if(dayOfWeek < saturday || (dayOfWeek == saturday && (hourOfDay < hourOfDayTwelve))) {
           updatedDateTime = currentDateTime.addDays(sunday - dayOfWeek);   //current week
        }
        else {
            updatedDateTime = currentDateTime.addDays(nextSunday - dayOfWeek); //next week
        }
        toBeUpdatedDate = updatedDateTime.date();
        return toBeUpdatedDate;            
    } 

    /**
    * @description Helper method to calculate Opportunity Journey Start Date for Xdate Journey's
    *           If Opportunity Xdate is not blank and greater then current date, use Xdate as StartDate
    *           Else add multiples of 180 days to Opportunity created date till it is greater than or equal to current date
    * @name - calXdateOppJourneyStartDate
    * @param currentOpp - Oppoortunity Record
	* @param stepOneDaysNum - No of days
    * @return finalDate - Date - Opportunity - Journey Start Date
    */
    @AuraEnabled
    public static Date calXdateOppJourneyStartDate(Opportunity currentOpp, Integer stepOneDaysNum) {

        Date finalDate;
        Date conCreatedDate = currentOpp.CreatedDate.date();
        if (currentOpp.X_Date__c != null) { //Check Xdate is not blank
            finaldate = calXdateNotNull(currentOpp.X_Date__c,stepOneDaysNum);
        }
        else { // Xdate null - using Opp created date
            finaldate = calXdateNull(conCreatedDate,stepOneDaysNum);      
        }
        return finalDate;          
    }
    /**
     * @description calXdateNotNull 
     * @param currentOppXDate 
     * @param daysNum 
     * @return  `Date`
     */
    public static Date calXdateNotNull(Date currentOppXDate, Integer daysNum) {
        Date finalDate;
        Integer daysDifference;
        if (currentOppXDate >= currentdate) { //Xdate greater than current date
            if (currentOppXDate >= currentdate.AddDays(days180 - daysNum)) {
                finalDate = currentOppXDate.AddDays(-days180);                      
            }
            else {
                finalDate = currentOppXDate;
            }                                        
        }
        else { //Past Xdate scenario - Less than current date               
            if (currentOppXDate.AddDays(daysNum)>= currentdate) {
                finaldate = currentOppXDate;
            }                   
            else {
                daysDifference = currentOppXDate.daysBetween(currentdate);
                finalDate = calXdateSixMonths(currentOppXDate,daysDifference);   
            }               
        }
        return finalDate;
    }
    /**
     * @description calXdateNull
     * @param conCreatedDate 
     * @param daysNum 
     * @return  `Date`
     */
    public static Date calXdateNull(Date conCreatedDate, Integer daysNum) {
        date finalDate;
        Integer daysDifference; 
        if (conCreatedDate.AddDays(daysNum)>= currentdate) {
            finaldate = conCreatedDate;
        }
        else {              
            daysDifference = conCreatedDate.daysBetween(currentdate);
            finalDate = calXdateSixMonths(conCreatedDate,daysDifference);               
        } 
        return finalDate;
    }
    ///
    /**
     * @description calXdateSixMonths
     * @param calDate 
     * @param daysDifference 
     * @return  `Date`
     */
    public static Date calXdateSixMonths(Date calDate, Integer daysDifference) {
        Date finalDate; 
        Integer numberToMultiply;
        Integer totalDaysToAdd; 
        if (Math.mod(daysDifference, days180) == daysZero ) { //Current Date - No remainder    
            numberToMultiply = (daysDifference / days180);  
            totalDaysToAdd = days180 * numberToMultiply; 
            finalDate = calDate.AddDays(totalDaysToAdd);
        }
        else { //Current Date - remainder
            numberToMultiply = (daysDifference / days180) + addOne;
            totalDaysToAdd = days180 * numberToMultiply;
            finalDate = calDate.AddDays(totalDaysToAdd);                
        }                
        return finalDate;
    }
    ///
    private static Integer getJourneyStepDaysNum (Id currentJourneyId) {
        List<Journey_Step__c> jnyStepFirstList = [SELECT DaysNum__c FROM Journey_Step__c WHERE JourneyStepID__c =: STEP_ID_ONE AND JourneyID__c =: currentJourneyId WITH SECURITY_ENFORCED];
        return jnyStepFirstList[0].DaysNum__c.intvalue();
    }
}