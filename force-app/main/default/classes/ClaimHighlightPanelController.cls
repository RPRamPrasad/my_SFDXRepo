/**
 * @author Team Moneyball
 * Date Created : 10/18/2022
 * @description Controller to be utilized in claimHighlightpanel LWC.
 * Version : 1.0
 */
public with sharing class ClaimHighlightPanelController {
    /**
     * @description getIndicator
     * @param claimId 
     * @param isAuto 
     * @return  `IndicatorWrapper`
     * @exception 
     */
    @AuraEnabled(cacheable=true)
    public static IndicatorWrapper getIndicator(Id claimId, Boolean isAuto) {
        IndicatorWrapper indicatorWrap = new IndicatorWrapper();
        try {
            if (!isAuto) {
                return null;
            }
            List<claimparticipant> lossParticpants = new List<claimparticipant>();

            lossParticpants = Security.stripInaccessible(
                    AccessType.READABLE,
                    [
                        SELECT Id, claimId
                        FROM claimparticipant
                        WHERE claimId = :claimId AND TotalLossIndicator__c = TRUE
                        LIMIT 1
                    ]
                )
                .getRecords();

            List<claimparticipant> deceasedParticipants = new List<claimparticipant>();
            deceasedParticipants = Security.stripInaccessible(
                    AccessType.READABLE,
                    [
                        SELECT Id, claimId
                        FROM claimparticipant
                        WHERE claimId = :claimId AND DeceasedIndicator__c = TRUE
                        LIMIT 1
                    ]
                )
                .getRecords();

            indicatorWrap.totalloss = lossParticpants.isEmpty() ? false : true;
            indicatorWrap.deceasedIndicator = deceasedParticipants.isEmpty() ? false : true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return indicatorWrap;
    }

    /**
    * @name getVehicleInfo
    * @description This method is to get vehicleInformation by calling an API.
    * @param input map with the callout name and parameters
    * @return HttpCalloutResponse Wrapped response with status code and body
    */
    @AuraEnabled(cacheable = true)
    public static HttpRequestCalloutHelper.HttpCalloutResponse getVehicleInfo(Map<String, Object> input) {
        try {
            return HttpRequestCalloutHelper.doCallout(input);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @name getParticipantInfo
    * @description This method is to get participantInformation by calling an API.
    * @param input map with the callout name and parameters
    * @return HttpCalloutResponse Wrapped response with status code and body
    */
    @AuraEnabled(cacheable = true)
    public static HttpRequestCalloutHelper.HttpCalloutResponse getParticipantInfo(Map<String, Object> input) {
        try {
            return HttpRequestCalloutHelper.doCallout(input);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * name: IndicatorWrapper
    * @description : wrapper class with @Auraenabled
    */
    public class IndicatorWrapper {
        /**
         * @description totalloss
         */
        @AuraEnabled
        public Boolean totalloss { get; set; }
        /**
         * @description deceasedIndicator
         */
        @AuraEnabled
        public Boolean deceasedIndicator { get; set; }
    }
}
