/*
 * Agreement sync - JSON POJO
 * @author Team Stark
 * @owner  Team Stark
 * @version 1.0
 * @dateCreated 8/10/2018 
 */

 /**
  * @description AP Agreement Sync Json
  */
public with sharing class AP_AgreementSyncJson {
	
	public cls_agreementRisks[] agreementRisks;

	/**
	 * @description CLS Agreement Risks
	 */
	public with sharing class cls_agreementRisks {
		public cls_agreRisk agreRisk;
	}
	
	/**
	 * @description CLS Agre Risk
	 */
	public with sharing class cls_agreRisk {
		public String agreRiskName;
		public String sfdcPolicyNumSearchKey;
		public String addrId;
		public String agreAccessKey;	
		public String agreDsplyNum;	
		public String agreDsplyPartyNm;	
		public Date agreEndDt;	
		public Date agreIncpDt;	
		public String agreIndexId;	
		public String agreIndexRiskNum;
		public String agreSrcSysCd;	
		public String agreSttsTxt;	
		public String agreSrcSysText;	
		public String apartmentNumber;	
		public String cityName;	
		public String clasCd;	
		public String companFormCd;
		public String coCd;	
		public String countryNameText;	
		public Double covAmt;	
		public Date riskEndDt;
		public DateTime extSrcSyncTime;	
		public String fletInd;	
		public String houseNumber;
		public String insAppNum;	
		public String policyMailPostalBarcode;
		public String mrktProdSpecId;	
		public String mstrDataLocCd;	
		public String mstrSrcRiskId;	
		public String mstrSrcRiskTypeCd;	
		public String mstrSrcRiskTypeText;
		public Date nextRenDt;	
		public String prtlEntTypeCd;
		public String physObjSerNum;
		public String physObjTypeId;
		public String physObjTypeText;
		public String plcyChngCd;	
		public String plcyMasterSttsCd;	
		public String plcyFormCd;	
		public String plcyKindCd;	
		public String plcyTypeCd;	
		public String postalStateCode;	
		public String postalZipCode;	
		public String poBoxNumber;	
		public String prodLineTxt;	
		public String prodDescTxt;	
		public String prodLineCd;	
		public String riskCtgryCd;	
		public String riskDescTxt;	
		public String riskGrpCd;	
		public String riskNum;	
		public String riskSttsTxt;	
		public String ruralRouteNumber;
		public String servicingAgentAssocID;	
		public String shortAppInd;	
		public String standardIndicator;
		public String fullStreetAddressText;
		public String streetName;	
		public String streetNamePostDirectionCode;	
		public String streetNamePreDirectionCode;	
		public String streetSuffixCode;	
		public String tqCd;	
		public String unitDesignationCode;	
		public cls_agreementPartyRoles[] agreementPartyRoles;
	}
	
	/**
	 * @description Cls Agre Party Role
	 */
	public with sharing class cls_agrePartyRole {
		public String partyId;	
		public String agreIndexRiskNum;
		public String agreIndexPartyIdRiskNum;
		public DateTime extSrcSyncTime;	
		public String roleNameCd;	
		public String roleNameText;	
		public String secondaryRoleNameCd;
		public String secondaryRoleNameText;	
	}
	
	/**
	 * @description Cls Agreement Party Roles
	 */
	public with sharing class cls_agreementPartyRoles {
		public cls_agrePartyRole agrePartyRole;
	}
	
	//Utility method to convert JSON string to Apex object
	/**
	 * @description parse
	 * @param json
	 * @return AP_AgreementSyncJson
	 */
	public static AP_AgreementSyncJson parse(String json){
        return (AP_AgreementSyncJson) System.JSON.deserialize(json, AP_AgreementSyncJson.class);
    }
    
}