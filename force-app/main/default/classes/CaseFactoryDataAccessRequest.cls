/** 
* @description case factory used to build data access request cases 
* @Owner: Grumpycats
*/
public with sharing class CaseFactoryDataAccessRequest extends CaseFactory {
	/**
	 * @description buildCase
	 * @param accountRecord 
	 * @return  `Case`
	 */
	public Case buildCase(SObject accountRecord){
		Case dataAccessRequest = new Case();
		dataAccessRequest.Subject = ('Data Access Request - ' + accountRecord.get('Name'));
		dataAccessRequest.Description = 'Data Access Request';
		dataAccessRequest.ContactId = String.valueOf(accountRecord.get('PersonContactId'));
		dataAccessRequest.AccountId = String.valueOf(accountRecord.get('Id'));
		dataAccessRequest.OwnerId = CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID;
		dataAccessRequest.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST;
		return dataAccessRequest;
    }
}