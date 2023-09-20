/**
 * @description AT_UTIL_ProductConstants
 */
public with sharing class AT_UTIL_ProductConstants {
    
    public static final String REGEX_SFO_CODE = '[0-9]{2}-[0-9]{4} SFO ';
    public static final String REGEX_ALL_X = '^(x)\\1*$';
    public static final integer LINK_NUMBER_FOR_WEB_NECHO_POLICY=9;
    public static final integer LINK_NUMBER_FOR_WEB_NECHO_POLICIES_ASSOC=69;
    public static final integer LINK_NUMBER_FOR_AUTO_FIRE_POLICY=13;
    public static final integer LINK_NUMBER_FOR_AUTO_FIRE_POLICY_ASSOC=28;
    public static final integer LINK_NUMBER_FOR_AUTO_FIRE_POLICY_STAGT=24;
    public static final integer LINK_NUMBER_FOR_AUTO_FIRE_POLICY_PMR=198;
    public static final integer LINK_NUMBER_FOR_LIFE_POLICY=68;
    public static final integer LINK_NUMBER_FOR_LIFE_POLICY_ASSOC=105;
    public static final integer LINK_NUMBER_FOR_PHOENIX_POLICY_VIEW=87;
    public static final integer LINK_NUMBER_FOR_PHOENIX_POLICY_VIEW_ASSOC=106;
    public static final integer LINK_NUMBER_FOR_PHOENIX_POLICY_VIEW2=192;
    public static final integer LINK_NUMBER_FOR_MUTUALFUND_POLICY=112;
    public static final integer LINK_NUMBER_FOR_BANK_POLICY=187;
    public static final integer LINK_NUMBER_FOR_PLM_MOD_AUTO_POLICYVIEW=92;
    public static final integer LINK_NUMBER_FOR_PLM_MOD_AUTO_POLICYCHANGE=93;
    public static final integer LINK_NUMBER_FOR_PLM_MOD_FIRE_POLICYVIEW=94;
    public static final integer LINK_NUMBER_FOR_PLM_MOD_FIRE_POLICYCHANGE=96;
    public static final String AUTO = 'A';
    public static final String FIRE = 'F';
    public static final String LOB_A = 'Auto';
    public static final String LOB_F = 'Fire';
    public static final String MUTUAL = 'M';
    public static final String HEALTH = 'H';
    public static final String BANK = 'B';
    public static final String LIFE = 'L';
    public static final String HOMEOWNERS ='HOMEOWNERS';
    public static final String MULT_VEH ='Multiple Vehicle';
    public static final String POLICY = 'policy';
    public static final String POLICY_TRANSACTION = 'new pt';
    public static final String TABLE_OF_CONTENTS = 'main toc';
    public static final String Y_CHAR = 'Y';
    public static final string EXTERNAL_LINK_PAGE ='/apex/VFP_ExternalLink?LinkId=';
    public static final string AGRE_SOURCE_SYS_CD_LIFE_MOD = '23';
    public static final string AGRE_SOURCE_SYS_CD_PLM_MOD_ALL = '15';
    public static final string AGRE_SOURCE_SYS_CD_PLM_MOD_AUTO = '24';
    public static final string AGRE_SOURCE_SYS_CD_PLM_MOD_FIRE = '26';
    public static final List<String> ALL_MOD_CODES = new List<String> { AGRE_SOURCE_SYS_CD_PLM_MOD_ALL, AGRE_SOURCE_SYS_CD_PLM_MOD_AUTO, AGRE_SOURCE_SYS_CD_PLM_MOD_FIRE };
    public static final String APARTMENT = 'Apartment Policy';
    public static final String BUSINESS_OWNERS = 'Businessowners Policy';
    public static final String RES_COMM_ASSOC = 'Residential Community Association Policy';
    public static final String BUSINESS_SERV = 'Business Services Policy';
    public static final String ACCESS_NOT_ALLOWED = 'ACCESS';
    public static final String AUTO_FIRE_ROLE_NAME_CD = '18';
    public static final String AUTO_FIRE_SECONDARY_ROLE_NAME_V2 = '20';
    public static final String AUTO_FIRE_SECONDARY_ROLE_NAME_V3 = '28'; 
    public static final String FIRE_AGREEMENT_SOURCE_CODE_LEGACY= '1'; 
    public static final String FIRE_AGREEMENT_SOURCE_CODE_BLM= '15'; 
}