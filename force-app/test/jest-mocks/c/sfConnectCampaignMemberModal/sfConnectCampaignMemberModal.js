import { LightningElement, api, wire, track} from 'lwc';
import Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import {buildMessage} from 'c/messageServiceHelper';
import {events, campaignMessage} from 'c/campaignConstants';   
import sendSFConnectText from '@salesforce/apex/SFConnectMiddleware.getSFConnectResponse';
import createITRRecord from '@salesforce/apex/SFConnectMiddleware.createITRRecord';
import createITRRecords from '@salesforce/apex/SFConnectMiddleware.createITRRecords';
import retrieveTextTemplates from '@salesforce/apex/SFConnectMiddleware.retrieveTextTemplates';
import retrieveCampaignMembersOkToText from '@salesforce/apex/SFConnectMiddleware.retrieveCampaignMembersOkToText';
import hasBulkTextBeenTriggered from '@salesforce/apex/SFConnectMiddleware.hasBulkTextBeenTriggered';

const SUCCESS_MESSAGE = "Text message sent!";
const FAILURE_MESSAGE = "Text was not sent successfully. Please try again or contact your normal support channel.";
const BULKITRFAILURE_MESSAGE = "List of sent texts not recorded. Please open ticket to report this.";

export default class SfConnectCampaignMemberModal extends NavigationMixin(LightningElement) {
    @api campaignId;
    @api accountId;
    @api accountName;
    @api campMembId;
    @api campaignMemberBulkText;
    conductedBy = Id;
    enableSpinner;
    displayError;
    displayErrorMsg;
    textCode;
    textMessage;
    buttonDisabled = true;
    textTemplateObject = {};
    hasBulkTextBeenTriggered;
    @track dropDownOptions;

    connectedCallback(){
        retrieveTextTemplates()
            .then((data) => {
                let tempArray = [];
                for(let i = 0; i < data.length; i++){
                    this.textTemplateObject[data[i].TextCode__c] = data[i].TextMessage__c;
                    tempArray.push({
                        label: data[i].TextMessage__c,
                        value: data[i].TextCode__c
                    });
                } 
                this.dropDownOptions = tempArray;
            })
            .catch(() => {
                this.showToastEvent("", 'Error retrieving text messages. Please refresh page or contact your normal support channels.', 'error');
            });

        hasBulkTextBeenTriggered({campaignId: this.campaignId})
            .then((data) => {
                this.hasBulkTextBeenTriggered = data;
                if(this.campaignMemberBulkText && this.hasBulkTextBeenTriggered){
                    this.showToastEvent("", "Bulk text has already been triggered once. Cannot initiate another bulk text.", 'error');
                }
            })
            .catch(() => {
                this.showToastEvent("", "Error retreiving. Please contact support and do not send out texts.", 'error');
            })
    }

    @wire(MessageContext)
    messageContext;

    handleCancel() {
        this.dispatchEvent(buildCancelEvent());
    }

    handleChange(event) {
        this.textCode = event.detail.value;
        this.textMessage = this.textTemplateObject[event.detail.value];
        this.buttonDisabled = false;

        if(this.campaignMemberBulkText && this.hasBulkTextBeenTriggered){
            this.buttonDisabled = true;
        }
    }

    async handleSubmit(event) {
        this.enableSpinner = true;
        event.preventDefault();

        // Depending on if it's a bulk text or single text, the request will go down different paths.
        if(this.campaignMemberBulkText){
            let listOfITRInformation = [];
            let campaignMembersOkToText = await retrieveCampaignMembersOkToText({ campaignId: this.campaignId});
            this.showToastEvent("", 'Bulk text initiated. Please wait while texts are being sent.', 'success');

            for(let i = 0; i < campaignMembersOkToText.length; i++){
                try{
                    // eslint-disable-next-line no-await-in-loop
                    await this.makeSFConnectCall(campaignMembersOkToText[i].Id, this.textMessage);
                    this.handleSuccessEventToCampMember(campaignMembersOkToText[i].Id);
                    let itrInformationString = this.campaignId + ' ' + campaignMembersOkToText[i].Id + ' ' + campaignMembersOkToText[i].AccountId__c + ' ' + this.textCode;
                    listOfITRInformation.push(itrInformationString);
                }catch(err){
                    this.showToastEvent("", FAILURE_MESSAGE, 'error');
                }
            }

            try{
                await createITRRecords({ listOfITRInformation: listOfITRInformation});
            }catch(err){
                this.showToastEvent("", BULKITRFAILURE_MESSAGE, 'error');
            }
            
            this.enableSpinner = false;
            this.handleCancel();
        }else{ 
            try{
                await this.makeSFConnectCall(this.campMembId, this.textMessage);
                let itrInformationString = this.campaignId + ' ' + this.campMembId + ' ' + this.accountId + ' ' + this.textCode;
                await createITRRecord({ itrInformation: itrInformationString});
                this.enableSpinner = false;
                this.handleCancel();
                this.handleSuccessEventToCampMember(this.campMembId);
                this.showToastEvent("", SUCCESS_MESSAGE, 'success');
            }catch(err){
                this.enableSpinner = false;
                this.handleCancel();
                this.showToastEvent("", FAILURE_MESSAGE, 'error');
            }
        }
    }

    async makeSFConnectCall(campMembId, textMessage){
        let sfConnectResponse = await sendSFConnectText({ campaignMemberId: campMembId, textMessage: textMessage});
        if(sfConnectResponse !== 200){
            throw new Error;
        }
    }

    handleSuccessEventToCampMember(campMembId) {
        publish(this.messageContext, campaignMessage, buildMessage(events.SF_CONNECT_SUCCESS,campMembId));
    }

    showToastEvent(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}

function buildCancelEvent() {
    return new CustomEvent('cancel');
}