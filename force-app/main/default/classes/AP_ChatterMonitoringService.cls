/**
 * @Name AP_ChatterMonitoringService
 * @Author ITIC
 * @description Class to callOut the Chatter Monitoring Web Service
 *
 * */
public with sharing class AP_ChatterMonitoringService {
    private static final String CLASS_NAME = 'AP_ChatterMonitoringService';
    private static final String BATCH_FINISH_METHOD = 'execute';
    private static final Integer STATUS_CODE = 200;

   /**
   * @description This method checks and validates the response code received from callout
   * @Name:  checkResponse
   * @param res response
   */
    private void checkResponse(HttpResponse res){
        AP_LogHolder logHolder = new AP_LogHolder();
        if (res.getStatusCode() != STATUS_CODE) {
            logHolder.error(CLASS_NAME,(System.label.CL_ERROR_IN_SERVICE + res.toString() + AP_UserProvisioningConstants.HYPHEN +AP_UserProvisioningConstants.SEND));
            logHolder.writeToLogExceptionObject();
        }
    }

   /**
   * @description This method makes the actual callout to the web service
   * @Name:  getResponseFromService
   * @param batchId
   */
    public void getResponseFromService(String batchId){
    	HttpRequest req = TechnicalPlatformDetails.buildHttpRequestForTP();
    	req.setEndpoint(AP_UserProvisioningConstants.CALL_OUT + AP_UserProvisioningConstants.FWD_SLASH + batchId);
        req.setMethod(TechnicalPlatformDetails.GET);
        Http h = new Http();
        HttpResponse res;
        try{
            res = h.send(req);
        }catch(Exception e){ LoggingService.logHandledException(e, CLASS_NAME, BATCH_FINISH_METHOD, System.LoggingLevel.ERROR);}
        checkResponse(res);
    }
}