/*****
 * Utility class for mocking Journey WebService calls
 * **/
@isTest
/**
 * @description TestDataFactory_Journey
 * @author 
 * @since 
 */
public with sharing class UTIL_MockJourneyMail {
    private static final String RESPONSE_X = 'response_x';

    /**
     * @description MockMailTrue
     */
    public class MockMailTrue implements WebServiceMock {
        /**
    	* @description doInvoke used to call the WebServiceMock with the given parameters
		* @param stub
		* @param request
		* @param response
		* @param endpoint
		* @param soapAction
		* @param requestName
		* @param responseNS
		* @param responseName
		* @param responseType
    	*/
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof  MarketingMailManagement.DoNotSolicitMailRequest_element) {
                MarketingMailManagement.DoNotSolicitMailResponse_element marketingMailresponse = new MarketingMailManagement.DoNotSolicitMailResponse_element();
                marketingMailresponse.doNotSolicitIndicator = true;
                response.put(RESPONSE_X,marketingMailresponse );
            }
        }
    }
    
    /**
     * @description MockMailFalse
     */
    public class MockMailFalse implements WebServiceMock {
        /**
    	* @description doInvoke used to call the WebServiceMock with the given parameters
		* @param stub
		* @param request
		* @param response
		* @param endpoint
		* @param soapAction
		* @param requestName
		* @param responseNS
		* @param responseName
		* @param responseType
    	*/
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof  MarketingMailManagement.DoNotSolicitMailRequest_element) {
                MarketingMailManagement.DoNotSolicitMailResponse_element marketingMailresponse = new MarketingMailManagement.DoNotSolicitMailResponse_element();
                marketingMailresponse.doNotSolicitIndicator = false;
                response.put(RESPONSE_X,marketingMailresponse );
            }
        }
    }

    /**
     * @description MockEmailBothTrue
     */
    public class MockEmailBothTrue implements WebServiceMock {
        /**
    	* @description doInvoke used to call the WebServiceMock with the given parameters
		* @param stub
		* @param request
		* @param response
		* @param endpoint
		* @param soapAction
		* @param requestName
		* @param responseNS
		* @param responseName
		* @param responseType
    	*/
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof  MarketingMailManagement.DoNotSolicitEmailRequest_element) {
                MarketingMailManagement.DoNotSolicitEmailResponse_element marketingEmailresponse = new MarketingMailManagement.DoNotSolicitEmailResponse_element();
                marketingEmailresponse.doNotSolicitServiceIndicator = true;
                marketingEmailresponse.doNotSolicitMarketingIndicator = true;
                response.put(RESPONSE_X,marketingEmailresponse );
            }
        }
    }
    
    /**
     * @description MockEmailBothFalse
     */
    public class MockEmailBothFalse implements WebServiceMock {
        /**
    	* @description doInvoke used to call the WebServiceMock with the given parameters
		* @param stub
		* @param request
		* @param response
		* @param endpoint
		* @param soapAction
		* @param requestName
		* @param responseNS
		* @param responseName
		* @param responseType
    	*/
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof  MarketingMailManagement.DoNotSolicitEmailRequest_element) {
                MarketingMailManagement.DoNotSolicitEmailResponse_element marketingEmailresponse = new MarketingMailManagement.DoNotSolicitEmailResponse_element();
                marketingEmailresponse.doNotSolicitServiceIndicator = false;
                marketingEmailresponse.doNotSolicitMarketingIndicator = false;
                response.put(RESPONSE_X,marketingEmailresponse );
            }
        }
    }
    
    /**
     * @description MockEmailServiceTrueMarketingFalse
     */
    public class MockEmailServiceTrueMarketingFalse implements WebServiceMock {
        /**
    	* @description doInvoke used to call the WebServiceMock with the given parameters
		* @param stub
		* @param request
		* @param response
		* @param endpoint
		* @param soapAction
		* @param requestName
		* @param responseNS
		* @param responseName
		* @param responseType
    	*/
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof  MarketingMailManagement.DoNotSolicitEmailRequest_element) {
                MarketingMailManagement.DoNotSolicitEmailResponse_element marketingEmailresponse = new MarketingMailManagement.DoNotSolicitEmailResponse_element();
                marketingEmailresponse.doNotSolicitServiceIndicator = true;
                marketingEmailresponse.doNotSolicitMarketingIndicator = false;
                response.put(RESPONSE_X,marketingEmailresponse );
            }
        }
    }
    
    /**
     * @description MockEmailServiceFalseMarketingTrue
     */
    public class MockEmailServiceFalseMarketingTrue implements WebServiceMock {
        /**
    	* @description doInvoke used to call the WebServiceMock with the given parameters
		* @param stub
		* @param request
		* @param response
		* @param endpoint
		* @param soapAction
		* @param requestName
		* @param responseNS
		* @param responseName
		* @param responseType
    	*/
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof  MarketingMailManagement.DoNotSolicitEmailRequest_element) {
                MarketingMailManagement.DoNotSolicitEmailResponse_element marketingEmailresponse = new MarketingMailManagement.DoNotSolicitEmailResponse_element();
                marketingEmailresponse.doNotSolicitServiceIndicator = false;
                marketingEmailresponse.doNotSolicitMarketingIndicator = true;
                response.put(RESPONSE_X,marketingEmailresponse );
            }
        }
    }
    
    /**
     * @description MockMailThrowsError
     */
    public class MockMailThrowsError implements WebServiceMock {
        /**
    	* @description doInvoke used to call the WebServiceMock with the given parameters
		* @param stub
		* @param request
		* @param response
		* @param endpoint
		* @param soapAction
		* @param requestName
		* @param responseNS
		* @param responseName
		* @param responseType
    	*/
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof  MarketingMailManagement.DoNotSolicitMailRequest_element) {
                throw new CalloutException();
            }
        }
    }
    
    /**
     * @description MockEmailThrowsError
     */
    public class MockEmailThrowsError implements WebServiceMock {
        /**
    	* @description doInvoke used to call the WebServiceMock with the given parameters
		* @param stub
		* @param request
		* @param response
		* @param endpoint
		* @param soapAction
		* @param requestName
		* @param responseNS
		* @param responseName
		* @param responseType
    	*/
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof  MarketingMailManagement.DoNotSolicitEmailRequest_element) {
                throw new CalloutException();
            }
        }
    }  
}
