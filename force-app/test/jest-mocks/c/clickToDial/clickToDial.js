import { LightningElement, api } from 'lwc';
import retrieveUserPreferences from '@salesforce/apex/ClickToDialController.retrieveUserPreferences';
import { formatPhoneNumberForUserPreference, USER_DIAL_PREFERENCE } from './utilities/phoneNumberFormat';
import { getBaseUrl } from './utilities/baseUrl';

export const DISPLAY_TYPE = {
    default: 'default',
    minimal: 'minimal'
};

const CALL_FAILED_PREFERENCE = {
    clickToDialPreference: USER_DIAL_PREFERENCE.elevenDigits
}

export default class ClickToDial extends LightningElement {
    
    @api displayType = DISPLAY_TYPE.default;
    @api isDoNotMarket;
    @api phoneNumber;
    @api metaData;
    @api isDoNotCall;

    @api overrideUserPreferences = false;
    @api theme;
    @api clickToDialEnabled = false;
    @api clickToDialPreference = USER_DIAL_PREFERENCE.elevenDigits;
    
    userPreference;
    baseUrl;

    async connectedCallback() {
        if (!this.overrideUserPreferences) {
            this.userPreference = await retrieveUserPreferences()
        } else {
            this.userPreference = {
                clickToDialEnabled: this.clickToDialEnabled,
                clickToDialPreference: this.clickToDialPreference,
                theme: this.theme
            };
        }

        this.baseUrl = getBaseUrl(this.userPreference.theme);
    }

    get enabled() {
        return this.userPreference.clickToDialEnabled;
    }

    get displayDefaultVersion() {
        return this.displayType === undefined || this.displayType === DISPLAY_TYPE.default;
    }

    get displayMinimalVersion() {
        return this.displayType === DISPLAY_TYPE.minimal;
    }

    get displayPhoneNumber() {
        if (this.isDoNotCall){
            return false;
        }
        return this.phoneNumber
            && this.phoneNumber.trim().length > 0;
    }

    get phoneLink() {
        return this.baseUrl + formatPhoneNumberForUserPreference(this.userPreference, this.phoneNumber); 
    }

    get callFailedPhoneLink() {
        return this.baseUrl + formatPhoneNumberForUserPreference(CALL_FAILED_PREFERENCE, this.phoneNumber);
    }

    get doNotMarket() {
        return this.isDoNotMarket;

    }

    get displayCallFailed() {
        return this.userPreference.clickToDialPreference
            && this.userPreference.clickToDialPreference !== USER_DIAL_PREFERENCE.elevenDigits;
    }  
    
    handlePhoneClick() {
        const event = new CustomEvent('clicktodialclick', {
            composed: true,
            bubbles: true,
            cancelable: false,
            detail: {
                metaData: this.metaData,
                phoneNumber: this.phoneNumber
            },
        });
        this.dispatchEvent(event);
    }
}