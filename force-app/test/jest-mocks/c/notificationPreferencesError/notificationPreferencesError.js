import { LightningElement,api } from 'lwc';
import 'c/checkBrowser';

export default class NotificationPreferencesError extends LightningElement {

    // values given from parent
    @api isNotInNewHotProspectGroup;  
    
    @api newHotProspectGroupName; 

    @api newHotProspectGroupURL;

    @api noNewHotProspectGroupFound;

    @api unhandlederror;

    @api allChatterNotificationsDisabled;

    @api allChatterMentionsDisabled;
}