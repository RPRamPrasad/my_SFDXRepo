/**
@author Team STARK
@owner Team STARK
@name UTIL_HouseholdMemberDAO
@CreateDate 09/09/2021
@modifiedDate
@description Common DAO class to access various AccontContactRelation related DML operations.
This is with Sharing class used only by Manage Household Members - add, move and remove
@version 1.0
*/
public with sharing class UTIL_HouseholdMemberDAO {
    /**
    * @description This method is used to insert AccountContactRelation and return success or failed status
    * @name : insertACRAndReturnSaveResults
    * @param insertACRList
    * @return List<Database.SaveResult>
    */
    public static List<Database.SaveResult> insertACRAndReturnSaveResults(List<AccountContactRelation> insertACRList){
        List<Database.SaveResult> acrSaveResultList = new List<Database.SaveResult>();
        acrSaveResultList = Database.insert(
            Security.stripInaccessible(
                AccessType.CREATABLE,
                insertACRList,
                true)
                .getRecords(), false);
        return acrSaveResultList;
    }
   
    /**
    * @description This method is used to update AccountContactRelation and return success or failed status
    * @name : updateACRAndReturnSaveResults
    * @param updateACRList
    * @return List<Database.SaveResult>
    */
    public static List<Database.SaveResult> updateACRAndReturnSaveResults(List<AccountContactRelation> updateACRList){
        List<Database.SaveResult> acrSaveResultList = new List<Database.SaveResult>();
        acrSaveResultList = Database.update(
            Security.stripInaccessible(
                AccessType.UPDATABLE,
                updateACRList,
                true)
                .getRecords(), false);
        return acrSaveResultList;
    }

    /**
    * @description This method is used to delete AccountContactRelation and return success or failed status
    * @name : deleteACRAndReturnSaveResults
    * @param deleteACRList
    * @return List<Database.SaveResult>
    */
    public static List<Database.DeleteResult> deleteACRAndReturnSaveResults(List<AccountContactRelation> deleteACRList){
        List<Database.DeleteResult> acrDeleteResultList = new List<Database.DeleteResult>();
        acrDeleteResultList = Database.delete(deleteACRList);
        return acrDeleteResultList;
    }
}