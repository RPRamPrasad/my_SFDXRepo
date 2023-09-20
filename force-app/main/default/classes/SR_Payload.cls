/**
 * @description SR_Payload is a apex object that will be passed in list form to the SR_Rest Apex web service
 * @Owner CATs
 */
global without sharing class SR_Payload {

    public SR_MatchParams matchParams; //Required
    public Case caseRecord; //Required if No task or log 
    public Task taskRecord; //Required if No Case or log 
    public Task logRecord; //Required if No case or task 
    public Integer numberOfTimesThroughProcess = 0; //Required //deprecated variable 
    public SR_Defaults defaults;
    public String eventId;
    
}