/**
* @author GrumpyCats
* @name ABS_ActivityManagementCallout
* @date Created 02/20/2020
* @description This class managens external services callout to ABS Activity/Task Management.
*/
public with sharing class ABS_ActivityManagementCallout {

    private static final String CLASS_NAME='ABS_ActivityManagementCallout';
    private static final String METHOD_NAME='callActivityMoveService';
    private static final String ACTIVITY_MOVE_NAMED_CREDENTIAL = 'callout:ActivityMoveCallout';
    private static final String POST = 'POST';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String XML_TYPE = 'application/xml';

	/**
     * @name callActivityMoveService
     * @description call Activity Move service
     * @param requestBody
     */
    public static Map<String, String> callActivityMoveService(String requestBody){
        Map<String, String> responseMap = new Map<String, String>();
        
        try {
                // Activity Move Requeset 
                HttpRequest request = new HttpRequest();
                request.setEndpoint(ACTIVITY_MOVE_NAMED_CREDENTIAL);
                request.setMethod(POST);
                request.setHeader(CONTENT_TYPE, XML_TYPE);
                request.setBody(requestBody);

                // Activity Move Response 
                Http http = new Http();
                HttpResponse response =  http.send(request);
            
            	responseMap.put('status', String.valueOf(response.getStatusCode()));
            	responseMap.put('responseBody', response.getBody());

                if(response.getStatusCode() != 200) { 
                    LoggingService.logHandledException(new callOutException(ACTIVITY_MOVE_NAMED_CREDENTIAL + ': Status: ' + response.getStatusCode()
                                                                            + ' Response:' + response.getBody()),CLASS_NAME, METHOD_NAME , LoggingLevel.WARN);
                }
        
            } catch(Exception ex) { 
                responseMap.put('responseBody', ex.getMessage());
                ex.setMessage(ex.getMessage());
                LoggingService.logHandledException(ex, CLASS_NAME, METHOD_NAME , LoggingLevel.ERROR);   
            }
			
        return responseMap;
    }
}
