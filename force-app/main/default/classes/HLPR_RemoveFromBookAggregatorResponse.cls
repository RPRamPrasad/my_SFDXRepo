/**
* @author : Team Loco Motivated / Targaryen
* @name : HLPR_RemoveFromBookAggregatorResponse
* @description : This is Helper class to get response for Remove From Book aggregator response 
* @Date : 07/05/2018
**/

public with sharing class HLPR_RemoveFromBookAggregatorResponse {
    
    //Populate Successfull Remove From Book values received from customer aggregator response
    /**
     * @description Get Remove From Book From Aggregator Failed Response
     * @param dataListValues
     * @return List<String>
     */
    public static List<String> getRemoveFromBookFromAggregatorFailedResponse(List<AP_RemoveFromBookAggregatorResponse.RemoveFromBookData> dataListValues) {
        List<String> removeFromBookSuccessList=new List<String>();
        List<String> removeFromBookUnSuccessList=new List<String>();
        String rfbClientIdentifier;
        String rfbAssociateId;
        if(dataListValues.isEmpty()){
            throw new CustomerAggregatorException('Aggregator Response is empty');
        }
        for(AP_RemoveFromBookAggregatorResponse.RemoveFromBookData jsonRemoveFromBookValue : dataListValues){
            List<AP_RemoveFromBookAggregatorResponse.RemoveFromBookErrors> errorTracker = new List<AP_RemoveFromBookAggregatorResponse.RemoveFromBookErrors>();
            errorTracker=jsonRemoveFromBookValue.errors;
            rfbClientIdentifier=jsonRemoveFromBookValue.clientIdentifier;
            rfbAssociateId=jsonRemoveFromBookValue.associateId;
            if(errorTracker.isEmpty()){
                removeFromBookSuccessList.add(rfbClientIdentifier+'-'+rfbAssociateId); 
            }else{
                removeFromBookUnSuccessList.add(rfbClientIdentifier+'-'+rfbAssociateId+'-'+errorTracker);
            }
        }
        return removeFromBookUnSuccessList;
    }
    
    /**
     * @description Get Remove From Book From Aggregator Successful Response
     * @param dataListValues
     * @return List<String>
     */
    public static List<String> getRemoveFromBookFromAggregatorSuccessfulResponse(List<AP_RemoveFromBookAggregatorResponse.RemoveFromBookData> dataListValues) {
        List<String> removeFromBookSuccessList=new List<String>();
        List<String> removeFromBookUnSuccessList=new List<String>();
        String rfbClientIdentifier;
        String rfbAssociateId;
        if(dataListValues.isEmpty()){
            throw new CustomerAggregatorException('Aggregator Response is empty');
        }
        for(AP_RemoveFromBookAggregatorResponse.RemoveFromBookData jsonRemoveFromBookValue : dataListValues){
            List<AP_RemoveFromBookAggregatorResponse.RemoveFromBookErrors> errorTracker = new List<AP_RemoveFromBookAggregatorResponse.RemoveFromBookErrors>();
            errorTracker=jsonRemoveFromBookValue.errors;
            rfbClientIdentifier=jsonRemoveFromBookValue.clientIdentifier;
            rfbAssociateId=jsonRemoveFromBookValue.associateId;
            if(errorTracker.isEmpty()){
                removeFromBookSuccessList.add(rfbClientIdentifier+'-'+rfbAssociateId); 
            }else{
                removeFromBookUnSuccessList.add(rfbClientIdentifier+'-'+rfbAssociateId+'-'+errorTracker);
            }
        }
        return removeFromBookSuccessList;
    }
}