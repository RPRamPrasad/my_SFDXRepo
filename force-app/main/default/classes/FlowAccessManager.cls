/**
* @Name: FlowAccessManager
* @Created: 11/05/2019
* @Author: Grumpycats
* @description : Used to determine current user's access to objects used in a flow
*/

public without sharing class FlowAccessManager {
    private static final String TRUE_VALUE = 'true';
    private static final String FALSE_VALUE = 'false';
    /**
     * @description FlowInputs
     */
     public without sharing class FlowInputs{
        @InvocableVariable
        public List<String> objectNameList;
	
        @InvocableVariable
        public boolean checkRecordTypeAccess;

    }
    /**
     * @description FlowOutputs
     */
    public without sharing class FlowOutputs{
        @InvocableVariable
        public List<String> objectNameAndAccess;
        
        @InvocableVariable
        public List<String> recordTypeAccess;
    }
    /**
     * @description determineUserAccess
     * @param flowInputs 
     * @return  `List<FlowOutputs>`
     */
    @InvocableMethod
    public static List<FlowOutputs> determineUserAccess(List<FlowInputs> flowInputs){
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowOutputs result = new FlowOutputs();
        if(flowInputs.get(0).objectNameList != null || !flowInputs.get(0).objectNameList.isEmpty()){
            result.objectNameAndAccess = getUserAccessToSObjectList(flowInputs.get(0).objectNameList);
            if(flowInputs.get(0).checkRecordTypeAccess != null && flowInputs.get(0).checkRecordTypeAccess){
                result.recordTypeAccess = isObjectRecordTypeAvailable(flowInputs.get(0).objectNameList);
            	
            }
            
            results.add(result);
        }
        	return results;
    }
    
    /**
     * @description getUserAccessToSObjectList
     * @param objectNameList 
     * @return  `List<String>`
     */
    public static List<String> getUserAccessToSObjectList(List<String> objectNameList) {
        List<SObject> records = convertNameListToSObjectList(objectNameList);
        List<String> currentUserPermissions = new List<String>();
        for(SObject record : records){  
            if(isObjectReadable(record)){
                currentUserPermissions.add((record.getSObjectType() + 'Read' + TRUE_VALUE));
            }else{
                currentUserPermissions.add((record.getSObjectType() + 'Read' + FALSE_VALUE));
            }
            if(isObjectEditable(record)){
                currentUserPermissions.add((record.getSObjectType() + 'Edit' + TRUE_VALUE));
            }else{
                currentUserPermissions.add((record.getSObjectType() + 'Edit' + FALSE_VALUE));
            }
            if(isObjectCreateable(record)){
                currentUserPermissions.add((record.getSObjectType() + 'Create' + TRUE_VALUE));
            }else{
                currentUserPermissions.add((record.getSObjectType() + 'Create' + FALSE_VALUE));
            }
            if(isObjectDeletable(record)){
                currentUserPermissions.add((record.getSObjectType() + 'Delete' + TRUE_VALUE));
            }else{
                currentUserPermissions.add((record.getSObjectType() + 'Delete' + FALSE_VALUE));
            } 
        }
        return currentUserPermissions;  
    }
    /**
     * @description isObjectReadable
     * @param record 
     * @return  `boolean`
     */
    public static boolean isObjectReadable(SObject record){
        return record.getSObjectType().getDescribe().isAccessible();
    }
    /**
     * @description isObjectEditable
     * @param record 
     * @return  `boolean`
     */
    public static boolean isObjectEditable(SObject record){
        return record.getSObjectType().getDescribe().isUpdateable();
    }
    /**
     * @description isObjectCreateable
     * @param record 
     * @return  `boolean`
     */
    public static boolean isObjectCreateable(SObject record){
        return record.getSObjectType().getDescribe().isCreateable();
    }
    /**
     * @description isObjectDeletable
     * @param record 
     * @return  `boolean`
     */
    public static boolean isObjectDeletable(SObject record){
        return record.getSObjectType().getDescribe().isDeletable();
    }
    /**
     * @description isObjectRecordTypeAvailable
     * @param objectNameList 
     * @return  `List<String>`
     */
    public static List<String> isObjectRecordTypeAvailable(List<String> objectNameList){
        List<SObject> records = convertNameListToSObjectList(objectNameList);
        List<String> availableRecordTypeNames = new List<String>();
        List<RecordTypeInfo> availableRecordTypeInfos = new List<RecordTypeInfo>();
        for(SObject record : records){  
         	SObjectType objectType = record.getSObjectType();
        	availableRecordTypeInfos = objectType.getDescribe().getRecordTypeInfos();
            for(RecordTypeInfo recordTypeInfo : availableRecordTypeInfos){
                if(recordTypeInfo.IsAvailable()){
                    availableRecordTypeNames.add(record.getSObjectType() + recordTypeInfo.developername);
                }
            }
        }  
        return availableRecordTypeNames;
    }

    /**
     * @description convertNameListToSObjectList
     * @param objectNameList 
     * @return  `List<SObject>`
     */	
    public static List<SObject> convertNameListToSObjectList(List<String> objectNameList){
        List<SObject> records = new List<SObject>();
        DescribeSObjectResult result;
        SObjectType recordType;
        for(String objectName : objectNameList){
            try{
               result = Schema.getGlobalDescribe().get(objectName).getDescribe();
       		   recordType = result.getSObjectType();
               records.add(recordType.newSObject());
            }catch(Exception ex){
               ex.setMessage('An error occured: ' + ex.getMessage() + 'The most common error is a mispelled SObject Name');
            }
            
        }
        
       	
        return records;
    }

}