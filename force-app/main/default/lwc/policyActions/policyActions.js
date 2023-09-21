import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import {
    subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext
} from 'lightning/messageService';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getVFOrigin from '@salesforce/apex/HA4C_PKCE.getVFOrigin';
import getHA4CToken from '@salesforce/apex/HA4C_PKCE.getHA4CToken';
import getPolicyDetailsParmHA4C from '@salesforce/apex/Ha4cWebController.getPolicyDetailsParmHA4C';

//Lightning Message Service channels
import selectedRisk from '@salesforce/messageChannel/risk__c';

//policy fields
import AGREEMENT_ACCESS_KEY from '@salesforce/schema/InsurancePolicy.AgreAccessKey__c';
import LINE_OF_BUSINESS from '@salesforce/schema/InsurancePolicy.ProdLineCd__c';
import SOURCE_SYSTEM_CODE from '@salesforce/schema/InsurancePolicy.AgreSourceSysCd__c';
import FLEET_INDICATOR from '@salesforce/schema/InsurancePolicy.FleetInd__c';
import POLICY_TYPE_CODE from '@salesforce/schema/InsurancePolicy.PlcyTypeCd__c';
import POLICY_NUMBER from '@salesforce/schema/InsurancePolicy.Name';
import POLICY_NAME from '@salesforce/schema/InsurancePolicy.PolicyName';
import POLICY_DESCRIPTION from '@salesforce/schema/InsurancePolicy.PolicyDescription';
import AGREE_INDEX_ID from '@salesforce/schema/InsurancePolicy.SourceSystemIdentifier';
import POLICY_STATUS from '@salesforce/schema/InsurancePolicy.Status';
import MASTER_DATA_LOCATION_CODE from '@salesforce/schema/InsurancePolicy.MasterDataLocationCd__c';
import COMPANY_CODE from '@salesforce/schema/InsurancePolicy.CoCd__c';
import AGENT_ASSOCIATE_ID from '@salesforce/schema/InsurancePolicy.Servicing_Agent__r.Associate_ID__c';
import STATE_AGENT_CODE from '@salesforce/schema/InsurancePolicy.Servicing_Agent__r.State_Agent_Code__c';
import NAMED_INSURED from '@salesforce/schema/InsurancePolicy.NameInsuredId';
import NAMED_INSURED_CLIENT_ID from '@salesforce/schema/InsurancePolicy.NameInsured.ClientIdentifier__c';
import NAMED_INSURED_NAME from '@salesforce/schema/InsurancePolicy.NameInsured.Name';
import NAMED_INSURED_EMAIL from '@salesforce/schema/InsurancePolicy.NameInsured.PersonEmail';
import NAMED_INSURED_STREET_ADDRESS from '@salesforce/schema/InsurancePolicy.NameInsured.BillingStreet';
import NAMED_INSURED_CITY_ADDRESS from '@salesforce/schema/InsurancePolicy.NameInsured.BillingCity';
import NAMED_INSURED_STATE_ADDRESS from '@salesforce/schema/InsurancePolicy.NameInsured.BillingState';
import NAMED_INSURED_ZIP_ADDRESS from '@salesforce/schema/InsurancePolicy.NameInsured.BillingPostalCode';
import NAMED_INSURED_FIRST_NAME from '@salesforce/schema/InsurancePolicy.NameInsured.FirstName';
import NAMED_INSURED_LAST_NAME from '@salesforce/schema/InsurancePolicy.NameInsured.LastName';
import ROLE_CD from '@salesforce/schema/InsurancePolicy.NI_RoleNameCd__c';
import SECONDARY_ROLE_CD from '@salesforce/schema/InsurancePolicy.NI_SecondaryRoleNameCd__c';
import UNFORMATTED_POLICY_NUMBER from '@salesforce/schema/InsurancePolicy.SFDCPolicyNumberSearchKey__c';

//user fields
import USER_ID from '@salesforce/user/Id';
import SERVICING_AGENT_ASSOC_ID from '@salesforce/schema/User.Servicing_Agent_Associate_ID__c';
import PROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import USER_CRITERIA from '@salesforce/schema/User.UserCriteriaList__c';
import SUBUSER_TYPE from '@salesforce/schema/User.SubUserType__c';

