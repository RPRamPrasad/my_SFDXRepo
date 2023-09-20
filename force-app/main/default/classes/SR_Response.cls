/**
 * @description Response Handler for SR_Rest flow
 * @Owner CATs
 */
public without sharing class SR_Response {
    
    @TestVisible private Blob responseBody;
    @TestVisible private Integer statusCode;
    /**
     * @description SR_Response
     * @param statusCode 
     * @param responseBody 
     */
    public SR_Response(Integer statusCode, String responseBody){
        this.statusCode = statusCode;
        this.responseBody = Blob.valueOf(responseBody);  
    }
    /**
     * @description handleResponse
     * @return  `RestResponse`
     */
    public RestResponse handleResponse(){
        RestResponse res = RestContext.response;
        if (res != null) {
         	res.statusCode = this.statusCode;
        	res.responseBody = this.responseBody; 
        }
        return res;
    }

}