/**
 * Class that is used to interact (create, update, view, ...) with cases the Operations Service Cloud (OSC) (formerly ACMT) Salesforce instance.
 * The two main methods of this class are createOSCCase() and getStatusOfAOSCCase(String oscCaseNumber). The former is used to create new cases in 
 * the OSC Salesforce instance. The latter is used to retrieve the status of specific cases from the OSC Salesforce instance.
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.1, 12/05/22
 * @see {@link https://sfgitlab.opr.statefarm.org/ACC-Salesforce/acc/-/wikis/home#_postCreateCaseRequest} 
 * @since 1.0
*/
/**
 * @description OSCCase
 */
public with sharing class OSCCase {
    // Create a new External Service instance of a OSCCaseController class to allow calling the OSC API
    private ExternalService.OSCCaseController oscCaseEs = new ExternalService.OSCCaseController();
    
    // Declare a oscCase Request variable
    private ExternalService.OSCCaseController.createCaseUsingPOST_Request oscCaseReq;
    // oscCaseReq Body variable, which contains all the createCases request body parameters
    private ExternalService.OSCCaseController_CreateCaseReqBody oscCaseReqBody;
    // List of case attachment objects
    private List<ExternalService.OSCCaseController_CreateCaseReqBody_attachments> attachments;
    /**
     * @description Custom inner class exception use to throw exceptions when an http connection to the OSC instance fails retrieving the status of a case
     */
    public class OSCCaseNotFoundException extends Exception {}
    /**
     * @description Custom inner class exception use to throw exceptions when an http connection to the OSC instance fails updating the status of a case
     */
    public class OSCUpdateCaseException extends Exception {}
    
                        
    /** 
     * @description Contains User Account Number
     */
    public String accountNumber {
        set{oscCaseReqBody.accountNumber = value;}
    }
    /**
     * @description Contains Agent code
     */
    public String agentCode {
        set{oscCaseReqBody.agentCode = value;}
    }
    /**
     * @description Contains the associate register id for Account
     */
    public String associateRegisterId {
        set{oscCaseReqBody.associateRegisterId = value;}
    }
    /**
     * @description Contains Customer name
     */
    public String customerName {
        set{oscCaseReqBody.customerName = value;}
    }
    /**
     * @description Contains the emailAddress which follows email formatting validations
     */
    public String emailAddress {
        set{oscCaseReqBody.emailAddress = value;}
    }
    /**
     * @description Contains the error description on which the request is create
     */
    public String errorDescription {
        set{oscCaseReqBody.errorDescription = value;}
    }
    /**
     * @description Contains HTML Data
     */
    public String formattedDescription {
        set{oscCaseReqBody.formattedDescription = value;}
    }
    /** 
     * @description Contains Case Comments
     */
    public String internalComment {
        set{oscCaseReqBody.internalComment = value;}
    }
    /**
     * @description Contains the source of Business information. Pick List
     */
    public String lineOfBusiness {
        set{oscCaseReqBody.lineOfBusiness = value;}
    }
    /**
     * @description Contains the date on which the request is created
     */
    public String originalRequestDate {
        set{oscCaseReqBody.originalRequestDate = value;}
    }
    /**
     * @description Contains the Policy Number. It can be empty or must be alphanumeric.
     */
    public String policyNumber {
        set{oscCaseReqBody.policyNumber = value;}
    }
    /**
     * @description Contains Product information. Pick List
     */
    public String product {
        set{oscCaseReqBody.product = value;}
    }
    /**
     * @description Contains Case Subject
    */
    public String subject {
        set{oscCaseReqBody.subject = value;}
    }
    /** 
    * @description Contains the unique transaction Id on which the request is created. Must be unique each time in the OSC database.
    */
    public String uniqueTransactionID {
        set{oscCaseReqBody.uniqueTransactionID = value;}
    }
    /**
     * @description Contains Alias of User
     */
    public String userAlias {
        set{oscCaseReqBody.userAlias = value;}
    }   
    
    /**
     *@description accountName - Fields in swagger but not in html doc
    */
    public String accountName {
        set{oscCaseReqBody.accountName = value;}
    }
    /**
     * @description contactName
     */
    public String contactName {
        set{oscCaseReqBody.contactName = value;}
    }
    /**
     * @description longPolicyNumber
     */
    public String longPolicyNumber {
        set{oscCaseReqBody.longPolicyNumber = value;}
    }
    
    
    /* oscCaseResBody body variable, which contains all the createCases response body parameters. These fields
    are available only if/when a case is successfully created in the OSC instance (createOSCCase()) */
    /**
     * @description oscCaseId
     */
    public String oscCaseId {get; private set;}
    /**
     * @description oscCaseNumber
     */
    public String oscCaseNumber {get; private set;}
    /**
     * @description oscCaseMessage
     */
    public String oscCaseMessage {get; private set;}
    /**
     * @description oscCaseComments
     */
    public String oscCaseComments {get; private set;}
    /**
     * @description oscCaseAttachment
     */
    public String oscCaseAttachment {get; private set;}
    
    /**
     * @description OSCCaseWrapper
     * the name of the application or SF group that attempting to create the case in the OSC instance (e.g. ECRM)
     * the OSC case description
     * the OSC case topic, which is of Picklist type. Some valid values are: ECRM, Premium Change, Licensing, Payments, ...
     * the OSC case type, which is of Picklist type. Some valid values are: Billing, PCU, ASR, HR, ...
     */
    public class OSCCaseWrapper{
        public String appName; 
        public String description; 
        public String topic; 
        public String type;
    }

    /**
     * @description Main Constructor - Creates an OSCCase object with the minimun required parametes used to create a case in the
     * OSC instance. To create the case in the OSC instance, include other parameters (such as accountName or agentCode) 
     * if needed and call the createOSCCase() instance method.
     * 
     * @param oscWrap
     * @see #createOSCCase()
     */ 
    public OSCCase(OSCCaseWrapper oscWrap) {
        oscCaseReq = new ExternalService.OSCCaseController.createCaseUsingPOST_Request();
        oscCaseReq.applicationName = oscWrap.appName;
        
        oscCaseReqBody = new ExternalService.OSCCaseController_CreateCaseReqBody();
        oscCaseReqBody.description = oscWrap.description;   // Contains Case description
        oscCaseReqBody.topic = oscWrap.topic;               // Describe the topic of the Case
        oscCaseReqBody.z0type = oscWrap.type;               // Describe the type of Case                    
    }
    
    /**
     * @description Adds a new attachment file to the OSCCase object. To create the case in the OSC instance, include other parameters 
     * (such as accountName or agentCode) if needed and call the createOSCCase() instance method.
     * 
     * @param fileAttachment the url of the attached file added to the OSC case
     * @param fileExtension the extension of the attached file added to the OSC case
     * @param fileName the name of the attached file added to the OSC case
     * @see #createOSCCase()
    */
    public void addCaseAttachment(String fileAttachment, String fileExtension, String fileName) {
        ExternalService.OSCCaseController_CreateCaseReqBody_attachments attachment = new ExternalService.OSCCaseController_CreateCaseReqBody_attachments();
        attachment.fileAttachment = fileAttachment;
        attachment.fileExtension = fileExtension;
        attachment.fileName = fileName;
        if (attachments == null) {
            attachments = new List<ExternalService.OSCCaseController_CreateCaseReqBody_attachments>();
            attachments.add(attachment);
        } else {
            attachments.add(attachment);
        }
        oscCaseReqBody.attachments = attachments;
    }
    
    /**
     * @description Creates a new case in the OSC instance with the required parameters (appName, description, topic, and type), and other 
     * optional parameters such as accountName, agentCode, lineOfBusiness, emailAddress, ...
     * 
     * @return {@code true} if the case was successfully created in the OSC instance, {@code false} otherwise
    */
    public Boolean createOSCCase() {
        oscCaseReq.createCaseRequest = oscCaseReqBody;
        try {
            ExternalService.OSCCaseController.createCaseUsingPOST_Response oscCaseRes = oscCaseEs.createCaseUsingPOST(oscCaseReq);
            ExternalService.OSCCaseController_CreateCaseResBody oscCaseResBody = oscCaseRes.Code201;
            oscCaseId = oscCaseResBody.id;
            oscCaseNumber = oscCaseResBody.caseNumber;
            oscCaseMessage = oscCaseResBody.message;
            oscCaseComments = oscCaseResBody.comments;
            oscCaseAttachment = oscCaseResBody.attachment;
            return true;
        } catch (ExternalService.OSCCaseController.createCaseUsingPOST_ResponseException exc) {
            return false;
        } 
    }
    

    /** 
     * @description Static method used to get the latest status of an OSC case.
     * 
     * @param oscCaseNumber the OSC case identification number
     * @return the case status in the OSC instance
     * @throws OSCCase.OSCCaseNotFoundException If the case number provided (oscCaseNumber) or ID does not exist in the OSC instance
	*/
    public static String getStatusOfOSCCase(String oscCaseNumber) {
        ExternalService.OSCCaseController oscCaseStat = new ExternalService.OSCCaseController();
        ExternalService.OSCCaseController.getCaseStatusUsingGET_Request oscCaseStatReq = new ExternalService.OSCCaseController.getCaseStatusUsingGET_Request();
        oscCaseStatReq.caseNumber = oscCaseNumber;
        ExternalService.OSCCaseController.getCaseStatusUsingGET_Response oscCaseStatRes = oscCaseStat.getCaseStatusUsingGET(oscCaseStatReq);
        ExternalService.OSCCaseController_CaseStatusResBody oscCaseStatResBody = oscCaseStatRes.Code200;

        if (oscCaseStatResBody.errorCode == '404') {
            throw new OSCCaseNotFoundException('Error: ' + oscCaseStatResBody.errorCode + ' -> ' + oscCaseStatResBody.message);
        }
        
        return oscCaseStatResBody.status;
    }
     /** 
     * @description Static method used to update the status of an OSC case.
     * 
     * @param oscCaseNumber the OSC case identification number
     * @param internalComment the OSC case internal comment
     * @param topic the OSC case topic
     * @return Boolean - true if the OSC case was successfully updated; false othewise
	*/
    public static Boolean updateStatusOfOSCCase(String oscCaseNumber, String internalComment, String topic) {
        Boolean caseUpdated = false;
        ExternalService.OSCCaseController oscCaseStat = new ExternalService.OSCCaseController();
        ExternalService.OSCCaseController.updateCaseUsingPOST_Request oscUpdCaseStatReq = new ExternalService.OSCCaseController.updateCaseUsingPOST_Request();
        oscUpdCaseStatReq.caseNumber = oscCaseNumber;
        ExternalService.OSCCaseController_UpdateCaseReqBody oscUpdCaseStatReqBody = new ExternalService.OSCCaseController_UpdateCaseReqBody();
        
        if (internalComment != null) {
            oscUpdCaseStatReqBody.internalComment = internalComment;
        }
        if (topic != null) {
            oscUpdCaseStatReqBody.topic = topic;
        }
        oscUpdCaseStatReq.updateCase = oscUpdCaseStatReqBody;
        try {
            oscCaseStat.updateCaseUsingPOST(oscUpdCaseStatReq);
            caseUpdated = true;
        } catch(ExternalService.OSCCaseController.updateCaseUsingPOST_ResponseException exc) {
            return false;
        }
        
        return caseUpdated;
    }
}