//access imports
import hasSAEPolicyChangeAccess from '@salesforce/customPermission/SAE_Policy_Change';
import { getFeatureAccessMetadataBySubuserType,getFeatureAccessMetadataByUserCriteria } from 'c/checkFeatureAccess';
import {
    buildDetailsLaunchout,
    isOutOfBookPolicy
} from './details';
import {
    buildActionsList,
    launchAutoPolicyAction,
    launchFirePolicyAction,
    launchWebNecho,
    launchEmailAutoIDCard,
    launchBillingOnlineSystem,
    launchCertificateOfInsurance
} from './actions';
import {
    throwToast,
    launchNewCase,
    retrieveGroupPolicyStatus,
    retrieveEncodedDescription,
    retrievePLMStatus,
    handlePolicyChange,
    handleAddVehicle,
    handleDSSBeaconReorder,
    handlePremiumChangeInquiry,
    handleAgentStatusTracker,
    handleTOOF,
    handleEmailAutoIDCard,
    retrieveIPAssets
} from './utils';
import { retrievePrimaryNamedInsured } from './roles';
import { constants } from 'c/policyDetailsCommonJS';

const {
    LIFE,
    TERMINATED_STATUS,
    POLICY_RETRIEVAL_ERROR,
    PARTIAL_POLICY_RETRIEVAL_ERROR,
    ADD_DRIVER,
    REPLACE_VEHICLE,
    POLICY_CHANGE,
    ADD_VEHICLE,
    AUTO_POLICY_CHANGE,
    FIRE_POLICY_CHANGE,
    LIFE_POLICY_CHANGE,
    HEALTH_POLICY_CHANGE,
    TOOF_REINSTATEMENT,
    DSS_BEACON_REORDER,
    PREMIUM_CHANGE_INQUIRY,
    AGENT_STATUS_TRACKER,
    EMAIL_AUTO_ID_CARD,
    BILLING_ONLINE_SYSTEM,
    CERTIFICATE_OF_INSURANCE,
    ADD_DRIVER_CASE,
    REPLACE_VEH_CASE,
    POLICY_CHANGE_CASE,
    NECHO_MAIN_TOC,
    PERSONAL_AUTO_MOD_CD,
    HDC_POLICY_TYPE
} = constants;

const MULTI_VEHICLE = 'MULTIPLE VEHICLE';
const PNX_DESC_PREFIX = 'PNX';

const SUCCESS_STATUS = 200;
const UNKNOWN = 'unknown';

const isJsonString = (jsonString) => {
    try {
        const o = JSON.parse(jsonString);
        if (o && typeof o === "object") {
            return true;
        }
    }
    catch (e) {
        // returning false
    }
    return false;
};

const parseJSON = (jsonString) => {
    if (isJsonString(jsonString)) {
        return JSON.parse(jsonString);
    }
    return {};
};

export default class PolicyActions extends NavigationMixin(LightningElement) {
    @api recordId;
    isSavingRecord = false;
    lob;
    agreementAccessKey;
    sourceSystemCode;
    policyTypeCode;
    policyNumber;
    productDescription;
    policyName;
    agreementIndexId;
    policyStatus;
    masterDataLocationCode;
    companyCode;
    agentAssociateId;
    stateAgentCode;
    namedInsured;
    niClientId;
    niName;
    niFirstName;
    niLastName;
    niEmail;
    niRoleCd;
    niSecondaryRoleCd;
    niStreet;
    niCity;
    niState;
    niZip;
    unformattedPolicyNumber;
    showSendModal = false;
    sendEmail = false;
    saPCAgreementIndexID;
    sapcparamObject;

    userId = USER_ID;
    loggedInProfile;
    loggedInAgentAssociateId;
    loggedInPilotUser2; //HATS Pilot Field
    loggedInUserCriteria;
    loggedInSubuser;

    
    loadFrame;
    WORKSTATION = 'ha4c_workstation_id';
    calledRenderedCallback = false;
    vfMessageListener;
    parmString;

