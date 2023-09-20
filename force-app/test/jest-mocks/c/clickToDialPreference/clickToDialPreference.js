import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import queryLoggedInUserClickToDialPreference from "@salesforce/apex/ClickToDialPreferenceController.getLoggedInUserClickToDialPreference";
import updateClickToDialPreference from "@salesforce/apex/ClickToDialPreferenceController.updateClickToDialPreference";

export default class ClickToDialPreference extends LightningElement {
    displaySpinner = false;
    displayClickToDialPreference = false;
    displayNoClickToDialEnabled = false;
    defaultPreferenceOption1 = false;
    defaultPreferenceOption2 = false;
    isSaveButtonDisabled = true;
    selectedClickToDialPreference;

    connectedCallback() {
        this.handleInitialClickToDialPreference();
    }

    handleInitialClickToDialPreference() {
        this.showSpinner();
        queryLoggedInUserClickToDialPreference()
        .then((data) => {
            if (data.ClickToDialEnabled__c) {
                this.displayClickToDialPreference = true;
                this.selectedClickToDialPreference = data.ClicktoDialPreference__c;
                this.setDefaultPreferenceOptions(data.ClicktoDialPreference__c);
            } else {
                this.displayNoClickToDialEnabled = true;
            }
            this.hideSpinner();
        })
        // eslint-disable-next-line no-unused-vars
        .catch((error) => {
            this.hideSpinner();
            this.displayErrorMessage = true;
        });
    }

    handleSelectedClickToDialPreferences(event) {
        this.selectedClickToDialPreference = event.target.value;
        this.setDefaultPreferenceOptions(event.target.value);
    }

    setDefaultPreferenceOptions(clickToDialPreferenceValue) {
        if (clickToDialPreferenceValue !== undefined) {
            this.isSaveButtonDisabled = false;
        }
        this.defaultPreferenceOption1 = false;
        this.defaultPreferenceOption2 = false;
        if (clickToDialPreferenceValue === "11")
            this.defaultPreferenceOption1 = true;
        if (clickToDialPreferenceValue === "10")
            this.defaultPreferenceOption2 = true;
    }

    handleSaveClickToDialPreference() {
        this.showSpinner();
        updateClickToDialPreference({ preferenceValue: this.selectedClickToDialPreference})
        .then((data) => {
            if (data) {
                this.showNotification("", "Click To Dial Preference was saved.", "success");
            } else {
                this.fireUpdateErrorMessage();
            }
            this.hideSpinner();
        })
        // eslint-disable-next-line no-unused-vars
        .catch((error) => {
            this.hideSpinner();
            this.fireUpdateErrorMessage();
        });
    }

    fireUpdateErrorMessage() {
        this.dispatchEvent(new ShowToastEvent({
            title: "There was an error saving your preferences.",
            message: "Please contact your normal support channel for assistance.", variant: "error"
        }));
    }

    showNotification(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({ title: title, message: msg, variant: variant }));
    }

    showSpinner() {
        this.displaySpinner = true;
    }

    hideSpinner() {
        this.displaySpinner = false;
    }
}
