/**
  * @author: Targaryen
  * @owner: Targaryen
  * @name: AP_FSCHHSyncServiceRequest
  * @createdDate: 10/16/2020
  * @description The class is a JSON object for FSCHHSyncService.
  * @version 1.0
  */
  public with sharing class AP_FSCHHSyncServiceRequest {
    public FSCHHSyncData data;
    public FSCHHSyncMeta meta;
    
    /**
     * @description FSCHH Sync Data
     */
    public with sharing class FSCHHSyncData {
        public String operation;       
        public Datetime transactionTimestamp;
        public List<GroupInfo> groupInfo;
        
    }
    
    /**
     * @description Group Info
     */
    public with sharing class GroupInfo{
        public String associateId;
        public boolean groupIdRemovedIndicator;
        public String fscExternalGroupIdImpacted;
        public String hhMember;
        public String impactedCustomers;
        public boolean isActive;
        public Date endDate;
    }
    /**
     * @description FSCHHS Sync Meta
     */
    public with sharing class FSCHHSyncMeta {
        public String callingApplication;
        public String callingArea;  
        public Requester requester;
    }
    /**
     * @description Requester
     */
    public with sharing class Requester {
        
        public String requesterReferenceId;
        public String requesterReferenceType;
    }
    
    
}