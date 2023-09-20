/**
 * @description CasePermissionUtil.cls
 */
public with sharing class CasePermissionUtil {
    
    @TestVisible private static final String CASE_ESCALATION_USER_CUSTOM_PERMISSION = 'Case_Escalation_User';
    @TestVisible private static final String ALLOW_CASE_OWNER_CHANGE_CUSTOM_PERMISSION = 'Allow_Case_Owner_Change';
    @TestVisible private static final String PRE_VALIDATED_DATA_CUSTOM_PERMISSION = 'Allow_DML_Bypass_For_Prevalidated_Data';
    @TestVisible private static final String DEV_TECH_SUPPORT_USER = 'Dev_Tech_Support_User';
    @TestVisible private CustomPermissionUtil util = new CustomPermissionUtil();
    /**
     * @description isAllowedToChangeOwner
     * @param oldCase 
     * @return  `boolean`
     */
    public boolean isAllowedToChangeOwner(Case oldCase){
        return this.util.checkPermission(ALLOW_CASE_OWNER_CHANGE_CUSTOM_PERMISSION) || oldCase.OwnerId == UserInfo.getUserId();
    }
    /**
     * @description isPrevalidatedUser
     * @return  `boolean`
     */
    public boolean isPrevalidatedUser(){
        return this.util.checkPermission(PRE_VALIDATED_DATA_CUSTOM_PERMISSION);
    }
    /**
     * @description isCaseEscalationUser
     * @return  `boolean`
     */
    public boolean isCaseEscalationUser(){
        return this.util.checkPermission(CASE_ESCALATION_USER_CUSTOM_PERMISSION);
    }
    /**
     * @description isTechSupportUser
     * @return  `boolean`
     */
    public boolean isTechSupportUser(){
        return this.util.checkPermission(DEV_TECH_SUPPORT_USER);
    }
    
}