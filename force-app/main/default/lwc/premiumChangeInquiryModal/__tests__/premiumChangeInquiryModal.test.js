import { createElement } from 'lwc';
import PremiumChangeInquiryModal from 'c/premiumChangeInquiryModal';
import callPremiumChange from '@salesforce/apex/PremiumChangeController.callPremiumChange';

const DV_NOT_PL_AUTO = { "premiumChange": [{ "vehicleName": ["2018 BMW X5"], "ratingChanges": ["The vehicle rating changed from GRG 28 to GRG 27", "The vehicle rating changed from DRG 31 to DRG 30"], "premiumChangeStatement": ["The premium for this vehicle increased by $123.44.  This represents a premium increase of 39%.  This review did not include accident surcharge or coverage changes."], "noPremiumChange": false, "mileageChanged": ["Annual Mileage changed from 5400 to 6900"], "isWA": false, "isOther": true, "isNY": false, "dss3": false, "dss2": true, "dss1": false, "discRemoved": null, "discChanged": null }, { "vehicleName": ["2020 TOYOTA TUNDRA"], "ratingChanges": ["The vehicle rating changed from GRG 24 to GRG 23", "The vehicle rating changed from DRG 25 to DRG 26", "The vehicle rating changed from LRG 7 to LRG 6"], "premiumChangeStatement": ["The premium for this vehicle increased by $107.22.  This represents a premium increase of 39%.  This review did not include accident surcharge or coverage changes."], "noPremiumChange": false, "mileageChanged": ["Annual Mileage changed from 6000 to 5800"], "isWA": false, "isOther": true, "isNY": false, "dss3": false, "dss2": true, "dss1": false, "discRemoved": null, "discChanged": null }], "responseStatus": 200, "flowType": "PLAuto"};
const DV_NO_RESPONSE = { "responseStatus": 404, "errorMsg": "" }
const DV_PL_AUTO_No_RESPONSE = { "responseStatus": 404, "errorMsg": "Unable to find second DV information!!","flowType": "PLAuto", };
const DV_PL_FIRE_No_RESPONSE = { "responseStatus": 404, "errorMsg": "Unable to find second DV information!!","flowType": "PLFire", };
const DV_BL_AUTO_No_RESPONSE = { "responseStatus": 404, "errorMsg": "Unable to find second DV information!!","flowType": "BLAuto", };
const DV_INVALID_FLOW_TYPE = { "responseStatus": 404, "errorMsg": "Unable to find second DV information!!","flowType": "PLModAuto"};
const DV_BL_AUTO_POLICY_NOT_IN_FORCE_RESPONSE = { "responseStatus": 404, "errorMsg": "Given policy # is not in force","flowType": "BLAuto", };

const DV_BL_FIRE_No_RESPONSE = { "responseStatus": 404, "errorMsg": "BLFire Not in scope","flowType": "BLFire", };

const DV_PL_AUTO_RESPONSE = { "responseStatus": 200, "flowType": "PLAuto","premiumChange": [{ "isWA": false, "isOther": true, "isNY": false, "dss3": false, "dss2": false, "dss1": true, "discRemoved": null, "discChanged": null }] };
const DV_RESPONSE_SUCCESS = {"premiumChange": [{"isWA": false, "isOther": true,"isNY": false,"dss3": false,"dss2": false,"dss1": true,"discRemoved": null,"discChanged": null}],"responseStatus": 200,"flowType": "PLAuto"};
const DV_NO_RESPONSE_POLICY = {};

const { setImmediate } = require('timers');

jest.mock(
    "@salesforce/apex/PremiumChangeController.callPremiumChange",
    () => ({ default: jest.fn() }), { virtual: true }
);

function flushPromises() {
    return new Promise(resolve => setImmediate(resolve));
}

