/**
* @author : Team Loco Motivated / Targaryen
* @name : AP_RemoveFromBookAggregatorResponse
* @description This is JSON object for Remove From Book aggregator response 
* @Date : 07/05/2018
**/

public with sharing class AP_RemoveFromBookAggregatorResponse {
    public List<RemoveFromBookData> data;
    public List<RemoveFromBookErrors> errors;
    
    /**
     * @description Get Data List
     * @return List<RemoveFromBookData>
     */
    public List<RemoveFromBookData> getDataList(){
        return data;
    }
    
    /**
     * @description Get Error List
     * @return List<RemoveFromBookErrors>
     */
    public List<RemoveFromBookErrors> getErrorList(){
        return errors;
    }
    
    /**
     * @description Remove From Book Data
     */
    public with sharing class RemoveFromBookData {
        // public RemoveFromBookDataAttributes attributes;
        public String clientIdentifier;  
        public String associateId;
        public List<RemoveFromBookErrors> errors;
    }
    
    /**
     * @description Remove From Book Errors
     */
    public with sharing class RemoveFromBookErrors {
        public String code; 
        public String title;    
        public String detail;   
    }
    
    /**
     * @description This method parses given JSON String
     * @param json
     * @return AP_RemoveFromBookAggregatorResponse
     */
    public static AP_RemoveFromBookAggregatorResponse parse(String json){
        return (AP_RemoveFromBookAggregatorResponse) System.JSON.deserialize(json, AP_RemoveFromBookAggregatorResponse.class);
    }
}