/**
 * Provides a common exception class that can be used to
 * pass transaction processing failures back to the 
 * LeadVendorMessageService stage processor.
 */
/**
 * @description HLPR_LeadVendorMessageServiceException
 */
public class HLPR_LeadVendorMessageServiceException extends Exception{
    // all of the methods that we need are already defined in
    // the base Exception class. This is just a marker
    // class that identifies transaction processor failures.
}