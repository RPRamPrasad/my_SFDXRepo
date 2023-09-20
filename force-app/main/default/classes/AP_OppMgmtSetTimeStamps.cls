/**
* @description AP_OppMgmtSetTimeStamps
* This is a Apex class which will be invoked from before update trigger and validate if the timestamps are null based on the stage of the opportunity
* @Author Team QuadCore
* @Date 9/08/2021
*/
public with sharing class AP_OppMgmtSetTimeStamps {
        public static final String QUOTING = 'Quoting';
    public static final String QUOTE_DISCUSSED= 'Quote Discussed';
    /**
     * @description setContactEstablishedDate
     * @param updatedOpportunity
     * @return  `Opportunity`
     */
    public static Opportunity setContactEstablishedDate(Opportunity updatedOpportunity){
        if(updatedOpportunity.OppContactEstablishedDateTime__c == null){
            updatedOpportunity.OppContactEstablishedDateTime__c= System.now();
        }
        return updatedOpportunity;
    }
    /**
     * @description setQuoteInProvidedDateTime
     * @param updatedOpportunity
     * @return  `Opportunity`
     */
    public static Opportunity setQuoteInProgressDateTime(Opportunity updatedOpportunity){
        if(updatedOpportunity.OppQuoteInProgressDateTime__c == null){
            updatedOpportunity.OppQuoteInProgressDateTime__c= System.now();
        }
        return updatedOpportunity;
    }
    /**
     * @description setQuoteInProvidedDateTime
     * @param updatedOpportunity
     * @return  `Opportunity`
     */
    public static Opportunity setQuoteInProvidedDateTime(Opportunity updatedOpportunity){
        if(updatedOpportunity.OppQuoteProvidedDateTime__c == null){
            updatedOpportunity.OppQuoteProvidedDateTime__c= System.now();
        }
        return updatedOpportunity;
    }
    /**
     * @description setQuoteProvidedDate
     * @param updatedOpportunity
     * @return  `Opportunity`
     */
    public static Opportunity setQuoteProvidedDate(Opportunity updatedOpportunity){
        if(updatedOpportunity.Quote_Received__c == null){
            updatedOpportunity.Quote_Received__c= System.Today();
        }
        return updatedOpportunity;
    }
    /**
     * @description setQuoteDiscussedDateTime
     * @param updatedOpportunity
     * @return  `Opportunity`
     */
    public static Opportunity setQuoteDiscussedDateTime(Opportunity updatedOpportunity){
        if(updatedOpportunity.OppQuote_Discussed_Timestamp__c == null){
            updatedOpportunity.OppQuote_Discussed_Timestamp__c= System.Now();
        }
        return updatedOpportunity;
    }
    /**
     * @description setAppPendingDateTime
     * @param updatedOpportunity
     * @return  `Opportunity`
     */
    public static Opportunity setAppPendingDateTime(Opportunity updatedOpportunity){
        if(updatedOpportunity.OppAppPendingDateTime__C == null){
            updatedOpportunity.OppAppPendingDateTime__C= System.Now();
        }
        return updatedOpportunity;
    }
    /**
     * @description setAppSubmittedDateTime
     * @param updatedOpportunity
     * @return  `Opportunity`
     */
    public static Opportunity setAppSubmittedDateTime(Opportunity updatedOpportunity){
        if(updatedOpportunity.OppAppSubmittedDateTime__c == null){
            updatedOpportunity.OppAppSubmittedDateTime__c= System.Now();
        }
        return updatedOpportunity;
    }
    /**
     * @description setTimeToQuoteProvided
     * @param updatedOpportunity
     * @return  `Opportunity`
     */
    public static Opportunity setTimeToQuoteProvided(Opportunity updatedOpportunity){
        if(updatedOpportunity.TimeToQuoteprovided__c == null){
            updatedOpportunity.TimeToQuoteprovided__c=   (Date.valueOf(updatedOpportunity.CreatedDate)).daysBetween((System.Now()).date());
        
        }
        return updatedOpportunity;
    }
    /**
     * @description setTimeToAppSubmitted
     * @param updatedOpportunity
     * @return  `Opportunity`
     */
    public static Opportunity setTimeToAppSubmitted(Opportunity updatedOpportunity){
        if(updatedOpportunity.TimeToAppsubmitted__c == null){
            updatedOpportunity.TimeToAppsubmitted__c= (Date.valueOf(updatedOpportunity.CreatedDate)).daysBetween((System.Now()).date());
        }
        return updatedOpportunity;
    }
    /**
     * @description setTimeToClose
     * @param updatedOpportunity
     * @return  `Opportunity`
     */
    public static Opportunity setTimeToClose(Opportunity updatedOpportunity){
        if(updatedOpportunity.TimetoCloseDays__c == null){
            updatedOpportunity.TimetoCloseDays__c= (Date.valueOf(updatedOpportunity.CreatedDate)).daysBetween((System.Now()).date());
        }
        return updatedOpportunity;
    }
    /**
     * @description validateStageQutoingAndQDISCSD
     *
     * @param updatedOpportunity (Opportunity): updatedOpportunity }
     * @param oldOpportunity (Opportunity): oldOpportunity }
     * @return Opportunity: Return Opportunity
     */
   
    public static Opportunity validateStageQutoingAndQDISCSD(Opportunity updatedOpportunity, Opportunity oldOpportunity){
        Opportunity updatedOpp = new Opportunity();
        updatedOpp = updatedOpportunity;
        if (QUOTING.equalsIgnoreCase(updatedOpp.stageName) && (QUOTE_DISCUSSED.equalsIgnoreCase(updatedOpp.status__c) || ''.equals(updatedOpp.status__c) || null == updatedOpp.status__c)){
            if (updatedOpp.OppQuote_Discussed_Timestamp__c == null){
            	updatedOpp.OppQuote_Discussed_Timestamp__c= System.Now();
                updatedOpp.Quote_Discussed_Date__c= System.today();
            }
        } else{
            updatedOpp = AP_OppMgmtTimeStamps.validateStageQutoingAndAppPending(updatedOpp, oldOpportunity);
        }
        return updatedOpp;
    }
}