    accountContext = {
        recordId: null,
        clientId: null,
        name: null,
        email: null
    };

    riskStatus;
    riskNumber;
    riskDescription;
    totalRisks;

    error;
    warning;
    isLoading = true;
    actionsButtonList = [];
    actionsMenuList = [];
    detailsURL;
    encodedDescription;
    caseId;

    userAccess = {
        hasPolicyTransactionAccess: false,
        hasToofLinkAccess: false,
        // hasAutoIdCardAccess: false,
        hasAutoIdCardAccessforSubuserType: false,
        hasAutoIdCardAccessforUserCriteria: false,
        hasBOSLinkAccess: false,
        hasCOILinkAccess: false,
        isGroupPolicy: false,
        hasDSSBeaconReorderAccess: false,
        hasPremiumChangeInquiryAccess: false,
        hasAgentStatusTrackerAccess: false,
        hasPolicyDocumentsAccess: false,
        hasSAEPolicyChangeAccess: false
    };

    plmActivationStatus = {}

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            LINE_OF_BUSINESS,
            AGREEMENT_ACCESS_KEY,
            SOURCE_SYSTEM_CODE,
            POLICY_TYPE_CODE,
            FLEET_INDICATOR,
            POLICY_NUMBER,
            POLICY_DESCRIPTION,
            POLICY_NAME,
            AGREE_INDEX_ID,
            POLICY_STATUS,
            MASTER_DATA_LOCATION_CODE,
            COMPANY_CODE,
            AGENT_ASSOCIATE_ID,
            STATE_AGENT_CODE,
            NAMED_INSURED,
            NAMED_INSURED_CLIENT_ID,
            NAMED_INSURED_NAME,
            NAMED_INSURED_FIRST_NAME,
            NAMED_INSURED_LAST_NAME,
            NAMED_INSURED_EMAIL,
            NAMED_INSURED_STREET_ADDRESS,
            NAMED_INSURED_CITY_ADDRESS,
            NAMED_INSURED_STATE_ADDRESS,
            NAMED_INSURED_ZIP_ADDRESS,
            ROLE_CD,
            SECONDARY_ROLE_CD,
            UNFORMATTED_POLICY_NUMBER
        ],
        optionalFields: []
    })

    
    async getInsurancePolicyRecordData(result) {
        this.isLoading = true;
        this.warning = null;
        this.error = null;

        if (result.data) {
            this.lob = getFieldValue(result.data, LINE_OF_BUSINESS).toUpperCase();
            this.agreementAccessKey = getFieldValue(result.data, AGREEMENT_ACCESS_KEY);
            this.sourceSystemCode = parseInt(getFieldValue(result.data, SOURCE_SYSTEM_CODE), 10);
            this.policyTypeCode = getFieldValue(result.data, POLICY_TYPE_CODE) ? getFieldValue(result.data, POLICY_TYPE_CODE).toUpperCase() : '';
            this.policyNumber = getFieldValue(result.data, POLICY_NUMBER);
            this.fleetIndicator = getFieldValue(result.data, FLEET_INDICATOR);
            this.productDescription = getFieldValue(result.data, POLICY_DESCRIPTION);
            this.policyName = getFieldValue(result.data, POLICY_NAME);
            this.agreementIndexId = getFieldValue(result.data, AGREE_INDEX_ID);
            this.policyStatus = getFieldValue(result.data, POLICY_STATUS);
            this.masterDataLocationCode = getFieldValue(result.data, MASTER_DATA_LOCATION_CODE);
            this.companyCode = getFieldValue(result.data, COMPANY_CODE);
            this.agentAssociateId = getFieldValue(result.data, AGENT_ASSOCIATE_ID);
            this.stateAgentCode = getFieldValue(result.data, STATE_AGENT_CODE);
            this.namedInsured = getFieldValue(result.data, NAMED_INSURED);
            this.niClientId = getFieldValue(result.data, NAMED_INSURED_CLIENT_ID);
            this.niName = getFieldValue(result.data, NAMED_INSURED_NAME);
            this.niFirstName = getFieldValue(result.data, NAMED_INSURED_FIRST_NAME);
            this.niLastName = getFieldValue(result.data, NAMED_INSURED_LAST_NAME);
            this.niEmail = getFieldValue(result.data, NAMED_INSURED_EMAIL);
            this.niRoleCd = getFieldValue(result.data, ROLE_CD);
            this.niSecondaryRoleCd = getFieldValue(result.data, SECONDARY_ROLE_CD);
            this.unformattedPolicyNumber = getFieldValue(result.data, UNFORMATTED_POLICY_NUMBER);
            this.niStreet = getFieldValue(result.data, NAMED_INSURED_STREET_ADDRESS);
            this.niCity = getFieldValue(result.data, NAMED_INSURED_CITY_ADDRESS);
            this.niState = getFieldValue(result.data, NAMED_INSURED_STATE_ADDRESS);
            this.niZip = getFieldValue(result.data, NAMED_INSURED_ZIP_ADDRESS);

            await Promise.all(this.makePreliminaryPromises());

            if (!this.waitingForRisk) {
                await this.makeDescriptionPromise();
                this.userAccess.hasSAEPolicyChangeAccess = hasSAEPolicyChangeAccess;
              //  this.userAccess.hasPremiumChangeInquiryAccess = hasPremiumChangeInquiryAccess;
                await Promise.all(this.makePrimaryPromises());
            }
        } else if (result.error) {
            this.error = JSON.stringify(result.error);
        }
        this.isLoading = false;
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [
            PROFILE_NAME,
            SERVICING_AGENT_ASSOC_ID,
            USER_CRITERIA,
            SUBUSER_TYPE
        ],
        optionalFields: []
    })
    getUserRecordData(result) {
        if (result.data) {
            this.loggedInAgentAssociateId = getFieldValue(result.data, SERVICING_AGENT_ASSOC_ID);
            this.loggedInProfile = getFieldValue(result.data, PROFILE_NAME);
            this.loggedInUserCriteria = getFieldValue(result.data, USER_CRITERIA); //added by shruti
            this.loggedInSubuser = getFieldValue(result.data, SUBUSER_TYPE); //added by shruti
        }
    }

    get isHagertyDriversClub() {
        return this.policyTypeCode === HDC_POLICY_TYPE;
    }

    get detailsButtonIsVisible() {
        return this.lob && !this.waitingForRisk? true:false;
    }

    get waitingForRisk() {
        return this.isMultiCarAuto && !this.riskNumber;
    }

    get status() {
        return this.isMultiCarAuto && this.riskStatus ? this.riskStatus : this.policyStatus;
    }

    get isStatusTerminated() {
        return this.status === TERMINATED_STATUS;
    }

    get isMultiCarAuto() {
        let isMultiCar;
        if(this.sourceSystemCode === 24) {
            isMultiCar = this.totalRisks && this.totalRisks > 1;
        } else {
            isMultiCar = this.productDescription?.toUpperCase().includes(MULTI_VEHICLE);
        }
        return isMultiCar;
    }

    get isFleetAuto() {
        return this.fleetIndicator?.toUpperCase().includes('Y');
    }

    get isPhoenixLife() {
        return this.productDescription?.toUpperCase().startsWith(PNX_DESC_PREFIX);
    }

    get isASCLife() {
        return this.productDescription && (this.policyNumber.startsWith('SL') || this.policyNumber.startsWith('SA'));
    }

    get isPMRLife() {
        return this.productDescription && (this.policyNumber.startsWith('LF') || this.policyNumber.startsWith('AS'));
    }
    get getProductDescription(){
        let description;
        if (this.isMultiCarAuto){ // Multicar Auto Policy
            description = this.riskDescription;
        }
        else if (! this.isMultiCarAuto && this.isGroupPolicy){ // Group Policy
            description = this.policyName;
        }
        else{ // Single Policy
            description = this.productDescription;
        }

        return description;

    }

    @api
    get getUserAccess() {
        return Object.freeze(this.userAccess);
    }

    makePreliminaryPromises() {
        const pniPromise = retrievePrimaryNamedInsured({
            lob: this.lob,
            namedInsured: this.namedInsured,
            niClientId: this.niClientId,
            niName: this.niName,
            niEmail: this.niEmail,
            isPMRLife: this.isPMRLife,
            niRoleCd: this.niRoleCd,
            niSecondaryRoleCd: this.niSecondaryRoleCd,
            recordId: this.recordId
        }).then(pni => {
            if (pni && pni.accountRecordId && pni.accountClientId) {
                this.accountContext.recordId = pni.accountRecordId;
                this.accountContext.clientId = pni.accountClientId;
                this.accountContext.name = pni.accountName;
                this.accountContext.email = pni.accountEmail;
            } else {
                this.accountContext.recordId = this.namedInsured;
                this.accountContext.clientId = this.niClientId;
                this.accountContext.name = this.niName;
                this.accountContext.email = this.niEmail;
            }
        });
        let assetsPromise;
        if(this.sourceSystemCode === PERSONAL_AUTO_MOD_CD) {
            assetsPromise = retrieveIPAssets(this.recordId).then(ipAssets => {
                this.totalRisks = ipAssets.length;
            });
        } else {
            assetsPromise = Promise.resolve();
        }
        const groupPromise = retrieveGroupPolicyStatus(this.policyName).then(isGroupPolicy => {
            if (isGroupPolicy !== null) {
                this.isGroupPolicy = isGroupPolicy; //false is an allowed value, so this must have direct null check
            } else {
                this.warning = PARTIAL_POLICY_RETRIEVAL_ERROR;
            }
        });

        const policyTransactionPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_PolicyTransactions')
            .then(data => { this.handleAccessAssignment(data, 'hasPolicyTransactionAccess') });

        const toofLinkPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_ToofPolicy')
            .then(data => { this.handleAccessAssignment(data, 'hasToofLinkAccess') });

        /*const autoIdCardPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_AutoIDCard')
            .then( data => { this.userAccess.hasAutoIdCardAccess = data && data.read ? data.read : false; });
        */
        const autoIdCardforSubuserTypePromise = getFeatureAccessMetadataBySubuserType('PolicyActions_AutoIDCard')
            .then(data => { this.handleAccessAssignment(data, 'hasAutoIdCardAccessforSubuserType') });
        const autoIdCardforUserCriteriaPromise = getFeatureAccessMetadataByUserCriteria('PolicyActions_AutoIDCard')
            .then(data => { this.handleAccessAssignment(data, 'hasAutoIdCardAccessforUserCriteria') });

        const BOSPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_BillingOnlineSystem')
            .then(data => { this.handleAccessAssignment(data, 'hasBOSLinkAccess') });
        const COIPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_CertificateOfInsurance')
            .then(data => { this.handleAccessAssignment(data, 'hasCOILinkAccess') });
        const dssBeaconReorderPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_DSSBeaconReorder')
            .then(data => { this.handleAccessAssignment(data, 'hasDSSBeaconReorderAccess') });
        const premiumChangePromise = getFeatureAccessMetadataBySubuserType('PolicyActions_PremiumChange')
            .then(data => { this.handleAccessAssignment(data, 'hasPremiumChangeInquiryAccess') });

        const agentStatusTrackerPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_AgentStatusTracker')
            .then(data => { this.handleAccessAssignment(data, 'hasAgentStatusTrackerAccess') });

        const policyDocumentsPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_PolicyDocuments')
            .then(data => { this.handleAccessAssignment(data, 'hasPolicyDocumentsAccess') });


        const csPLMStatus = retrievePLMStatus().then(plmStatus => {
            this.plmActivationStatus.isOppRedirectActive = plmStatus.PLM_Opp_Redirect_Active__c;
            this.plmActivationStatus.isPCAutoLaunchActive = plmStatus.PLM_Auto_Launch_PC_Active__c;
            this.plmActivationStatus.isPolicyActionsActive = plmStatus.PLM_Policy_Actions_Active__c;
        });

        return [
            pniPromise,
            groupPromise,
            policyTransactionPromise,
            toofLinkPromise,
            //autoIdCardPromise,
            autoIdCardforSubuserTypePromise,
            autoIdCardforUserCriteriaPromise,
            BOSPromise,
            COIPromise,
            dssBeaconReorderPromise,
            premiumChangePromise,
            agentStatusTrackerPromise,
            policyDocumentsPromise,
            csPLMStatus,
            assetsPromise
        ];
    }

    handleAccessAssignment(data, accessName) {
        this.userAccess[accessName] = data && data.read ? data.read : false;
    }

    makeDescriptionPromise() {
        let description;

        if (this.isGroupPolicy) {
            description = this.policyName;
        } else if (this.isMultiCarAuto) {
            description = this.policyName + ': ' + this.riskDescription;
        } else {
            description = this.productDescription;
        }

        return retrieveEncodedDescription(description).then(encodedDescription => {
            if (encodedDescription) {
                this.encodedDescription = encodedDescription;
            } else {
                this.error = POLICY_RETRIEVAL_ERROR;
            }
        });
    }

    makePrimaryPromises() {
        const paramObj = {
            accountRecordId: this.accountContext.recordId,
            agreementIndexId: this.agreementIndexId,
            sourceSystemCode: this.sourceSystemCode,
            policyNumber: this.isMultiCarAuto ? this.policyNumber + '-' + this.riskNumber : this.policyNumber,
            policyName: this.policyName,
            productDescription: this.productDescription,
            policyTypeCode: this.policyTypeCode,
            lob: this.lob,
            encodedDescription: this.encodedDescription,
            agentAssociateId: this.agentAssociateId,
            outOfBook: isOutOfBookPolicy(this.agentAssociateId, this.loggedInProfile, this.loggedInAgentAssociateId),
            accessKey: this.agreementAccessKey,
            isStatusTerminated: this.isStatusTerminated,
            isMultiCarAuto: this.isMultiCarAuto,
            isFleetAuto: this.isFleetAuto,
            isPhoenixLife: this.isPhoenixLife,
            isPMRLife: this.isPMRLife,
            isASCLife: this.isASCLife,
            riskNumber: this.riskNumber,
            userId: this.userId,
            unformattedPolicyNumber: this.unformattedPolicyNumber,
            stateAgentCode: this.stateAgentCode
        };

        const actionPromise = buildActionsList(this.userAccess, paramObj)
            .then(actionLists => {
                this.actionsButtonList = (paramObj.sourceSystemCode !== PERSONAL_AUTO_MOD_CD || this.plmActivationStatus.isPolicyActionsActive) ? actionLists.actionsButtonList : [];
                this.actionsMenuList = (paramObj.sourceSystemCode !== PERSONAL_AUTO_MOD_CD || this.plmActivationStatus.isPolicyActionsActive) ? actionLists.actionsMenuList : [];
            });
        const detailsPromise = buildDetailsLaunchout(paramObj)
            .then(url => { this.detailsURL = url; });

        return [
            actionPromise,
            detailsPromise
        ];
    }

    subscribeToRiskMessageChannel() {
        this.riskSubscription = subscribe(
            this.messageContext,
            selectedRisk,
            async(message) => {
                if (message.policyRecordId === this.recordId && this.productDescription) {
                    this.isLoading = true;

                    this.riskStatus = message.riskStatus;
                    this.riskNumber = message.riskNumber;
                    this.riskDescription = message.riskDescription;

                    await this.makeDescriptionPromise();
                    this.userAccess.hasSAEPolicyChangeAccess = hasSAEPolicyChangeAccess;
                    // this.userAccess.hasPremiumChangeInquiryAccess = hasPremiumChangeInquiryAccess;
                    await Promise.all(this.makePrimaryPromises());

                    this.isLoading = false;
                }
            },
            { scope: APPLICATION_SCOPE }
        );
    }

    unsubscribeToRiskMessageChannel() {
        unsubscribe(this.riskSubscription);
        this.riskSubscription = null;
    }

    constructor() {
        super();
        // save a reference to the bound function 
        // because bind() returns a new function 
        // and the component would not be able to call 
        // removeEventListener() with the same function instance
        this.vfMessageListener = this.handleAuthResponse.bind(this);
    }

    connectedCallback() {
        this.subscribeToRiskMessageChannel();
        window.addEventListener('message', this.vfMessageListener);
    }

    disconnectedCallback() {
        this.unsubscribeToRiskMessageChannel();
    }

    async handleAuthResponse(event) {
        const vfOrigin = await getVFOrigin();
        if (event.data && (event.origin === vfOrigin)) {
            const msg = parseJSON(event.data);
            if (msg.ha4cVfReady === true) {
                this.initiateVFAuthCall(vfOrigin);
            }
            if (msg.ha4cToken === true) {
                await this.processToken();
            }
            if (msg.ha4cToken === false) {
                this.processWorkstationId(UNKNOWN);
            }
        }
    }

    initiateVFAuthCall(vfOrigin) {
        //call vf to initiate auth flow
        const message = { ha4cPkceLogin: true }
        this.template.querySelector('iframe').contentWindow.postMessage(JSON.stringify(message), vfOrigin);
    }

    async processToken() {
        const token = await getHA4CToken();
        const deviceId = parseJSON(window.atob(token.split('.')[1])).deviceid;
        const workstationId = await this.determineWorkstationId(token, deviceId);
        this.processWorkstationId(workstationId);
    }

    async determineWorkstationId(token, deviceId) {
        // call microsoftGraph API if the deviceId is not undefined
        if (typeof deviceId != 'undefined') {
            const endpoint = `https://graph.microsoft.com/v1.0/devices?$filter=deviceId+eq+'${deviceId}'&$select=displayName`;
            const respJson = await this.callMSGraph(endpoint, token);
            return respJson?.value[0]?.displayName || UNKNOWN;
        }
        return UNKNOWN
    }

    processWorkstationId(workstationId) {
        sessionStorage.setItem(this.WORKSTATION, workstationId);
        this.navigateToWeb(workstationId);

    }

    async handleClick() {
        const workstationId = sessionStorage.getItem(this.WORKSTATION);
        if (workstationId) {
            this.navigateToWeb(workstationId);
        } else {
            this.loadFrame = true;
        }    }


    //This method will launch URL in new Browser Window tab after setting up all paramters
    async navigateToWeb(workstationId) {
        try {
            this.parmString = await getPolicyDetailsParmHA4C({ caseId: this.caseId })
            window.open(this.parmString + '&workstationID=' + workstationId + '&pgmName=PCA21&callingApp=Case');
        } catch (error) {
            this.showToast('Launch to Necho Status', "Error", 'The operation couldnt be completed (Status: ' +
                error.message +
                ' ). Please contact WG11255.');
        }
    }

    async callMSGraph(endpoint, accessToken) {
        const bearer = `Bearer ${accessToken}`;
        const options = {
            method: "GET",
            headers: {
                'Authorization': bearer,
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'ConsistencyLevel': 'eventual'
            }
        };
        try {
            const response = await fetch(endpoint, options);
            // return response json only if the status code is 200
            if (response.status === SUCCESS_STATUS) {
                const responseBody = await response.json();
                return responseBody;
            }
        } catch (e) {
            // nothing to do here - just returning null
        }
        return null;
    }

    showToast(title, type, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            variant: type,
            message: message
        });
        this.dispatchEvent(toastEvent);
    }

    handleAction(event) {
        event.preventDefault();
        event.stopPropagation();

        // shared by lightning-button-group and lactionightning-button-menu, they pass events differently
        const actionLabel = event.target && event.target.label ? event.target.label : event.detail.value;

        const paramObject = {
            sourceSystemCode: this.sourceSystemCode,
            agreementIndexId: this.agreementIndexId,
            isMultiCarAuto: this.isMultiCarAuto,
            agentAssociateId: this.agentAssociateId,
            stateAgentCode: this.stateAgentCode,
            lob: this.lob,
            policyNumber: this.isMultiCarAuto ? this.policyNumber + '-' + this.riskNumber : this.policyNumber,
            accountRecordId: this.accountContext.recordId,
            accountClientId: this.accountContext.clientId,
            riskNumber: this.riskNumber,
            productDescription: this.getProductDescription,
            agreAccessKey: this.agreementAccessKey,
            unformattedPolicyNumber: this.unformattedPolicyNumber
        };

        if (this.lob === LIFE && this.niRoleCd === '22') {
            paramObject.policyOwner = this.namedInsured
        }

        this.isLoading = true;
        // eslint-disable-next-line default-case
        switch (actionLabel) {
            case POLICY_CHANGE:
                this.isSavingRecord = true;
                handlePolicyChange(paramObject, this).then((caseId) => { this.isSavingRecord = false ; this.caseId = caseId; this.handleClick();});
                break;
            case ADD_VEHICLE:
                this.isSavingRecord = true;
                handleAddVehicle(paramObject, this).then((caseId) => { this.isSavingRecord = false ; this.caseId = caseId; this.handleClick();});
                break;
            case ADD_DRIVER:
                launchAutoPolicyAction(paramObject);
                launchNewCase(ADD_DRIVER_CASE, paramObject, this);
                break;
            case REPLACE_VEHICLE:
                launchAutoPolicyAction(paramObject);
                launchNewCase(REPLACE_VEH_CASE, paramObject, this);
                break;
            case AUTO_POLICY_CHANGE:
                launchAutoPolicyAction(paramObject);
                launchNewCase(POLICY_CHANGE_CASE, paramObject, this);
                break;
            case FIRE_POLICY_CHANGE:
                launchFirePolicyAction(paramObject);
                launchNewCase(POLICY_CHANGE_CASE, paramObject, this);
                break;
            case TOOF_REINSTATEMENT:
                handleTOOF(paramObject, this);
                break;
            case LIFE_POLICY_CHANGE:
            case HEALTH_POLICY_CHANGE:
                launchWebNecho(NECHO_MAIN_TOC, paramObject);
                launchNewCase(POLICY_CHANGE_CASE, paramObject, this);
                break;
            case DSS_BEACON_REORDER:
                handleDSSBeaconReorder(this);
                break;
            case AGENT_STATUS_TRACKER:
                handleAgentStatusTracker(this);
                break;
            case PREMIUM_CHANGE_INQUIRY:
                handlePremiumChangeInquiry(this);
                break;
            case EMAIL_AUTO_ID_CARD:
                handleEmailAutoIDCard(this);
                break;
            case BILLING_ONLINE_SYSTEM:
                launchBillingOnlineSystem(this.accountContext.recordId, this.companyCode, this.policyNumber, this.lob);
                break;
            case CERTIFICATE_OF_INSURANCE:
                launchCertificateOfInsurance(this.masterDataLocationCode, this.policyNumber, this.policyTypeCode, this.lob,this.niClientId);
                break;

            // default:
            //     // should never be here
            //     break;
        }

        this.isLoading = false;
    }

    handleDetails(event) {
        this.error = null;
        this.warning = null;

        event.preventDefault();
        event.stopPropagation();

        if (this.lob === LIFE && this.isGroupPolicy) {
            throwToast(
                this,
                'NOTICE: Action Not Available',
                'Detailed view is not available for Group Life policies.',
            );
        } else {
            window.open(this.detailsURL);
        }
    }

    onCloseModal(event) {
        this.showSendModal = event.detail.showModal;
    }
    onSendEmail(event) {
        this.sendEmail = event.detail.sendEmail;
        this.accountContext.email = event.detail.userEmail;
        this.showSendModal = false;
        if (this.sendEmail === true) {
            launchEmailAutoIDCard(this.accountContext, this.riskNumber && this.riskNumber !== '000' ? this.agreementAccessKey + this.riskNumber : this.agreementAccessKey, this);

        }
    }

}

export {
    buildActionsList,
    retrievePrimaryNamedInsured,
    retrieveGroupPolicyStatus,
    retrievePLMStatus,
    handlePolicyChange,
    handleAddVehicle,
    handleTOOF,
    handleDSSBeaconReorder,
    handlePremiumChangeInquiry,
    handleAgentStatusTracker,
    handleEmailAutoIDCard,
    launchAutoPolicyAction,
    launchFirePolicyAction,
    launchWebNecho,
    launchEmailAutoIDCard,
    launchBillingOnlineSystem,
    launchCertificateOfInsurance,
    launchNewCase,
    throwToast
}