/**
  * @name AQ_WorkItem
  * @author Team Skynet
  * @createdDate 12/07/2022
  * @description  Wrapper class for Agent Queue Work Items
*/
public with sharing class AQ_WorkItem {

    /**@description work item type */
    @AuraEnabled
    public String itemType { get; set; }
    
    /**@description accountid */
    @AuraEnabled
    public Id accountId { get; set; }
    
    /**@description Household Id */
    @AuraEnabled
    public Id hhId { get; set; }
    
    /**@description due Date */
    @AuraEnabled
    public Date dueDate { get; set; }
    
    /**@description work item */
    @AuraEnabled
    public SObject item { get; set; }
    
    /**@description child items, typically tasks */
    @AuraEnabled
    public List<SObject> childItems { get; set; }
    
    /**
     * @param item
     * @param itemType
     * @description Constructor with item and itemtype 
     * */
    public AQ_WorkItem(SObject item, String itemType) {
        this.ItemType = itemType;
        this.Item = item;
    }

}