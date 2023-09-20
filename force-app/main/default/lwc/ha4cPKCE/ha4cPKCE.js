import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getVFOrigin from '@salesforce/apex/HA4C_PKCE.getVFOrigin';
import getHA4CToken from '@salesforce/apex/HA4C_PKCE.getHA4CToken';
import getPolicyDetailsParmHA4C from '@salesforce/apex/Ha4cWebController.getPolicyDetailsParmHA4C';

const SUCCESS_STATUS = 200;
const UNKNOWN = 'unknown';

const isJsonString = (jsonString) => {
    try {
        const o = JSON.parse(jsonString);
        if (o && typeof o === "object") {
            return true;
        }
    }
    catch (e) {
        // returning false
    }
    return false;
};

const parseJSON = (jsonString) => {
    if (isJsonString(jsonString)) {
        return JSON.parse(jsonString);
    }
    return {};
};

export default class HA4CPkce extends NavigationMixin(LightningElement) {

    loadFrame;
    WORKSTATION = 'ha4c_workstation_id';
    calledRenderedCallback = false;
    vfMessageListener;
    @api recordId;
    parmString;

    constructor() {
        super();
        // save a reference to the bound function 
        // because bind() returns a new function 
        // and the component would not be able to call 
        // removeEventListener() with the same function instance
        this.vfMessageListener = this.handleAuthResponse.bind(this);
    }

    connectedCallback() {
        //bind event listener for data received from visualforce auth call 
        window.addEventListener('message', this.vfMessageListener);


    }

    disconnectedCallback() {
        window.removeEventListener('message', this.vfMessageListener);
    }

    renderedCallback() {
        if (!this.calledRenderedCallback) {
            this.calledRenderedCallback = true;
            const workstationId = sessionStorage.getItem(this.WORKSTATION);
            if (workstationId) {
                this.navigateToWeb(workstationId);
            } else {
                this.loadFrame = true;
            }
        }
    }

    async handleAuthResponse(event) {
        const vfOrigin = await getVFOrigin();
        if (event.data && (event.origin === vfOrigin)) {
            const msg = parseJSON(event.data);
            if (msg.ha4cVfReady === true) {
                this.initiateVFAuthCall(vfOrigin);
            }
            if (msg.ha4cToken === true) {
                await this.processToken();
            }
            if (msg.ha4cToken === false) {
                this.processWorkstationId(UNKNOWN);
            }
        }
    }

    initiateVFAuthCall(vfOrigin) {
        //call vf to initiate auth flow
        const message = { ha4cPkceLogin: true }
        this.template.querySelector('iframe').contentWindow.postMessage(JSON.stringify(message), vfOrigin);
    }

    async processToken() {
        const token = await getHA4CToken();
        const deviceId = parseJSON(window.atob(token.split('.')[1])).deviceid;
        const workstationId = await this.determineWorkstationId(token, deviceId);
        this.processWorkstationId(workstationId);
    }

    async determineWorkstationId(token, deviceId) {
        // call microsoftGraph API if the deviceId is not undefined
        if (typeof deviceId != 'undefined') {
            const endpoint = `https://graph.microsoft.com/v1.0/devices?$filter=deviceId+eq+'${deviceId}'&$select=displayName`;
            const respJson = await this.callMSGraph(endpoint, token);
            return respJson?.value[0]?.displayName || UNKNOWN;
        }
        return UNKNOWN
    }

    processWorkstationId(workstationId) {
        sessionStorage.setItem(this.WORKSTATION, workstationId);
        this.navigateToWeb(workstationId);

    }

    //This method will launch URL in new Browser Window tab after setting up all paramters
    async navigateToWeb(workstationId) {
        try {
            if (this.parmString === undefined) {
                this.parmString = await getPolicyDetailsParmHA4C({ caseId: this.recordId });
            }
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.parmString + '&workstationID=' + workstationId + '&pgmName=PCA21&callingApp=Case'
                }
            })
        } catch (error) {
            this.showToast('Launch to Necho Status', "Error", 'The operation couldnt be completed (Status: ' +
                error.message +
                ' ). Please contact WG11255.');
        }
    }

    async callMSGraph(endpoint, accessToken) {
        const bearer = `Bearer ${accessToken}`;
        const options = {
            method: "GET",
            headers: {
                'Authorization': bearer,
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'ConsistencyLevel': 'eventual'
            }
        };
        try {
            const response = await fetch(endpoint, options);
            // return response json only if the status code is 200
            if (response.status === SUCCESS_STATUS) {
                const responseBody = await response.json();
                return responseBody;
            }
        } catch (e) {
            // nothing to do here - just returning null
        }
        return null;
    }

    showToast(title, type, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            variant: type,
            message: message
        });
        this.dispatchEvent(toastEvent);
    }
}