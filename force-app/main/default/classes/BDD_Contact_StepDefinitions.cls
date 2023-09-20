@isTest
public class BDD_Contact_StepDefinitions {
    
	/**
	 * @description Contact
	 * @return Contact
	 */
    public Contact contact { get; private set; }
    
	/**
	 * @description Given Contact
	 * @param firstName
	 * @param lastName
	 */
    public void givenAContact(String firstName, String lastName){
		
		contact = TestDataFactory_Contact.generateContact(firstName,lastName);
		contact = TestDataFactory_Contact.insertContact(contact);
	}

	/**
	 * @description Given The Contact Has PhoneNumber
	 * @param phoneType
	 * @param phoneNumber
	 */
	public void givenTheContactHasPhoneNumber(String phoneType, String phoneNumber){
		system.runAs(TestDataFactory_User.getSysAdminUser()){
			if(phoneType.equals('MobilePhone')){
				contact.MobilePhone = phoneNumber;
			}else if(phoneType.equals('Phone')){
				contact.Phone = phoneNumber;
			}
			update contact;
		}
	}
    
}