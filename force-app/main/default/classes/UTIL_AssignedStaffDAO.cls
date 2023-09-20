/**  
@Author Choo_Choo  
@Owner Team Stark
@name UTIL_AssignedStaffDAO
@CreateDate 04/26/2018 
@description This is a utility class that implements Inserting AssignedStaff
@Version 1.0
*/
public without sharing class UTIL_AssignedStaffDAO {
    
    /**
* @method insertAssignedStaff: Insert Assigned Staff
* @description insertAssignedStaff
* @param assignedStaffList List of Assigned Staff
*/    
    public static void insertAssignedStaff(List<AssignedStaff__c> assignedStaffList){
        if(assignedStaffList!= null && !assignedStaffList.isEmpty()){
            insert assignedStaffList;
        }
    }
    
    /**
* @method updateAssignedStaff: update Assigned Staff
* @description updateAssignedStaff
* @param assignedStaffList List of Assigned Staff
*/    
    public static void updateAssignedStaff(List<AssignedStaff__c> assignedStaffList){
        if(assignedStaffList!= null && !assignedStaffList.isEmpty()){
            update assignedStaffList;
        }
    }
    
    
    /**
* @method updateAssignedStaffWithResponse: update Assigned Staff and return the response
* @description updateAssignedStaffWithResponse
* @param assignedStaffList List of Assigned Staff
* @return Database.SaveResult[]
*/    
    public static Database.SaveResult[] updateAssignedStaffWithResponse(List<AssignedStaff__c> assignedStaffList){
        Database.SaveResult[] updateResult = new List<Database.SaveResult>();
        if(assignedStaffList!= null && !assignedStaffList.isEmpty()){
            updateResult = Database.update(assignedStaffList, false);
        }
        return updateResult;
    }
    
    /**
* @method upsertAssignedStaff: upsert Assigned Staff
* @description upsertAssignedStaff
* @param assignedStaffList List of Assigned Staff
* @param externalIdField External Id
* @return Database.UpsertResult[]
*/    
    public static Database.UpsertResult[] upsertAssignedStaff(List<AssignedStaff__c> assignedStaffList, String externalIdField){
        Database.UpsertResult[] upsertResults = null; 
        if(assignedStaffList!= null && !assignedStaffList.isEmpty()){
            upsertResults =  Database.upsert(assignedStaffList, Schema.SObjectType.AssignedStaff__c.fields.getMap().get(externalIdField), false);
        }
        return upsertResults;
    }
    
    /**
* @method deleteAssignedStaff: delete Assigned Staff
* @description deleteAssignedStaff
* @param assignedStaffList List of Assigned Staff
*/    
    public static void deleteAssignedStaff(List<AssignedStaff__c> assignedStaffList){
        if(assignedStaffList!= null && !assignedStaffList.isEmpty()){
            delete assignedStaffList;
        }
    }
}