/****************************************************************************************
Name: journeyOptIn.js
=========================================================================================
* description : This LWC allows agents to select their preferred preferences
                for specific Marketing Cloud Journeys.
Team: Incognito
=========================================================================================
VERSION    AUTHOR               DATE           DETAIL
1.0        ClubCar              12/01/2020     Initial development
2.0        ClubCar              1/12/2021      Adding functionality to save a monthly
                                               budget amount with a preference
3.0        Incognito            9/29/2022      Fixing bug where Journeys did not appear
                                               in order         
4.0        Incognito                           Name, Role, Value accessibilty defect fixes
5.0        Incognito            12/20/2022     Modal trap defect(create new modal)                         
******************************************************************************************/

import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import recordCreationOrUpdating from '@salesforce/apex/JourneyOptInAddRecord.addOrUpdateRecord';
import retrieveJourneys from '@salesforce/apex/JourneyOptInAddRecord.getOptInRecords';
import getCustomMetaData from '@salesforce/apex/JourneyOptInAddRecord.getCustomMetaData';
import hasJourneyOptInPermission from '@salesforce/customPermission/JourneyOptInAccess';

const columns = [
    { label: `Journey`, fieldName: `journeyName` },
    { label: `Opt-In`, fieldName: `optIn` },
];
const optInConstants = {
    type: 'Journey Name',
    preference: 'Opt-In Preference',
    confirmation: 'Please review the above table to verify your selection(s) are correct. Click SUBMIT to confirm that the selection made is correct and save your preference.',
}

export default class JourneyOptIn extends LightningElement {
    // This array will be populated by Custom Metadata in the contructJourneysInProperFormat function 
    @track
    journeys;

    connectedCallback() {
        this.retrieveCustomMetaData();
        document.addEventListener("keydown", this.handleEscapeKey.bind(this));
    }
    handleEscapeKey(event) {
        if ((event.key === 'Escape' || event.keyCode === 27)) {
            this.hideModalBox();
        }
    }

    retrieveCurrentPreferences() {
        retrieveJourneys({ agentUserID: USER_ID }).then(data => {
            data.forEach(el => {
                for (let i = 0; i < this.journeys.length; i++) {
                    if (el.Journey_Name__c === this.formatJourneyPreferenceName(this.journeys[i].Name.split(' '))) {
                        if (el.Journey_Preference__c === true) {
                            this.whenYesButtonClicked(i);
                        } else {
                            this.whenNoButtonClicked(i);
                        }
                    }
                }
            });
        })
            .catch(() => {
                //Show toast message instead
                this.showNotification("", 'Error retrieving your current preferences.', "error");
            });
    }

    retrieveCustomMetaData() {
        getCustomMetaData().then((data) => {
            this.contructJourneysInProperFormat(data);
        }).catch(() => {
            this.showNotification("", 'Error retrieving current Journeys available for selection. Please try to refresh page or contact your normal support channels.', "error");
        });
    }

    contructJourneysInProperFormat(customMetaDataRetrieved) {
        let journeys = [];
        customMetaDataRetrieved.forEach((journey) => {
            let newJourneyObject = {};
            newJourneyObject.Id = journey.JourneyId__c;
            newJourneyObject.Name = journey.MasterLabel;
            newJourneyObject.Link = journey.Link__c;
            newJourneyObject.HelpText = journey.HelpText__c;
            newJourneyObject.VariantYes = 'Neutral';
            newJourneyObject.VariantNo = 'Neutral';
            newJourneyObject.TitleYes = journey.TitleYes__c;
            newJourneyObject.TitleNo = journey.TitleNo__c;
            newJourneyObject.DisplaySave = false;
            newJourneyObject.OptIn = '';
            journeys.push(newJourneyObject);
        });

        let sortedJourneys = journeys.sort((a, b) => {
            return a.Id - b.Id;
        });

        this.journeys = sortedJourneys;
        this.retrieveCurrentPreferences();
    }

    data = [];
    optInConstants = optInConstants;
    columns = columns;
    displayModal;
    tierLevel;
    displaySave;

    get isJourneyOptInPermissionEnabled() {
        return !hasJourneyOptInPermission;
    }

    //These handlers are changing the color or what button user selects
    handleYesClickOnRadioButtons(event) {
        this.journeys.forEach((el) => {
            if (el.TitleYes === event.target.title) {
                this.whenYesButtonClicked(el.Id - 1);
                this.displaySaveButton();
                this.template.querySelector(`[data-id="` + el.TitleYes + `"]`).ariaPressed = true;
            }
        });
    }

    handleNoClickOnRadioButtons(event) {
        this.journeys.forEach((el) => {
            if (el.TitleNo === event.target.title) {
                this.whenNoButtonClicked(el.Id - 1);
                this.displaySaveButton();
                this.template.querySelector(`[data-id="` + el.TitleNo + `"]`).ariaPressed = true;
            }
        });
    }

