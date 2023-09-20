@isTest
public class TestDataFactory_Contact {
    /**
     * @description insertContact
     * @param contact 
     * @return  `Contact`
     */
    public static Contact insertContact(Contact contact){
    	insert contact;
    	return contact;
    }
    /**
     * @description generateContact
     * @param firstName 
     * @param lastName 
     * @return  `Contact`
     */
    public static Contact generateContact(String firstName, String lastName){
    	return new Contact(Firstname = firstName, Lastname=lastName);
    }
    /**
     * @description byPassTriggers
     */
    public static void byPassTriggers(){
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = new CS001_ByPassTriggerAtoF__c();
 		objectBasedByPassTrigger.Override_ContactAfterUpdate__c = true;
        insert objectBasedByPassTrigger;
    
    }
}