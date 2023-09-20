@isTest
public class BDD_Opportunity_StepDefinitions {
    
	private Exception ex;
	/**
	 * @description bddOpportunity
	 */
    public Opportunity bddOpportunity { get; private set; }
	/**
	 * @description notes
	 */
    public List<Opportunity_Note__c> notes { get; private set; }
	/**
	 * @description opportunityNote
	 */
    public Opportunity_Note__c opportunityNote { get; private set; }
    private Account account { get; private set; }
    
	/**
	 * @description givenAnOpportunityForOwner
	 * @param user 
	 */
    public void givenAnOpportunityForOwner(User user) {
    	 account = TestDataFactory_Account.createIndividualCustomer('TestAccountName');

		System.runAs(TestDataFactory_User.getSysAdminUser()){
    		TestDataFactory_Account.byPassAccountBeforeTrigger();
    		TestDataFactory_Account.insertAccount(account);
    	}
    	    	
    	bddOpportunity = TestDataFactory_Opportunity.generateOpportunity('TestOpportunity');
    	bddOpportunity.AccountId = account.Id;
    	bddOpportunity.OwnerId = user.Id;
    	
    	System.runAs(TestDataFactory_User.getSysAdminUser()){
    		TestDataFactory_Opportunity.insertOpportunity(bddOpportunity);
    	}    	
    }
    
	/**
	 * @description givenAnOpportunityNoteIsCreatedForOpportunityBy
	 * @param user 
	 */
    public void givenAnOpportunityNoteIsCreatedForOpportunityBy(User user) {
    	insertOpportunity(user, false);
    }
    
	/**
	 * @description givenAnOpportunityNoteWithSPIIsCreatedForOpportunityBy
	 * @param user 
	 */
    public void givenAnOpportunityNoteWithSPIIsCreatedForOpportunityBy(User user) {
    	insertOpportunity(user, true);
    }
    
	/**
	 * @description givenAnOpportunityWithPhoneNumbers
	 * @param user 
	 * @param personMobilePhone 
	 * @param personHomePhone 
	 * @param phone 
	 * @param submittedPhone 
	 * @param isDoNotCallEnabled 
	 */
    public void givenAnOpportunityWithPhoneNumbers(User user, String personMobilePhone, String personHomePhone, String phone, String submittedPhone, Boolean isDoNotCallEnabled) {
    	givenAnOpportunityForOwner(user);
    	account.PersonMobilePhone = personMobilePhone;
    	account.PersonHomePhone = personHomePhone;
    	account.Phone = phone;
    	account.PersonDoNotCall = isDoNotCallEnabled;
		account.Edit_In_VFP__c = true;
    	update account;
    	
    	bddOpportunity.Phone__c = submittedPhone;
    	update bddOpportunity;
    }
    
	/**
	 * @description givenAnOpportunityWithPhoneNumberAndDate
	 * @param user 
	 * @param personMobilePhone 
	 * @param personHomePhone 
	 * @param phone 
	 * @param submittedPhone 
	 * @param isDoNotCallEnabled 
	 * @param daysBeforeToday 
	 */
    public void givenAnOpportunityWithPhoneNumberAndDate(User user, String personMobilePhone, String personHomePhone, String phone, String submittedPhone, Boolean isDoNotCallEnabled, Integer daysBeforeToday) {
    	givenAnOpportunityWithPhoneNumbers(user, personMobilePhone, personHomePhone, phone, submittedPhone, isDoNotCallEnabled);
    	Test.setCreatedDate(bddOpportunity.Id, system.today() - daysBeforeToday);
      	System.runAs(TestDataFactory_User.getSysAdminUser()){
        	update bddOpportunity;
      	} 
    }
    
    private void insertOpportunity(User user, Boolean withSPI) {
    	if (notes == null) {
    		notes = new List<Opportunity_Note__c>();
    	}
    	String comments = 'Customer said some random quote from Ghostbusters. It was weird.';
    	if (withSPI) {
    		comments = comments + 'SSN : 234-45-7364';
    	}
    	Opportunity_Note__c note = new Opportunity_Note__c(
    											Name='TestNoteName',
    											Opportunity__c=bddOpportunity.Id);
		note.Comments__c = comments;
		System.runAs(user) {
           	if (Schema.SObjectType.Opportunity_Note__c.isCreateable()) {
           		try {
               		insert note;
           		} catch (Exception e) {
           			this.ex = e;
           		}
           		this.opportunityNote = note;
				notes.add(note);
           	} else {
           		this.ex = new DMLException('User does not have Permission to create Opportunity_Note__c');
           	}                      	
        } 
    }
    
	/**
	 * @description whenAnOpportunityNoteIsCreatedForTheOpportunityBy
	 * @param user 
	 */
    public void whenAnOpportunityNoteIsCreatedForTheOpportunityBy(User user) {
    	givenAnOpportunityNoteIsCreatedForOpportunityBy(user);
    }
    
