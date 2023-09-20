/**
 * @description A custom exception class used in the SR Rest Service
 * @Owner CATs
 */
public without sharing class SR_Exception extends Exception {

    public static final String EXCEPTION_MESSAGE_NO_VALID_PAYLOADS = 'All Service Requests are Invalid';
    public static final String EXCEPTION_MESSAGE_DML_ERROR = 'A DML Exception was thrown: ';
    public static final String EXCEPTION_MESSAGE_NO_SOBJECTS = 'None of the Servie Requests resulted in having valid SObjects';
    public static final String EXCEPTION_MESSAGE_NO_ACCOUNTS_FOUND = 'There were no Account found with the provided Client Ids';
    public static final String EXCEPTION_MESSAGE_INVALID_CASE_RECORD_TYPE = 'Invalid Case Record Type';
    public static final String EXCEPTION_MESSAGE_EMPTY_PAYLOAD_LIST = 'Payloads cannot be Null or Empty';
    public List<Object> errorPayloads;
    
    /**
    * @description Used to set the error message when an exception is thrown and which object caused the exception.
    * @param message 
    * @param errorPayloads 
    */
    public SR_Exception(String message, List<Object> errorPayloads){
        this(message);
        this.errorPayloads = errorPayloads;
    }
    
}