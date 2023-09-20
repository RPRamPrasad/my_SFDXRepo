import { LightningElement, api } from 'lwc';
import {getEventName} from './eventName'
import { getActionButtonDetails,getDropdownOptions} from './actionItems'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasAgencyUserPermission from '@salesforce/customPermission/Agency_User'

const MODAL_EVENTS = ['newlogforcampaignmember','quickopportunitycreate','convertleadcampaignmember','simpleconvforcampaignmember','goodneighborconnectforcampaignmember','newcaseforcampaignmember','removeleadcampaignmember'];
export default class CampaignMemberActions extends LightningElement {

    @api campaignMemberId;
    @api leadId;
    @api campaignMemberName;
    @api campaignMemberStatus
    @api campaignMemberEmail;
    @api campaignMemberSendText;
    @api campaignId;
    @api accountId;

    actionButtonId;
    actionButtonLabel;
    dropdownDisplayOptions;
    showButton;

    @api
    get buttonOption(){
        return this.buttonOptionHolder;
    }
    set buttonOption(value){
        var options = getActionButtonDetails(value);
        if(options !== undefined){
            this.actionButtonId = options.id;
            this.actionButtonLabel = options.label;
            this.buttonOptionHolder = value;
            this.showButton = true;
        }
    }

    @api
    get dropdownOptions(){
        return this.dropdownOptionsHolder;
    }
    set dropdownOptions(value){
        this.dropdownDisplayOptions = getDropdownOptions(value,this.campaignMemberStatus,this.campaignMemberEmail,this.campaignMemberSendText);
        this.dropdownOptionsHolder = value;
    }
   
    handleDropdownItem(event){
        this.handleEvent(event);
    }

    handleActionButtonClick(event){
        this.handleEvent(event);
    }
    handleEvent(event){
        const eventName = getEventName(event.target.id);

        //If user has agency user permission OR (user doesn't have agency user permission but the action is a non-modal event), then dispatch; else display toast message
        if(hasAgencyUserPermission) {
          this.dispatchBubblingEvent(eventName);  
        
        } else if (MODAL_EVENTS.includes(eventName)) {
            this.dispatchBubblingEvent(eventName);
        
          } else {
            const evt = new ShowToastEvent({
              title: undefined,
              message: `Support user does not have authority use action '${event.target.label}'`,
              variant: 'error'
            });
            this.dispatchEvent(evt);
      }
    }

    dispatchBubblingEvent(eventName) {
        const customEvent = new CustomEvent(eventName, {
            bubbles: true,
            composed: true,
            cancelable: false,
            detail: {
                accountId: this.accountId,
                campaignMemberId: this.campaignMemberId,
                leadId: this.leadId,
                campaignMemberStatus: this.campaignMemberStatus,
                campaignMemberName: this.campaignMemberName,
                campaignMemberEmail: this.campaignMemberEmail,
                campaignMemberSendText: this.campaignMemberSendText,
                campaignId: this.campaignId
            }
        });
        this.dispatchEvent(customEvent);
    }

}