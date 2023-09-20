import { LightningElement, api, wire } from 'lwc';
import { getPageByPageId, getPageByErrorCode } from './modalBodies';


import { DSS_INACTIVE_ERROR_CODE, NO_ENROLLMENT_DATE_ERROR_CODE, INCORRECT_PRODUCT_CODE_ERROR_CODE, BEACON_SHIPPED_ERROR_CODE,CCC_BEACON_SHIPPED_ERROR_CODE, REORDER_REASONS,REORDER_REASONS_CCC,TECHNICAL_ERROR_CODE,CCC_TECHNICAL_ERROR_CODE} from './constants';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext
} from 'lightning/messageService';
import dssTelematicsData from '@salesforce/messageChannel/dss_case__c';

import createSupportCase from '@salesforce/apex/DssBeaconReorderController.createSupportCase';
import mrsfServiceCall from '@salesforce/apex/DssBeaconReorderController.mrsfServiceCall';
import shipmentServiceCall from '@salesforce/apex/DssBeaconReorderController.shipmentServiceCall';
import { getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import SUBUSERTYPE from '@salesforce/schema/User.SubUserType__c';

export default class DssBeaconReorder extends LightningElement {
    // Variables from IP Record Page
    @api customerStreet;
    @api customerCity;
    @api customerState;
    @api customerZip;
    @api customerClientId;
    @api customerFirstName;
    @api customerLastName;
    @api accountName;
    @api policyNumber;
    @api agreementAccessKey;
    @api productDescription;
    @api sourceSystemCode;
    @api accountId;
    
    _currentPageNumber = null;
    previousPageNumber = null;
    modalIsOpen = false;
    shouldShowErrorScreen;
    currentBodyText;
    shouldShowPreviousButton;
    shouldShowContinueButton;
    shouldShowSubmitButton;
    shouldShowReorderReasons;
    shouldShowYesNoButtons;
    selectedReorderReason;
    shouldShowAddressInfo;
    shouldShowReqSupportButton;
    reorderReasons;
    loggedInSubUserType;
    submissionObject = {};
    isSaving = false;
    
    // data fetch variables
    dataHasReturned;
    _mrsfData = {};
    _dvApiData = {};
    shipmentOrderStatus;
    
     getCustomePageBody(accountRecordId,pageNumber){
        let htmlBody="";

        if (pageNumber === 100  ){
            htmlBody = `<p>This workflow is unavailable. To continue to process your request, please follow the beacon reorder process using the <a href="/apex/VFP_ExternalLink?LinkId=215&accountId=${accountRecordId}" target="_blank" data-id="popDSSLink">Drive Safe & Save Beacon Reorder tool</a> in ECRM. Refer to procedural resources to confirm process and beacon eligibility.</p>`;
        } else if (pageNumber === 101){
            htmlBody = `<p>A beacon has been shipped in the last 10 days. Please confirm shipping status inside the Drive Safe & Save Beacon Status tool and verify the customer still needs a beacon sent. If one is needed, then follow the beacon reorder process using the <a href="/apex/VFP_ExternalLink?LinkId=215&accountId=${accountRecordId}" target="_blank" data-id="popDSSLink">Drive Safe & Save Beacon Reorder tool</a> in ECRM.</p>` ;
        }
        return htmlBody;
     }

    // @api decorator is only needed until connections are in place to set this value properly
    get mrsfData() { return this._mrsfData }
    set mrsfData(value) {
        this._mrsfData = value;
        this.dataHasReturned = true;
    }

    get dvApiData() { return this._dvApiData }
    set dvApiData(value) {
        this._dvApiData = value;
        this.dataHasReturned = true;
        this.mrsfData = {};
        if(this.modalIsOpen === true) {
            this.mrsfServiceCall(this.dvApiData.tc_id,this.dvApiData.telematicsEnrollmentIdentifier);
            
        }
    }

    @wire(MessageContext)
    messageContext;

    subscribeToDSScaseMessageChannel() {
        //this.cccErrorPage100Body = this.getcccErrorPage100Body("clientid");
        this.dsscaseSubscription = subscribe(
            this.messageContext,
            dssTelematicsData,
            async(message) => {   
                if(this.agreementAccessKey === message.agreementAccessKey) {  
                    this.dvApiData = {
                        tc_id: message?.tc_id,
                        telematicsEnrollmentIdentifier: message?.telematicsEnrollmentIdentifier,
                        telematicsServiceProductCode: message?.telematicsServiceProductCode,
                        telematicsEnrollmentCompletionDate: message?.telematicsEnrollmentCompletionDate,
                        physicalObjectSerialNumber: message?.physicalObjectSerialNumber
                    };
                }
            }, { scope: APPLICATION_SCOPE }
        );
    }

    unsubscribeToDSSCaseMessageChannel() {
        unsubscribe(this.dsscaseSubscription);
        this.dsscaseSubscription = null;
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [
            SUBUSERTYPE
        ]
    })
    getUserRecordData(result) {
        if (result.data) {
            if (result.data.fields.SubUserType__c.value) {
                this.loggedInSubUserType = result.data.fields.SubUserType__c.value.toUpperCase();
                if((this.loggedInSubUserType === 'CCC SALES') || (this.loggedInSubUserType === 'CCC SERVICE')){
                    this.reorderReasons = REORDER_REASONS_CCC;
                }
                else {
                    this.reorderReasons = REORDER_REASONS;
                }
            }
            else { //SubUserType__c null
                this.showToast('Unable to load policy action buttons', 'Error', "User record details incomplete. Please contact support for assistance.");
            }
        }
    }

      

      

    get currentPageNumber() { return this._currentPageNumber }
    set currentPageNumber(value) {
        const pageDetails = getPageByPageId(value);
        this._currentPageNumber = value;
        this.currentBodyText = pageDetails.bodyHTML;
        //custom logic for dynamic html
        if (value === 100 || value === 101 ){
            this.currentBodyText = this.getCustomePageBody(this.accountId,value);
        } 

        this.shouldShowPreviousButton = pageDetails.showPrevious;
        this.shouldShowContinueButton = pageDetails.showContinue;
        this.shouldShowSubmitButton = pageDetails.showSubmit;
        this.shouldShowErrorScreen = pageDetails.errorPage;
        this.shouldShowReorderReasons = pageDetails.showReasons;
        this.shouldShowYesNoButtons = pageDetails.showYesNo;
        this.shouldShowAddressInfo = pageDetails.showAddress;
        this.spinnerPage = pageDetails.showSpinner;
        this.shouldShowReqSupportButton = pageDetails.showReqSupport;
    }

    get shouldDisableContinueButton() {
        return this.currentPageNumber === 2 && !this.selectedReorderReason;
    }

    get shouldShowSpinner() {
        return this.spinnerPage && ((Object.keys(this.dvApiData).length === 0 || Object.keys(this.mrsfData).length === 0) || this.isSaving);
    }

    get shouldShowAddress() {
        return this.shouldShowAddressInfo && !this.shouldShowSpinner;
    }

    connectedCallback() {
        this.currentPageNumber = 0;
        this.subscribeToDSScaseMessageChannel();
    }

     //mrsf service call
     mrsfServiceCall(tcId,enrollmentId) {         
        let mrsfDataObj ={};         

         if (tcId || enrollmentId){ 
            mrsfServiceCall({
                tcId:tcId,
                enrollmentId:enrollmentId
            }).then((result) => {                                             
                if(result){
                    mrsfDataObj= JSON.parse((result));  
                           
                    this.mrsfData = {
                        lastShipDate : mrsfDataObj?.LastShipDate,
                        lastOrderStatus : mrsfDataObj?.LastOrderStatus,
                        isSuccess : true
                    }

                    if (this.mrsfData.lastShipDate){
                        let todayDate = new Date().toISOString().split("T")[0];
                        let lastShipDate = new Date(this.mrsfData.lastShipDate).toISOString().split("T")[0];
                        const msPerDay = 1000*60*60*24;
                        this.mrsfData = {
                            lastShipDateInDays : (new Date(todayDate) - new Date(lastShipDate))/msPerDay,
                            lastOrderStatus : this.mrsfData.lastOrderStatus,
                            isSuccess : true
                        }
                     
                    }
                }
                else {                 
                    this.mrsfData = { isSuccess : false }
                }  
            });
        } else {
            this.mrsfData = { notCalled: true };
        }
     }

     //shipment Service Call
    async callShipmentAPI(shipmentObject) {  
        let result = await shipmentServiceCall({shipmentOrder : shipmentObject});
        if (result === "Success"){
            this.showToast('Success', 'Success', "Your Drive Safe & Save™ beacon request has been submitted! The Customer will be notified once it is shipped.");
            this.toggleModal();
        } else {
            if((this.loggedInSubUserType === 'CCC SALES') || (this.loggedInSubUserType === 'CCC SERVICE')){
                this.currentPageNumber = getPageByErrorCode(CCC_TECHNICAL_ERROR_CODE);
            }
            else {
                this.currentPageNumber = getPageByErrorCode(TECHNICAL_ERROR_CODE);               
            }
        }
     }


    @api toggleModal() {
        const modal = this.template.querySelector('[data-id="beacon-modal"]').classList;
        const backdrop = this.template.querySelector('[data-id="modal-backdrop"]').classList;
        modal.toggle('slds-fade-in-open');
        backdrop.toggle('slds-backdrop_open');
        if(this.modalIsOpen === true) {
            this.currentPageNumber = 0;
        } else {
            if(Object.keys(this.mrsfData).length === 0 && Object.keys(this.dvApiData).length > 0) {
                this.mrsfServiceCall(this.dvApiData.tc_id,this.dvApiData.telematicsEnrollmentIdentifier);
            } else if (Object.keys(this.mrsfData).length > 0) {
                this.dataHasReturned = true;
            }
        }
        this.modalIsOpen = !this.modalIsOpen;
    }

    @api goToNextPage() {
        if (this.dataHasReturned) {
            this.currentPageNumber = this.evaluateDataToProceed(this.currentPageNumber + 1);
        } else {
            this.previousPageNumber = this.currentPageNumber;
            this.currentPageNumber += 1;
        }
    }

    @api goToReasonsPage() {
        if (this.dataHasReturned) {
            this.currentPageNumber = this.evaluateDataToProceed(2);
        } else {
            this.previousPageNumber = this.currentPageNumber;
            this.currentPageNumber = 2;
        }
    }

    @api goToPreviousPage() {
        if (this.dataHasReturned) {
            this.currentPageNumber = this.evaluateDataToProceed(this.currentPageNumber - 1);
            this.previousPageNumber = null;
        } else {
            if (this.previousPageNumber !== null) {
                this.currentPageNumber = this.previousPageNumber;
                this.previousPageNumber = null;
            } else {
                this.currentPageNumber -= 1;
            }
        }
    }

    evaluateDataToProceed(pageToChangeTo) {
        let pageToTurnTo = pageToChangeTo;
        this.previousPageNumber = this.currentPageNumber;
        if (this.dataHasReturned && Object.keys(this.dvApiData).length > 0) {
            pageToTurnTo = this.evaluateDVApiData(pageToTurnTo);
        }
        if (this.dataHasReturned && Object.keys(this.mrsfData).length > 0) {         
            pageToTurnTo = this.evaluateMrsfShipDate(pageToTurnTo);
        }
        this.dataHasReturned = false;
        return pageToTurnTo;
    }

    evaluateMrsfShipDate(pageToChangeTo) {
        let pageToTurnTo = pageToChangeTo;
        if(this.mrsfData.notCalled) {
            return pageToTurnTo;
        }
        if(!this.mrsfData.isSuccess){
            if((this.loggedInSubUserType === 'CCC SALES') || (this.loggedInSubUserType === 'CCC SERVICE')){
                pageToTurnTo = getPageByErrorCode(CCC_TECHNICAL_ERROR_CODE);            
            }
            else{
            pageToTurnTo = getPageByErrorCode(TECHNICAL_ERROR_CODE);          
            }
        }
        if (this.mrsfData?.lastShipDateInDays < 10 || this.mrsfData?.lastOrderStatus === 'Processing Shipment' || this.mrsfData?.lastOrderStatus === 'Order Submitted'){
            if((this.loggedInSubUserType === 'CCC SALES') || (this.loggedInSubUserType === 'CCC SERVICE')){
                pageToTurnTo = getPageByErrorCode(CCC_BEACON_SHIPPED_ERROR_CODE);               
            }
            else{
            pageToTurnTo = getPageByErrorCode(BEACON_SHIPPED_ERROR_CODE);          
            }
       }
        return pageToTurnTo;
    }

    evaluateDVApiData(pageToTurnTo) {
        if((this.sourceSystemCode === 24 && !this.dvApiData.telematicsEnrollmentIdentifier) || (this.sourceSystemCode !== 24 && !this.dvApiData.tc_id)) {
            // policy without telematics data; dss not active         
            return getPageByErrorCode(DSS_INACTIVE_ERROR_CODE);
        } else if(this.sourceSystemCode === 24 && !this.dvApiData.telematicsEnrollmentCompletionDate) {
            // mod policy without enrollment completion date          
            return getPageByErrorCode(NO_ENROLLMENT_DATE_ERROR_CODE);
        }
        if(this.dvApiData.telematicsServiceProductCode !== '09') {
            // incorrect DSS policy code         
            return getPageByErrorCode(INCORRECT_PRODUCT_CODE_ERROR_CODE);
        }
        return pageToTurnTo;
    }

    handleRadioChange(event) {
        this.selectedReorderReason = event.detail.value;
    }

    @api handleSubmit() {
        let dataShouldPreventSubmission = this.currentPageNumber;
        if (this.dataHasReturned) {
            dataShouldPreventSubmission = this.evaluateDataToProceed(this.currentPageNumber);
        }
        if (dataShouldPreventSubmission === this.currentPageNumber) {
            let submissionObject = {
                clientId: this.customerClientId,
                firstName: this.customerFirstName,
                lastName: this.customerLastName,
                address1: this.customerStreet,
                postalState: this.customerState,
                postalCode: this.customerZip,
                postalCity: this.customerCity,
                tempAddressIndicator: false,
                telemeterOrderReason: this.selectedReorderReason,
                addSourceIdentifier: 'ECRM',
                itemModelNumber: 'Bluetooth Device'
            }
            if(this.sourceSystemCode === 24) {
                submissionObject.enrollmentId = this.dvApiData.telematicsEnrollmentIdentifier;
            } else {
                submissionObject.tc_id = this.dvApiData.tc_id; //null;
            }
            this.isSaving = true;
            this.callShipmentAPI(submissionObject).then(() => { this.isSaving = false });
        } else {
            this.currentPageNumber = dataShouldPreventSubmission;
        }
    }

    @api createSupportCase() {
        const reasonRegex = /(<([^>]+)>)/g;
        const errorReasonNoHtml = this.currentBodyText.replace(reasonRegex, '');
        const params = {
            policyNumber: this.policyNumber,
            clientId: this.customerClientId,
            clientName: this.accountName,
            productDescription: this.productDescription,
            vin: this.dvApiData?.physicalObjectSerialNumber,
            errorDescription: errorReasonNoHtml
        };
        this.isSaving = true;
        createSupportCase({ uiParams: params }).then(caseNumber => {
            this.isSaving = false;
            let message, title, variant;
            if(caseNumber) {
                title = 'Successfully Created Support Case';
                message = 'Case #' + caseNumber + ' has been created for this request.';
                variant = 'success';
                this.toggleModal();
            } else {
                title = 'Something went wrong';
                message = 'A support case could not be created for this request. Please contact your normal support channels for assistance.';
                variant = 'error';
            }
            this.showToast(title, variant, message);
        });
    }

    showToast(title, type, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            variant: type,
            message: message
        })
        this.dispatchEvent(toastEvent);
    }

    disconnectedCallback() {
        this.unsubscribeToDSSCaseMessageChannel();
    }




}
