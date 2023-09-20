/**
  * @name UTIL_CustomerGroupMoveMemberResponse
  * @author Poseidon
  * @createdDate 12/17/2018
  * @description Response object from Household Management service
  */
public with sharing class UTIL_CustomerGroupMoveMemberResponse {
    public CustomerGroupResponseData data;
    public List<String> errors;
    public String servicingAgentAssocId;
    
    /**
     * @description Customer Group Data
     */
    public with sharing class CustomerGroupData {
        public String customer;	
        public String groupId;
    }
    
    /**
     * @description Customer Group Response Data
     */
    public with sharing class CustomerGroupResponseData {
        public List<CustomerGroupData> groupings;
    }
    
    /**
     * @description parse
     * @param json
     * @return UTIL_CustomerGroupMoveMemberResponse
     */
    public static UTIL_CustomerGroupMoveMemberResponse parse(String json) {
        return (UTIL_CustomerGroupMoveMemberResponse) System.JSON.deserialize(json, UTIL_CustomerGroupMoveMemberResponse.class);
    }
}