    //These two are actually changing the property of the preference selected
    whenYesButtonClicked(journeyIndex) {
        this.journeys[journeyIndex].VariantYes = 'brand';
        this.journeys[journeyIndex].VariantNo = 'Neutral';
        this.journeys[journeyIndex].DisplaySave = true;
        this.template.querySelector(`[data-id="` + this.journeys[journeyIndex].TitleYes + `"]`).ariaPressed = true;
        this.template.querySelector(`[data-id="` + this.journeys[journeyIndex].TitleNo + `"]`).ariaPressed = false;
    }
    whenNoButtonClicked(journeyIndex) {
        this.journeys[journeyIndex].VariantYes = 'Neutral';
        this.journeys[journeyIndex].VariantNo = 'brand';
        this.journeys[journeyIndex].DisplaySave = true;
        this.template.querySelector(`[data-id="` + this.journeys[journeyIndex].TitleNo + `"]`).ariaPressed = true;
        this.template.querySelector(`[data-id="` + this.journeys[journeyIndex].TitleYes + `"]`).ariaPressed = false;
    }

    displaySaveButton() {
        let displaySaveResults = this.journeys.map(el => el.DisplaySave);
        let counter = 0;
        displaySaveResults.forEach((el) => {
            if (el === true) {
                counter++;
            }
        });

        // && this.tierLevel
        if (counter === this.journeys.length) {
            this.displaySave = true;
        }//else{
        //  this.displaySave = false; // this is redundant code since the default value is false.
        // }
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    addJourneyDataToDataTable() {
        this.data = [];
        for (let i = 0; i < this.journeys.length; i++) {
            let journeyObject = {};
            journeyObject.id = this.journeys[i].Id;
            journeyObject.journeyName = this.journeys[i].Name;
            journeyObject.optIn = this.journeys[i].OptIn;
            this.data.push(journeyObject);
        }
    }

    clearValues() {
        //  window.console.log('this is journey'+JSON.stringify(this.journeys));
        for (let el of this.journeys) {
            el.VariantNo = 'Neutral';
            el.VariantYes = 'Neutral';
            el.DisplaySave = false;
        }
        //this.displayModal = false; // displayModal is not used in the html template
        this.displaySave = false;
    }

    renderedCallback() {
        let modalDiv = this.template.querySelector("button[data-modal-id = closeIconFocus]");
        if (modalDiv) {
            modalDiv.focus();
            this.trapModalFocus();
        }
    }

    trapModalFocus() {
        let modal = this.template.querySelector('.autoModalFocus');
        // add all the elements inside modal which you want to make focusable
        const focusableElements = 'button, a, input, select, textarea, [tabindex]:not([tabindex="-1"])';
        const focusableContent = modal.querySelectorAll(focusableElements);
        const firstFocusableElement = modal.querySelectorAll(focusableElements)[0]; // get first element to be focused inside modal
        const lastFocusableElement = focusableContent[focusableContent.length - 1]; // get last element to be focused inside modal

        firstFocusableElement.addEventListener(`keydown`, (event) => { this.lastFocusTrapper(event, lastFocusableElement) });
        lastFocusableElement.addEventListener(`keydown`, (event) => { this.firstFocusTrapper(event, firstFocusableElement) });
    }

    // eslint-disable-next-line no-unused-vars
    firstFocusTrapper(event, firstFocusableElement) {
        let isTabPressed = event.key === `Tab` || event.keyCode === 9;
        if (isTabPressed && !event.shiftKey) { // if tab key is pressed
            firstFocusableElement.focus(); // add focus for the first focusable element
            event.preventDefault();
        }
    }

    lastFocusTrapper(event, lastFocusableElement) {
        let isTabPressed = event.key === `Tab` || event.keyCode === 9;
        if (event.shiftKey && isTabPressed) { // if shift key pressed for shift + tab combiination
            lastFocusableElement.focus(); // add focus for the last focusable element
            event.preventDefault();
        }
    }


    save() {
        for (let i = 0; i < this.journeys.length; i++) {
            if (this.journeys[i].VariantYes === 'brand') {
                this.journeys[i].OptIn = 'Yes';
            } else {
                this.journeys[i].OptIn = 'No';
            }
        }
        this.addJourneyDataToDataTable();
        //this.showModal();
        this.showModalBox();

    }


    // findModal() {
    //     return this.template.querySelector("c-modal[data-id='journeyOptInConfirmation']");
    // }

    // showModal() {
    //     this.findModal().show();
    // }

    // closeModal() {
    //     this.findModal().hide();
    // }

    @track isShowModal = false;

    showModalBox() {
        this.isShowModal = true;
    }
    hideModalBox() {
        this.isShowModal = false;
    }

    onOptInPreferenceSubmission() {
        this.createMCPreferenceRecords();
        this.clearValues();
        //this.closeModal();
        this.hideModalBox();
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => this.retrieveCurrentPreferences(), 2000);
    }

    formatJourneyPreferenceName = (journeyName) => {
        let formattedJourneyName = '';
        for (let i = 0; i < journeyName.length; i++) {
            formattedJourneyName += journeyName[i];
            if (i !== journeyName.length - 1) {
                formattedJourneyName += '_';
            }
        }
        return formattedJourneyName;
    }

    createMCPreferenceRecords() {
        this.journeys.forEach((el) => {
            let preferences = '';
            preferences += this.formatJourneyPreferenceName(el.Name.split(' ')) + ' ';
            preferences += el.OptIn + ' ';
            preferences += USER_ID;

            recordCreationOrUpdating({ optInSelections: preferences }).then(() => {
                this.showNotification("", 'Your preferences were saved.', "success");
            })
                .catch(() => {
                    this.showNotification("", 'Error saving preferences. Please try again or contact your normal support channels.', "error");
                });
        });
    }
}