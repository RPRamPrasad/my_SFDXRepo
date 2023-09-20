@isTest
public with sharing class BDD_Case_StepDefinition {
	private Exception ex;
	/**
	 * @description caselist
	 */
	private List<case> caselist = new List<case>();
   /**
	* @description cases 
    */
	public Case cases { get; private set; }
	
	/**
	 * @description note
	 */
	public Case_Note__c note { get; private set; }
	/**
	 * @description notes
	 */
	public List<Case_Note__c> notes { get; private set; }
	/**
	 * @description proxyUser
	 */
	public User proxyUser { get; private set; }
	
  /***************************************************************************
   * Creates a Case in the test context  
   * @description givenANewCaseOnSalesforce
   */
    public void givenANewCaseOnSalesforce() { 
    	TestDataFactory_Case.byPassCaseBeforeTrigger();         	     
   		Account account = TestDataFactory_Account.createIndividualCustomer('TEST1');
        cases = TestDataFactory_Case.generateCase(account.Id);
    }
    
    /***************************************************************************
   * Creates a Case for an existing account in the test context  
   * @description givenANewCaseOnExistingAccount
   * @param account 
   * @param proxy 
   */
    public void givenANewCaseOnExistingAccount(Account account,User proxy) { 
    	TestDataFactory_Case.byPassCaseBeforeTrigger();         	     
   		cases = TestDataFactory_Case.generateCase(account.Id);
   		TestDataFactory_Case.createCaseShareForProxy(TestDataFactory_Case.insertCase(cases),proxy);
    }
    
    
   
   /***************************************************************************
   * Creates Agent User and Proxy User in the test context with a valid Associate Id 
   * @description givenHasAValidAgent
   * @param servicingAgentAssociateId 
   */
    public void givenHasAValidAgent(String servicingAgentAssociateId) {      	   	    		
    	createAgentProxyUsersRelatedToCase(servicingAgentAssociateId);    		   		   
    }
   
    
   /***************************************************************************
   * Creates Agent User and Proxy User in the test context with an Invalid Associate Id 
	 * @description givenACaseIsOwnedBy
	 * @param proxyUser 
	 */    
    public void givenACaseIsOwnedBy(User proxyUser) {
    	givenANewCaseOnSalesforce();
    	whenCaseIsCreatedInSalesforce();
    	User systemRecordOwner = TestDataFactory_User_Wrapper.getSystemRecordOwner();
    	System.runAs(TestDataFactory_User.getSysAdminUser()) {     		
    		cases.OwnerId = systemRecordOwner.Id;  
    		update cases; 
    		TestDataFactory_Case.createCaseShareForProxy(cases, proxyUser); 		
    	}
    }
    /**
	 * @description givenACaseIsOwnedByTheSupportQueue
	 */
    public void givenACaseIsOwnedByTheSupportQueue() {
    	givenANewCaseOnSalesforce();
    	whenCaseIsCreatedInSalesforce();
    	System.runAs(TestDataFactory_User.getSysAdminUser()) {     		
    		cases.OwnerId = queryCaseQueue(); 
    		update cases;  		
    	}    	
    }
    /**
	 * @description givenACaseIsOwnedByTheSupportQueue
	 * @param runningUser 
	 */
    public void givenACaseIsOwnedByTheSupportQueue(User runningUser) {
    	givenANewCaseOnSalesforce();
    	whenCaseIsCreatedInSalesforce();
    	System.runAs(runningUser) {     		
    		cases.OwnerId = queryCaseQueue(); 
    		update cases;  		
    	}    	
    }
    /**
	 * @description givenAnCaseNoteIsCreatedForCaseBy
	 * @param user 
	 */
    public void givenAnCaseNoteIsCreatedForCaseBy(User user) {
    	insertCaseNote(user, false);
    }
    /**
	 * @description givenACaseNoteWithSPIIsCreatedForCaseBy
	 * @param user 
	 */
    public void givenACaseNoteWithSPIIsCreatedForCaseBy(User user) {
    	TestDataFactory_CustomSetting.createSPIDataCustomSettingsForCaseNote();
    	TestDataFactory_CustomSetting.createSPISecurityControlsData();
    	insertCaseNote(user, true);
    }
   /**************************************************************************
    * Inserts the Case Note into the Saleforce database
	* @description insertCaseNote
	* @param user 
	* @param withSPI 
    */ 
    private void insertCaseNote(User user, Boolean withSPI) {
    	if (notes == null) {
    		notes = new List<Case_Note__c>();
    	}
    	String comments = 'Customer said some random quote from Ghostbusters. It was weird.';
    	if (withSPI) {
    		comments = comments + 'SSN : 234-45-7364';
    	}
    	Case_Note__c note = new Case_Note__c(
    											Name='TestNoteName',
    											Case__c = cases.Id);
		note.Comments__c = comments;
		System.runAs(user) {
           	if (Schema.SObjectType.Case_Note__c.isCreateable()) {
           		try {
               		insert note;
           		} catch (Exception e) {
           			this.ex = e;
           		}
           		this.Note = note;
				notes.add(note);
           	} else {
           		this.ex = new DMLException('User does not have Permission to create Opportunity_Note__c');
           	}                      	
        } 
    }
    /**************************************************************************
    * Inserts the Case into the Saleforce database
	* @description whenCaseIsCreatedByUser
	* @param user 
    */
    public void whenCaseIsCreatedByUser(User user) {
    	givenANewCaseOnSalesforce();
    	System.runAs(user) {
           	if (Schema.SObjectType.case.isCreateable()) {
           		try {
               		TestDataFactory_Case.insertCase(cases);
               		cases = getCaseInformation();               		
           		} catch (Exception e) {
           			this.ex = e;
           		}
           		
           	} else {
           		this.ex = new DMLException('User does not have Permission to create Case');
           	}                      	
        }      	     	
    }
    
    
   /**************************************************************************
    * Inserts the Case into the Saleforce database
	* @description whenCaseIsCreatedInSalesforce
    */
    public void whenCaseIsCreatedInSalesforce() {
     	TestDataFactory_Case.insertCase(cases);
     	cases = getCaseInformation();
    }
    
    
    /**************************************************************************
    * User changing the case owner
	* @description whenTheUserChangeTheOwnerCaseBy
	* @param user 
	* @param proxyUser 
    */
    public void whenTheUserChangeTheOwnerCaseBy(User user,User proxyUser) {	
    	try{
    		System.runAs(user){
    			cases.ownerId = proxyUser.Id; 
    			if(Schema.SObjectType.Case.isUpdateable()){
    				update cases;
    			}else {
    				this.ex = new DMLException('User does not have Permission to Update Case');
    			}
    		}
    		
    	} catch(Exception e) {
    		this.ex = e;  
    	}
    }
    
        
    /**************************************************************************
    * User quering the case
	* @description whenTheUserViewsTheCase
	* @param user 
    */
    public void whenTheUserViewsTheCase(User user) {	
    	System.runAs(user) {
    		if (Schema.SObjectType.Case.isAccessible()) {
    			cases = [SELECT ID, OwnerId FROM Case WHERE ID = :cases.ID];
    		} else {
    			cases = null;
    		}
    	}
    }
    
    
    /**************************************************************************
    * User quering the list of cases
	* @description whenTheUserTryToViewTheCase
	* @param user 
    */
    public void whenTheUserTryToViewTheCase(User user) {
    	System.runAs(user) {
    		if (Schema.SObjectType.Case.isAccessible()) {
    			caselist = [SELECT ID, OwnerId FROM Case WHERE ID = :cases.ID];    			
    		} else {
    			caselist = null;
    		}
    	}
    }
    

    /**************************************************************************
    * Edit a Case in the Saleforce database
	* @description whenTheUserEditsTheCase
	* @param user 
    */
    public void whenTheUserEditsTheCase(User user) {
    	System.runAs(user) {
    		cases = [SELECT ID, OwnerId, Subject FROM Case WHERE ID = :cases.ID];    		    		    
    		cases.Type = 'Claim';
    		if(Schema.SObjectType.Case.isUpdateable()) {
    			try{    			    			    				   		
    				update cases; 
    			} catch(Exception e) {
    				this.ex = e;  
    			} 	  			
    		} else {
    			this.ex = new DMLException('User does not have Permission to Update Case');
    		}	
    	}
    }
    
    /**************************************************************************
    * Delete the Case from the Saleforce database
	* @description whenTheUserDeleteTheCase
	* @param user 
    */
    public void whenTheUserDeleteTheCase(User user) {   	
    	System.runAs(user) {    		
    		if(Schema.SObjectType.case.isDeletable()) {    			
    			try{    			    			
    				delete cases;     			
    			} catch(Exception e) {
    				this.ex = e;  
    			} 	  			
    		} else {
    			this.ex = new DMLException('User does not have Permission to delete Case');
    		}		
    	}
    	whenTheUserTryToViewTheCase(user);
    }
    /**
	 * @description whenTheCaseIsAssignedTo_By
	 * @param assignedToUser 
	 * @param assignedByUser 
	 * @exception 
	 */
	public void whenTheCaseIsAssignedToBy(User assignedToUser, User assignedByUser) {
		System.runAs(assignedToUser) {
			if (!Schema.SObjectType.Case.isAccessible()) {
				throw new DMLException('Cannot assign case to a User that does not have read access');
			}
		}
		System.runAs(assignedByUser) {
			cases.OwnerId = assignedToUser.Id; 
			update cases;
		}
	}
	/**************************************************************************
    * Create the Case Note in the Saleforce database
	* @description whenACaseNoteIsCreatedForTheCaseBy
	* @param user 
    */
	public void whenACaseNoteIsCreatedForTheCaseBy(User user) {
    	givenAnCaseNoteIsCreatedForCaseBy(user);
    }
    /**
	 * @description whenACaseNoteWithSPIIsCreatedForTheCaseBy
	 * @param user 
	 */
    public void whenACaseNoteWithSPIIsCreatedForTheCaseBy(User user) {
    	givenACaseNoteWithSPIIsCreatedForCaseBy(user);
    }
	/**************************************************************************
    * Read the Case Note from the Saleforce database
	* @description whenTheCaseNotesAreViewedBy
	* @param user 
    */
	 public void whenTheCaseNotesAreViewedBy(User user) {
    	Set<ID> noteIds = new Set<ID>();
    	for (Case_Note__c note: Notes) {
    		noteIds.add(note.Id);
    	}
    	System.runAs(user) {
    		if (Schema.SObjectType.Case_Note__c.isAccessible()) {
    			notes = [SELECT Name, Comments__c
    					FROM Case_Note__c
    					WHERE Id IN :noteIds];  
    		} else {
    			notes = null;
    		}   		   		
    	}
    }
    /**************************************************************************
    * Edit the Case Note in the Saleforce database
	* @description whenTheCaseNotesAreEditedBy
	* @param user 
    */
    public void whenTheCaseNotesAreEditedBy(User user) {
    	note.Comments__c = 'This is an update';

    	System.runAs(user) {
           	if (Schema.SObjectType.Case_Note__c.isUpdateable()) {
           		try {
               		update note;
           		} catch (Exception e) {
           			this.ex = e;
           		}
           	} else {
           		this.ex = new DMLException('User does not have Permission to update Case_Note__c');
           	}
        } 
    }
    /**************************************************************************
    * Delete the Case Note from the Saleforce database
	* @description whenTheCaseNotesAreDeletedBy
	* @param user 
    */ 
    public void whenTheCaseNotesAreDeletedBy(User user) {
    	System.runAs(user) {
           	if (Schema.SObjectType.Case_Note__c.isDeletable()) {
           		try {
               		delete note;
           		} catch (Exception e) {
           			this.ex = e;
           		}
           	} else {
           		this.ex = new DMLException('User does not have Permission to delete Case_Note__c');
           	}
        } 
    }
    /*********************************************************************
    * Asserts that Case Owner Is Assigned To agent proxy user 
	* @description thenTheCaseOwnerIsAgentOffice
    *********************************************************************/
    public void thenTheCaseOwnerIsAgentOffice() {   	
    	System.assertEquals(proxyUser.id, cases.ownerId, 'Expected value is '+proxyUser.id+', but actual value is '+cases.ownerId);
    }
    
   /*********************************************************************
    * Asserts that Case Owner Is Assigned To agent proxy user 
	 * @description thenTheCaseOwnerIsAgentOffice
	 * @param proxyUser 
	 */
	public void thenTheCaseOwnerIsAgentOffice(User proxyUser) {   	
    	System.assertEquals(proxyUser.id, cases.ownerId, 'Expected value is '+proxyUser.id+', but actual value is '+cases.ownerId);
    }
    
     
    /*********************************************************************
    * Asserts that Case Owner Is Assigned To Case Queue in Salesforce
	* @description thenTheCaseOwnerIsCaseQueue
    *********************************************************************/
    public void thenTheCaseOwnerIsCaseQueue() {
    	Id caseQueueId = queryCaseQueue();    	
    	System.assertEquals(caseQueueId, cases.ownerId, 'Expected value is '+caseQueueId+', but actual value is '+cases.ownerId);
    }
    
    /*********************************************************************
    * Asserts that user can access the Case in Salesforce
	* @description thenTheUserCanReviewTheCase
    *********************************************************************/
    public void thenTheUserCanReviewTheCase() {
    	cases =[SELECT ID, OwnerId, Subject FROM Case WHERE ID = :cases.ID]; 
    	System.assert(cases != null, 'Case is viewable, meaning the user was able to view the case');
    }
    /**
	 * @description thenTheCaseCanBeViewedBy
	 * @param user 
	 */
    public void thenTheCaseCanBeViewedBy(User user) {
    	Case caseToView = null;
    	System.runAs(user) {
    		if (Schema.SObjectType.Case.isAccessible()) {
    			caseToView = getCaseInformation();
    		}
    	}
    	
    	System.assert(caseToView != null, 'Case is not viewable, meaning the user does not have visbility to the case');
    }
	/**
	 * @description - Asserts that user cannot access the Case in Salesforce
	 */
	public void thenTheUserCannotReviewTheCase() {
    	System.assert(CollectionUtils.isNullOrEmptyList(caselist), 'CollectionUtils is null/empty');    
    }
	/**
	 * @description - An exception is occured during the operation
	 */
	public void thenTheUserIsGivenAnError() {
    	System.assert(ex != null, 'User was given an error');
	}
    /**
	 * @description thenTheCaseNotesAreViewable
	 */   
    public void thenTheCaseNotesAreViewable() {    	
    	System.assert(notes != null && !notes.isEmpty(), 'Case Notes are not viewable to the User');
    }
    /**
	 * @description thenTheCaseNoteIsCreated
	 */
    public void thenTheCaseNoteIsCreated() {
    	System.assert(note != null, 'Case Note was not created.');
    }
    /**
	 * @description thenTheCaseNoteIsNotCreated
	 */
    public void thenTheCaseNoteIsNotCreated() {    	
    	notes = [SELECT Name, Comments__c, Id FROM Case_Note__c WHERE Id = :note.Id];     	   	   	
    	System.assert(notes.isEmpty() || notes.isEmpty(), 'Case Note was created.');
    }
    /**
	 * @description thenTheCaseNoteIsEdited
	 */
    public void thenTheCaseNoteIsEdited() {
    	System.assert(note != null, 'Case Note was not updated.');
    	System.assert(note.Comments__c == 'This is an update', 'Case Note was not updated.');
    }
    /**
	 * @description thenTheCaseNoteIsDeleted
	 */
    public void thenTheCaseNoteIsDeleted() {
    	notes = [SELECT Name, Comments__c, Id FROM Case_Note__c WHERE Id = :note.Id]; 
    	System.assert(notes == null || notes.isEmpty(), 'Case Note was not deleted.');
    }
	/**
	 * @description createAgentProxyUsersRelatedToCase - create Agent user and Proxy User on Saleforce
	 * @param servicingAgentAssociateId 
	 */
    public void createAgentProxyUsersRelatedToCase(String servicingAgentAssociateId) {      	
     	User agentUser = TestDataFactory_User_Wrapper.generateAgentUser('TEST', servicingAgentAssociateId);
    	proxyUser = TestDataFactory_User_Wrapper.generateProxyUser('TEST', servicingAgentAssociateId); 
    	
    	agentUser = TestDataFactory_User.insertUser(agentUser);
    	proxyUser = TestDataFactory_User.insertUser(proxyUser);    	
    }
    
    //Query inserted case information
    private case getCaseInformation() {
        return [SELECT ownerId FROM Case WHERE ID = :cases.ID];
    }
    
	/**
	 * @description queryCaseQueue - Query Case Queue information
	 * @return  `Id`
	 */
    public Id queryCaseQueue() {
    	return [SELECT Id, Name, Type FROM Group WHERE DeveloperName = 'Case_Owner_Queue' AND Type = 'Queue'].Id;
    }
}