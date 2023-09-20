import { LightningElement, api, wire } from 'lwc';
import retrieveSObjects from '@salesforce/apex/SObjectRetrieveController.retrieveSObjectsNotCacheable';
import { subscribe, MessageContext } from 'lightning/messageService';
import { handleSubscribe } from 'c/messageServiceHelper'
import { publish } from 'lightning/messageService';
import { buildMessage } from 'c/messageServiceHelper'
import { events, campaignMessage } from 'c/campaignConstants';
import isSalesLeaderUser from '@salesforce/customPermission/SalesLeader_User';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const NO_ACCESS_ERROR_MSG = 'This functionality is not available for your profile.';

export default class CampaignStartStopJourneyButton extends LightningElement {
    @wire(MessageContext)
    messageContext

    @api recordId;
    @api objectApiName;
    journeyRequest;
    buttonName;
    recType;
    RecordType;
    isRecordTypeService = false;


    connectedCallback() {


        subscribe(this.messageContext, campaignMessage, (message) => {
            handleSubscribe(message, events.JOURNEY_STARTED, this.refreshData.bind(this));
        });
        subscribe(this.messageContext, campaignMessage, (message) => {
            handleSubscribe(message, events.JOURNEY_STOPPED, this.refreshData.bind(this));
        });
        this.refreshData();

    }

    refreshData() {
        this.journeyRequest = buildRequest({ recordId: this.recordId, objectApiName: this.objectApiName });
        this.retrieveSObjects();


    }

    showToastEvent(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    handleStartStopJourneyModal() {
        if (isSalesLeaderUser) {
            this.showToastEvent("", NO_ACCESS_ERROR_MSG, "error");
        } else {
            publish(this.messageContext, campaignMessage, buildMessage(events.START_STOP_JOURNEY, this.recordId));
        }
    }



    retrieveSObjects() {
        retrieveSObjects({ request: this.journeyRequest })
            .then(result => {
                if (result.sobjects[0].Journey_ID__c) {
                    this.buttonName = 'Stop Journey';
                } else {
                    this.buttonName = 'Start Journey';
                }

                this.recType = result.sobjects[0].RecordType.DeveloperName;

                if (this.recType === 'Service') {
                    this.isRecordTypeService = true;

                }


            })
    }

}
function buildRequest(data) {
    return {
        sobjectName: data.objectApiName,
        fieldNames: ['Journey_ID__c', 'RecordType.DeveloperName'],
        filterCriteriaIn: [
            {
                enable: true,
                filterType: 'LIST_OF_STRING',
                filterFieldName: 'ID',
                queryNullValues: false,
                filterValues: [data.recordId]
            }
        ],
        queryLimit: 1
    };

}