	/**
	 * @description whenAnOpportunityNoteWithSPIIsCreatedForTheOpportunityBy
	 * @param user 
	 */
    public void whenAnOpportunityNoteWithSPIIsCreatedForTheOpportunityBy(User user) {
    	givenAnOpportunityNoteWithSPIIsCreatedForOpportunityBy(user);
    }
    
	/**
	 * @description whenTheOpportunityNotesAreViewedBy
	 * @param user 
	 */
    public void whenTheOpportunityNotesAreViewedBy(User user) {
    	Set<ID> noteIds = new Set<ID>();
    	for (Opportunity_Note__c note: notes) {
    		noteIds.add(note.Id);
    	}
    	System.runAs(user) {
    		if (Schema.SObjectType.Opportunity_Note__c.isAccessible()) {
    			notes = [SELECT Name, Comments__c
    					FROM Opportunity_Note__c
    					WHERE Id IN :noteIds];  
    		} else {
    			notes = null;
    		}   		   		
    	}    	
    }
    
	/**
	 * @description whenTheOpportunityNotesAreEditedBy
	 * @param user 
	 */
    public void whenTheOpportunityNotesAreEditedBy(User user) {
    	opportunityNote.Comments__c = 'This is an update';

    	System.runAs(user) {
           	if (Schema.SObjectType.Opportunity_Note__c.isUpdateable()) {
           		try {
               		update opportunityNote;
           		} catch (Exception e) {
           			this.ex = e;
           		}
           	} else {
           		this.ex = new DMLException('User does not have Permission to update Opportunity_Note__c');
           	}
        } 
    }
    
	/**
	 * @description whenTheOpportunityNotesAreDeletedBy
	 * @param user 
	 */
    public void whenTheOpportunityNotesAreDeletedBy(User user) {
    	System.runAs(user) {
           	if (Schema.SObjectType.Opportunity_Note__c.isDeletable()) {
           		try {
               		delete opportunityNote;
           		} catch (Exception e) {
           			this.ex = e;
           		}
           	} else {
           		this.ex = new DMLException('User does not have Permission to delete Opportunity_Note__c');
           	}
        } 
    }
    
	/**
	 * @description whenTheOpportunityAreDeletedBy
	 * @param user 
	 */
     public void whenTheOpportunityAreDeletedBy(User user) {
    	System.runAs(user) {
           	if (Schema.SObjectType.Opportunity.isDeletable()) {
           		try {
               		delete bddOpportunity;
           		} catch (Exception e) {
           			this.ex = e;
           		}
           	} else {
           		this.ex = new DMLException('User does not have Permission to delete Opportunity');
           	}
        } 
    }
    
	/**
	 * @description thenTheOpportunityNotesAreViewable
	 */
    public void thenTheOpportunityNotesAreViewable() {
    	System.assert(notes != null && notes.size() > 0, 'Opportunity Notes are not viewable to the User');
    }
    
	/**
	 * @description thenTheOpportunityNoteIsNotCreated
	 */
    public void thenTheOpportunityNoteIsNotCreated() {    	
    	notes = [SELECT Name, Comments__c, Id FROM Opportunity_Note__c WHERE Id = :opportunityNote.Id];     	   	   	
    	System.assert(notes.isEmpty() || notes.size() == 0, 'Opportunity was created.');
    }
    
	/**
	 * @description thenTheOpportunityNoteIsEdited
	 */
    public void thenTheOpportunityNoteIsEdited() {
    	System.assert(opportunityNote != null, 'Opportunity was not updated.');
    	System.assert(opportunityNote.Comments__c == 'This is an update', 'Opportunity was not updated.');
    }
    
	/**
	 * @description thenTheOpportunityNoteIsDeleted
	 */
    public void thenTheOpportunityNoteIsDeleted() {
    	notes = [SELECT Name, Comments__c, Id FROM Opportunity_Note__c WHERE Id = :opportunityNote.Id]; 
    	System.assert(notes == null || notes.isEmpty(), 'Opportunity was not deleted.');
    }
    
	/**
	 * @description thenTheOpportunityIsDeleted
	 */
    public void thenTheOpportunityIsDeleted() {
    	List<Opportunity> opportunity = [SELECT Id FROM Opportunity WHERE Id = :bddOpportunity.Id]; 
    	System.assert(opportunity == null || opportunity.isEmpty(), 'Opportunity was not deleted.');
    }
    
    /**
	 * @description thenTheOpportunityNoteIsCreated
	 */
    public void thenTheOpportunityNoteIsCreated() {
    	System.assert(opportunityNote != null, 'Opportunity was not created.');
    }
    
	/**
	 * @description thenTheUserIsGivenAnError
	 */
    public void thenTheUserIsGivenAnError() {
    	System.assert(ex != null, 'User was not given an error');
    }

    /**
	 * @description thenTheUserisNotAbleToViewTheNotes
	 */
    public void thenTheUserisNotAbleToViewTheNotes() {
    	System.assert(notes == null || notes.size() == 0, 'Opportunity Notes are viewable to the User');
    }
}