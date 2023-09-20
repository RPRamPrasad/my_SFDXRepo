import { LightningElement, api } from 'lwc';
import 'c/checkBrowser';

const NOTIFICATION_CHANNEL_SFCOM_KEYS = [ 'enableSFComSkype__c','enableSFComEmail__c' ];

const TEMPERATURE_KEYS = [ 'enableTempUrgent__c','enableTempHotWarm__c','enableTempColdNoTemp__c' ];

const ONLINE_BROWSING_KEY = [ 'enableOnlineBrowsing__c' ];

const NOTIFICATION_CHANNEL_ILP_KEYS = [ 'enableILPSkype__c','enableILPEmail__c' ];

export default class NotificationOptionSelection extends LightningElement {
    @api retrievedpreferences;
    notificationChannelValueSFCom = [];
    notificationChannelValueILP = [];
    temperatureValue = [];
    onlineBrowsingValue = [];

    connectedCallback() {
        this.setRetrievedPreferences(NOTIFICATION_CHANNEL_SFCOM_KEYS, this.notificationChannelValueSFCom);
        this.setRetrievedPreferences(TEMPERATURE_KEYS, this.temperatureValue);
        this.setRetrievedPreferences(ONLINE_BROWSING_KEY, this.onlineBrowsingValue);
        this.setRetrievedPreferences(NOTIFICATION_CHANNEL_ILP_KEYS, this.notificationChannelValueILP);
    }

    renderedCallback() {
        this.template.querySelector('lightning-tabset').activeTabValue = 'ilp';
        this.template.querySelector('lightning-tabset').activeTabValue = 'sfcom';
    }

    //sets values of class level properties which are used in HTML to pass values to child components (checkboxes)
    setRetrievedPreferences(preferenceValues, preferenceAttribute){
        for (let key in this.retrievedpreferences) {
            if (this.retrievedpreferences[key] === true && preferenceValues.includes(key)) {
                preferenceAttribute.push(key);
            }
        }
    }

    //used by parent to retrieve values when Save button is clicked on UI
    @api getCheckboxes() {
        let checkboxes = this.template.querySelectorAll('c-checkbox-group-reusable[data-id="sfcom"], c-checkbox-group-reusable[data-id="ilp"]');
        return checkboxes;
    }

    handleSelectAllSFCOM() {
        //iterate over the list of checkboxes and toggle each one individually for the SFCOM tab
        let checkboxes = this.template.querySelectorAll('c-checkbox-group-reusable[data-id="sfcom"]');
        checkboxes.forEach(element => {
            element.selectAllToggle();
        })
    } 

    handleSelectAllILP() {
        //iterate over the list of checkboxes and toggle each one individually for the ILP tab
        let checkboxes = this.template.querySelectorAll('c-checkbox-group-reusable[data-id="ilp"]');
        checkboxes.forEach(element => {
            element.selectAllToggle();
        })
    } 

    get selectAllOptions() {
        return [
            { label: 'Select All', value: 'selectAll' }
        ];
    }

    get notificationChannelOptionsSFCom() {
        return [
            { label: 'Teams', value: 'enableSFComSkype__c' },
            { label: 'Email', value: 'enableSFComEmail__c' }
        ];
    }

    get notificationChannelOptionsILP() {
        return [
            { label: 'Teams', value: 'enableILPSkype__c' },
            { label: 'Email', value: 'enableILPEmail__c' }
        ];
    }

    get temperatureOptions() {
        return [
            { label: 'Urgent', value: 'enableTempUrgent__c' },
            { label: 'Hot/Warm', value: 'enableTempHotWarm__c' },
            { label: 'Cold/No Temp', value: 'enableTempColdNoTemp__c' }
        ];
    }

    get onlineBrowsingOption() {
        return [
            { label: 'Online Browsing', value: 'enableOnlineBrowsing__c' }
        ];
    }
}
