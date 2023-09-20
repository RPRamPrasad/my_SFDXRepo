import {api, track, wire } from 'lwc';
import getCampaignMemberAssignedToCounts from '@salesforce/apex/CampaignAssignToController.retrieveCampaignMemberAssignedToCounts';
import getCampaignById from '@salesforce/apex/CampaignAssignToController.retrieveCampaignById';
import assignUserIdsToField from '@salesforce/apex/AssignToController.assignPipeDelimitedListOfUserIdsToField';
import { events, eventData, campaignMessage } from 'c/campaignConstants';
import { publish, MessageContext,subscribe,unsubscribe } from 'lightning/messageService';
import {buildMessage,handleSubscribe} from 'c/messageServiceHelper'
import hasCampaignAssignToEditPermission from '@salesforce/customPermission/CampaignAssignToEdit';
import LightningModal from "lightning/modal";
import { loadStyle } from 'lightning/platformResourceLoader'
import campaignStyle from '@salesforce/resourceUrl/campaignStyle';

const requiredData = [eventData.CAMPAIGN_MEMBER_MINIFIED, eventData.AGENT_OFFICE, eventData.USER];
export default class CampaignMemberBulkAssignToModal extends LightningModal {
    @wire(MessageContext)
    messageContext;
    @api recordId;
     
    @track usersToAssignTo;
    @track campaignMemberData;
    @track userData;
    @track receivedAllData = false;
    @track waitingForText = 'Waiting for Campaign Member, Agent Office and User data.';
    @track disableAssignToButton = hasCampaignAssignToEditPermission !== true;
    @track showModal;

    connectedCallbackDataRequestEventName;
    connectedCallbackDataRequestEvent;

    // renderCallBack() {
    //     loadStyle(this, CampaignMemberBulkAssignToModal);
    // }

    connectedCallback() {

        loadStyle(this, campaignStyle);
        this.connectedCallbackDataRequestEventName = `${this.recordId}_campaignmemberassigntomodal_datarequest`;
       
        subscribe(this.messageContext, campaignMessage, (message) =>{
            handleSubscribe(message,events.CAMPAIGN_MEMBER_MINIFIED_DATA_REFRESH,this.refreshCampaignMemberData.bind(this));
        });
        subscribe(this.messageContext, campaignMessage, (message) =>{
            handleSubscribe(message,events.AGENT_OFFICE_DATA_REFRESH,this.refreshAgentOfficeData.bind(this));
        });
        subscribe(this.messageContext, campaignMessage, (message) =>{
            handleSubscribe(message,events.USER_DATA_REFRESH,this.refreshUserData.bind(this));
        });
        this.requestData();
        
    }
    
    requestData() {
        const payload = {
            returnEventName: this.connectedCallbackDataRequestEventName,
            requestedData: requiredData
        };

        this.connectedCallbackDataRequestEvent = subscribe(this.messageContext, campaignMessage, (message) =>{
            handleSubscribe(message,this.connectedCallbackDataRequestEventName,this.handleDataRequestResponse.bind(this));
        });
        publish(this.messageContext, campaignMessage, buildMessage(events.DATA_REQUEST,payload));
    }

    handleDataRequestResponse(event) {
        var data = event.data
       this.usersToAssignTo = data[eventData.AGENT_OFFICE].agentOffice;
      // this.usersToAssignTo = data[eventData.AGENT_OFFICE];
        this.campaignMemberData = data[eventData.CAMPAIGN_MEMBER_MINIFIED];
        this.userData = data[eventData.USER];
        unsubscribe(this.connectedCallbackDataRequestEvent);

        this.hasReceivedAllData();
    }

    refreshCampaignMemberData(event) {
        var data= event.data;
        this.campaignMemberData = data ? JSON.parse(data) : undefined;
        this.hasReceivedAllData();
    }

    refreshAgentOfficeData(event) {
        var data = event.data;
        this.usersToAssignTo = data ? JSON.parse(data) : undefined;
        this.hasReceivedAllData();
    }

    refreshUserData(event) {
        var data= event.data;
        this.userData = data ? JSON.parse(data) : undefined;
        this.hasReceivedAllData();
    }

    hasReceivedAllData() {
        if (this.campaignMemberData && this.usersToAssignTo && this.userData) {
            this.receivedAllData = true; 
            this.waitingForText = '';
        } else {
            this.receivedAllData = false;
            
            const waitingFor = [];
            if (!this.campaignMemberData) {
                waitingFor.push('Campaign Member')
            } 

            if (!this.usersToAssignTo) {
                waitingFor.push('Agent Office');
            }

            if (!this.userData) {
                waitingFor.push('User');
            }

            let waitingForString = 'Waiting for ';
            for (let x = 0; x < waitingFor.length; x++) {
                if (x === 0) {
                    waitingForString += waitingFor[x];
                } else if (x === waitingFor.length - 1) {
                    waitingForString += ` and ${waitingFor[x]}`;
                } else {
                    waitingForString += `, ${waitingFor[x]}`;
                }
            }

            this.waitingForText = `${waitingForString} data.`;
        }
    }
 
    handleAssignmentSuccess() {
        this.updateCampaignMemberAssignedToList();
        this.close();
    }

    handleAssignmentError() {
       this.close();
    }

    handleAssignmentCancel() {
      this.close();
    }

    updateCampaignMemberAssignedToList(){
        return Promise.all(
            [
                getCampaignById( {campaignId: this.recordId}), 
                getCampaignMemberAssignedToCounts( { campaignId: this.recordId})
            ])
        .then(([campaign, assignToCounts]) => {
 
            const fullUserRecordCount = buildFullUserRecordCounts(assignToCounts);

            assignUserIdsToField(
                {
                    wrap: {
                        theSObject: campaign,
                        assignListFieldId: 'CampaignMembersAssignedToList__c',
                        assignListFieldName: 'Assigned_to_Campaign__c',
                        userRecordCounts: fullUserRecordCount
                    }
                })
                .then(() => {
                    const message = buildMessage(events.CAMPAIGN_MEMBER_BULK_ASSIGNMENT,this.recordId)
                    publish(this.messageContext, campaignMessage, message);
                });
        })
    }
}

function buildFullUserRecordCounts(data) {
    const userRecordCounts = [];
    data.filter(item => item.Id).forEach(element => {
        userRecordCounts.push({
            userId: element.Id,
            userFullName: element.Name,
            numberOfRecordsToAssign: element.RecordCount
        });
    });

    return userRecordCounts;
}