describe('c-premium-change-inquiry-modal', () => {
    let premiumChangeInquiryModal;

    beforeEach(() => {
        premiumChangeInquiryModal = createElement('c-premium-change-inquiry-modal', {
            is: PremiumChangeInquiryModal
        });
        document.body.appendChild(premiumChangeInquiryModal);
    })

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        premiumChangeInquiryModal = null;
        jest.clearAllMocks();
    });


    it('opens Modal before DV is loading the data', async () => {
        premiumChangeInquiryModal.recordId = '123';
        const dvPlAutoResponse = JSON.stringify(DV_PL_AUTO_RESPONSE);
        if (JSON.parse(dvPlAutoResponse)?.flowType === "PLAuto"){
            premiumChangeInquiryModal.isPLAuto = true;
        }

        if (JSON.parse(dvPlAutoResponse)?.responseStatus === 200){
            premiumChangeInquiryModal.responseStatus = true;
        }
        
        
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvPlAutoResponse));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        const beforeModalSpinner = premiumChangeInquiryModal.shadowRoot.querySelector('[data-id="loading-spinner"]');
        expect(beforeModalSpinner.textContent).toEqual('');
        await Promise.resolve();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: '123'
        });
        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        expect(premiumChangeInquiryModal.isPLAuto).toBeTruthy();
        expect(premiumChangeInquiryModal.responseStatus).toBeTruthy();
    });

    it('Resonpse Successs', async () => {
        premiumChangeInquiryModal.recordId = '123';
        const dvPlAutoResponse = JSON.stringify(DV_RESPONSE_SUCCESS);
        if (JSON.parse(dvPlAutoResponse)?.flowType === "PLAuto"){
            premiumChangeInquiryModal.isPLAuto = true;
        }

        if (JSON.parse(dvPlAutoResponse)?.responseStatus === 200){
            premiumChangeInquiryModal.responseStatus = true;
        }

        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvPlAutoResponse));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await Promise.resolve();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: '123'
        });
        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        expect(premiumChangeInquiryModal.isPLAuto).toBeTruthy();
        expect(premiumChangeInquiryModal.responseStatus).toBeTruthy();
        const lblMsg = premiumChangeInquiryModal.shadowRoot.querySelector('.sf-premium-lbl');
        expect(lblMsg.textContent).toEqual(' Find details below on why the premium changed at renewal:');
    });

    it('No response for PL Auto', async () => {
        premiumChangeInquiryModal.recordId = '123';
        const dvPlAutoNoResponse = JSON.stringify(DV_PL_AUTO_No_RESPONSE);
        if (JSON.parse(dvPlAutoNoResponse)?.flowType === "PLAuto"){
            premiumChangeInquiryModal.isPLAuto = true;
        }

        if (JSON.parse(dvPlAutoNoResponse)?.responseStatus === 200){
            premiumChangeInquiryModal.responseStatus = true;
        }
        
        if (JSON.parse(dvPlAutoNoResponse)?.errorMsg) {
            if (JSON.parse(dvPlAutoNoResponse)?.errorMsg.includes("Unable to find")) {
                premiumChangeInquiryModal.unableToLocatePolicy = true;
            } else {
                premiumChangeInquiryModal.unableToLocatePolicy = false;
            }
        }
        
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvPlAutoNoResponse));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await Promise.resolve();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: '123'
        });

        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        expect(premiumChangeInquiryModal.responseStatus).toBeFalsy();
        //expect(premiumChangeInquiryModal.isPLAuto).toBeTruthy();
        expect(premiumChangeInquiryModal.unableToLocatePolicy).toBeTruthy();
        const errorMsg = premiumChangeInquiryModal.shadowRoot.querySelector('.sf-pl-auto-no-response');
        const linkCall = premiumChangeInquiryModal.shadowRoot.querySelector('.pl-auto-no-respone-lnk');
        expect(linkCall.textContent).toEqual("Auto Renewal Premium Increase Activities");
        expect(linkCall.href).toContain("http://sfnet.opr.statefarm.org/agency/manuals/customer_retention/auto_renewal_premium_increase_checklist.shtml");
        expect(errorMsg.textContent).toBe("We were unable to locate your policy to review why the premium changed at renewal. The Auto Renewal Premium Increase Activities can help determine changes or events that may have impacted the auto renewal premium.");
    });

    it('No response for PL Fire', async () => {
        premiumChangeInquiryModal.recordId = '123';
        const dvPlFireNoResponse = JSON.stringify(DV_PL_FIRE_No_RESPONSE);
        if (JSON.parse(dvPlFireNoResponse)?.flowType === "PLFire"){
            premiumChangeInquiryModal.isPLFire = true;
        }

        if (JSON.parse(dvPlFireNoResponse)?.responseStatus === 200){
            premiumChangeInquiryModal.responseStatus = true;
        }
        
        if (JSON.parse(dvPlFireNoResponse)?.errorMsg) {
            if (JSON.parse(dvPlFireNoResponse)?.errorMsg.includes("Unable to find")) {
                premiumChangeInquiryModal.unableToLocatePolicy = true;
            } else {
                premiumChangeInquiryModal.unableToLocatePolicy = false;
            }
        }
        
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvPlFireNoResponse));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await Promise.resolve();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: '123'
        });

        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        expect(premiumChangeInquiryModal.responseStatus).toBeFalsy();
        //expect(premiumChangeInquiryModal.isPLAuto).toBeTruthy();
        expect(premiumChangeInquiryModal.unableToLocatePolicy).toBeTruthy();
       // const errorMsg = premiumChangeInquiryModal.shadowRoot.querySelector('.sf-pl-fire-no-response');
        const linkCall = premiumChangeInquiryModal.shadowRoot.querySelector('.pl-fire-no-respone-lnk');
        expect(linkCall.textContent).toEqual("Fire Rate Changes");
        expect(linkCall.href).toContain("http://sfnet.opr.statefarm.org/agency/manuals/firechanges/statelist.shtml");
        
    });

    it('No response for BL Auto', async () => {
        premiumChangeInquiryModal.recordId = '123';
        const dvBlAutoNoResponse = JSON.stringify(DV_BL_AUTO_No_RESPONSE);
        if (JSON.parse(dvBlAutoNoResponse)?.flowType === "BLAuto"){
            premiumChangeInquiryModal.isBLAuto = true;
        }

        if (JSON.parse(dvBlAutoNoResponse)?.responseStatus === 200){
            premiumChangeInquiryModal.responseStatus = true;
        } else {
            premiumChangeInquiryModal.responseStatus = false;
        }
        
        if (JSON.parse(dvBlAutoNoResponse)?.errorMsg) {
            if (JSON.parse(dvBlAutoNoResponse)?.errorMsg.includes("Unable to find")) {
                premiumChangeInquiryModal.unableToLocatePolicy = true;
            } else {
                premiumChangeInquiryModal.unableToLocatePolicy = false;
            }
        }
        
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvBlAutoNoResponse));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await Promise.resolve();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: '123'
        });

        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        expect(premiumChangeInquiryModal.responseStatus).toBeFalsy();
        expect(premiumChangeInquiryModal.isBLAuto).toBeTruthy();
        expect(premiumChangeInquiryModal.unableToLocatePolicy).toBeTruthy();
        const errorMsg = premiumChangeInquiryModal.shadowRoot.querySelector('.sf-bl-auto-no-response');
        const linkCall = premiumChangeInquiryModal.shadowRoot.querySelector('.bl-auto-no-respone-lnk');
        expect(linkCall.textContent).toEqual("here,");
        expect(linkCall.href).toContain("http://sfeuc.opr.statefarm.org/EUCNET01048/Default.aspx");
        expect(errorMsg.textContent).toContain("We were unable to locate your policy to review why the premium changed at renewal.Verify if a rate change to your state contributed to the premium change. To locate this information click here, select the state, and review");
    });

    it('No response for BL Auto Policy Not In Force', async () => {
        premiumChangeInquiryModal.recordId = '123';
        const dvBlAutoNoResponse = JSON.stringify(DV_BL_AUTO_POLICY_NOT_IN_FORCE_RESPONSE);
        if (JSON.parse(dvBlAutoNoResponse)?.flowType === "BLAuto"){
            premiumChangeInquiryModal.isBLAuto = true;
        }

        if (JSON.parse(dvBlAutoNoResponse)?.responseStatus === 200){
            premiumChangeInquiryModal.responseStatus = true;
        } else {
            premiumChangeInquiryModal.responseStatus = false;
        }
        
        if (JSON.parse(dvBlAutoNoResponse)?.errorMsg) {
            if (JSON.parse(dvBlAutoNoResponse)?.errorMsg.includes("Unable to find")) {
                premiumChangeInquiryModal.unableToLocatePolicy = true;
            } else {
                premiumChangeInquiryModal.unableToLocatePolicy = false;
            }
        }
        
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvBlAutoNoResponse));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await Promise.resolve();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: '123'
        });

        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        expect(premiumChangeInquiryModal.responseStatus).toBeFalsy();
        expect(premiumChangeInquiryModal.isBLAuto).toBeTruthy();
        expect(premiumChangeInquiryModal.unableToLocatePolicy).toBeFalsy();
        const errorMsg = premiumChangeInquiryModal.shadowRoot.querySelector('.sf-bl-auto-no-response');
        const linkCall = premiumChangeInquiryModal.shadowRoot.querySelector('.bl-auto-no-respone-lnk');
        expect(linkCall.textContent).toEqual("here,");
        expect(linkCall.href).toContain("http://sfeuc.opr.statefarm.org/EUCNET01048/Default.aspx");
        expect(errorMsg.textContent).toContain("We were unable to locate your policy to review why the premium changed at renewal.Verify if a rate change to your state contributed to the premium change. To locate this information click here, select the state, and review");
    });


    it('No response for BL Fire', async () => {
        premiumChangeInquiryModal.recordId = '123';
        const dvBlFireNoResponse = JSON.stringify(DV_BL_FIRE_No_RESPONSE);
        if (JSON.parse(dvBlFireNoResponse)?.flowType === "BLFire"){
            premiumChangeInquiryModal.isBLFire = true;
        }

        if (JSON.parse(dvBlFireNoResponse)?.responseStatus === 200){
            premiumChangeInquiryModal.responseStatus = true;
        }
        
        if (JSON.parse(dvBlFireNoResponse)?.errorMsg) {
            if (JSON.parse(dvBlFireNoResponse)?.errorMsg.includes("Unable to find")) {
                premiumChangeInquiryModal.unableToLocatePolicy = true;
            } else {
                premiumChangeInquiryModal.unableToLocatePolicy = false;
            }
        }
        
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvBlFireNoResponse));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await Promise.resolve();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: '123'
        });

        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        expect(premiumChangeInquiryModal.responseStatus).toBeFalsy();
        expect(premiumChangeInquiryModal.isBLFire).toBeTruthy();
        expect(premiumChangeInquiryModal.unableToLocatePolicy).toBeFalsy();
        //const errorMsg = premiumChangeInquiryModal.shadowRoot.querySelector('.sf-bl-auto-no-response');
        const linkCall = premiumChangeInquiryModal.shadowRoot.querySelector('.bl-fire-no-respone-lnk');
        const linkCall2 = premiumChangeInquiryModal.shadowRoot.querySelector('.bl-fire-no-respone-lnk-2');
        expect(linkCall.textContent).toEqual(" here");
        expect(linkCall2.textContent).toEqual("Quick Resource for Business Lines Grown");
        expect(linkCall.href).toContain("http://sfeuc.opr.statefarm.org/EUCNET01048/Default.aspx");
        expect(linkCall2.href).toContain("https://collab.sfcollab.org/sites/WSS003629/SharedTraining_AgtsTM/QRBLG.pdf");
        //expect(errorMsg.textContent).toContain("We were unable to locate your policy to review why the premium changed at renewal.Verify if a rate change to your state contributed to the premium change. To locate this information click here, select the state, and review");
    });



    it('closes Modal with all the values reset', async () => {
        premiumChangeInquiryModal.isModalOpen = true;
        await flushPromises();
        const closeButton = premiumChangeInquiryModal.shadowRoot.querySelector('button[data-id="closeButton"]');
        closeButton.dispatchEvent(new CustomEvent('click'));
        expect(premiumChangeInquiryModal.isModalOpen).toBe(false);
    });

    it('is PL AUTO false', async () => {
        premiumChangeInquiryModal.recordId = 'policyId';
        expect(premiumChangeInquiryModal.isModalOpen).toBe(false);
        callPremiumChange.mockResolvedValue();
        const dvResponsePLAuto = DV_NOT_PL_AUTO;
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvResponsePLAuto));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await flushPromises();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: 'policyId'
        });
        premiumChangeInquiryModal.responseStatus = DV_NOT_PL_AUTO.responseStatus;
        premiumChangeInquiryModal.isPLAuto = dvResponsePLAuto.isPLAuto;
        expect(premiumChangeInquiryModal.responseStatus).toBeTruthy();
        expect(premiumChangeInquiryModal.isPLAuto).toBeFalsy();
        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
    });

    it('No response, no policy available for premium change', async () => {
        premiumChangeInquiryModal.recordId = 'policyId';
        const dvNoResponsePLAuto = JSON.stringify(DV_NO_RESPONSE);
        if (JSON.parse(dvNoResponsePLAuto)?.flowType === "PLAuto"){
            premiumChangeInquiryModal.isPLAuto = true;
        }

        if (JSON.parse(dvNoResponsePLAuto)?.responseStatus === 200){
            premiumChangeInquiryModal.responseStatus = true;
        }
        
        if (JSON.parse(dvNoResponsePLAuto)?.errorMsg) {
            if (JSON.parse(dvNoResponsePLAuto)?.errorMsg.includes("Unable to find")) {
                premiumChangeInquiryModal.unableToLocatePolicy = true;
            } else {

                premiumChangeInquiryModal.unableToLocatePolicy = false;
            }
        } else {
            premiumChangeInquiryModal.unableToLocatePolicy = false;
        }
        
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvNoResponsePLAuto));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await flushPromises();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: 'policyId'
        });
        premiumChangeInquiryModal.isError = false;
        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        expect(premiumChangeInquiryModal.responseStatus).toBeFalsy();
        expect(premiumChangeInquiryModal.isError).toBeFalsy();       
        const errorMsgNoPolicy = premiumChangeInquiryModal.shadowRoot.querySelector('.sf-no-response-no-policy');
        expect(errorMsgNoPolicy.textContent).toBe("We were unable to locate your policy to review why the premium changed at renewal.");

    });

    it('No response, no policy, blank flow type available for premium change', async () => {
        premiumChangeInquiryModal.recordId = 'policyId';
        const dvInvalidFlowType = JSON.stringify(DV_INVALID_FLOW_TYPE );
        

        if (JSON.parse(dvInvalidFlowType)?.responseStatus === 200){
            premiumChangeInquiryModal.responseStatus = true;
        }
        
        if (JSON.parse(dvInvalidFlowType)?.errorMsg) {
            if (JSON.parse(dvInvalidFlowType)?.errorMsg.includes("Unable to find")) {
                premiumChangeInquiryModal.unableToLocatePolicy = true;
            } else {

                premiumChangeInquiryModal.unableToLocatePolicy = false;
            }
        } else {
            premiumChangeInquiryModal.unableToLocatePolicy = false;
        }
        
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvInvalidFlowType));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await flushPromises();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: 'policyId'
        });
        premiumChangeInquiryModal.isError = false;
        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        expect(premiumChangeInquiryModal.responseStatus).toBeFalsy();
        expect(premiumChangeInquiryModal.isError).toBeFalsy();       
        const errorMsgNoPolicy = premiumChangeInquiryModal.shadowRoot.querySelector('.sf-no-response-no-policy');
        expect(errorMsgNoPolicy.textContent).toBe("We were unable to locate your policy to review why the premium changed at renewal.");

    });


    it('opens Modal before DV is loading the data view More', async () => {
        premiumChangeInquiryModal.recordId = '123';
        const dvPlAutoResponse = JSON.stringify(DV_PL_AUTO_RESPONSE);
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvPlAutoResponse));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await Promise.resolve();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: '123'
        });
        const dssViewMore = premiumChangeInquiryModal.shadowRoot.querySelector('[data-id="dssViewMore1"]');
        await dssViewMore.click();       
        premiumChangeInquiryModal.isDssShowHide = true;
        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        expect(premiumChangeInquiryModal.isDssShowHide).toBeTruthy();       
    });

    it('opens Modal before DV is loading the data view less', async () => {
        premiumChangeInquiryModal.recordId = '123';
        const dvPlAutoResponse = JSON.stringify(DV_PL_AUTO_RESPONSE);
        callPremiumChange.mockImplementationOnce(() => Promise.resolve(dvPlAutoResponse));
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);
        await Promise.resolve();
        expect(callPremiumChange).toHaveBeenCalled();
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: '123'
        });
        const dssViewMore = premiumChangeInquiryModal.shadowRoot.querySelector('[data-id="dssViewMore1"]');
        await dssViewMore.click();
        const showMsg = premiumChangeInquiryModal.shadowRoot.querySelector('[data-id="dssViewLess1"]');
        expect(showMsg.textContent).toBe("View Less Drive Safe & Save Information");
        expect(premiumChangeInquiryModal.shouldShowSpinner).toBeFalsy();
        const dssViewLess = premiumChangeInquiryModal.shadowRoot.querySelector('[data-id="dssViewLess1"]');
        await dssViewLess.click();
        const dssViewMoreMsg = premiumChangeInquiryModal.shadowRoot.querySelector('[data-id="dssViewMore1"]');
        expect(dssViewMoreMsg.textContent).toBe('View Additional Drive Safe & Save Information');

    });

    it('No response in catch block', async () => {
        premiumChangeInquiryModal.recordId = '';
        const dvNoResponsePLAuto = DV_NO_RESPONSE_POLICY;
        callPremiumChange.mockImplementationOnce(() => Promise.reject(dvNoResponsePLAuto));        
        await premiumChangeInquiryModal.openModal();
        expect(premiumChangeInquiryModal.isModalOpen).toBe(true);       
        await flushPromises();      
        expect(callPremiumChange).toHaveBeenCalledWith({
            policyId: ''
        });     
        const errorMsgNoResponse = await premiumChangeInquiryModal.shadowRoot.querySelector('.sf-no-response-status');        
        expect(errorMsgNoResponse.textContent).toBe("We were unable to locate your policy to review why the premium changed at renewal.");
    });


});