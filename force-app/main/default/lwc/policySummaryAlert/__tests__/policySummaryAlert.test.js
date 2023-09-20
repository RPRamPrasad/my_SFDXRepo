import { createElement } from 'lwc';

import logClickCardAlertBillingAcctNum from '@salesforce/apex/PolicySummaryEventController.logClickCardAlertBillingAcctNum';
import logClickCardAlertPayBills from '@salesforce/apex/PolicySummaryEventController.logClickCardAlertPayBills';
import logClickListAlertBillingAcctNum from '@salesforce/apex/PolicySummaryEventController.logClickListAlertBillingAcctNum';
import logClickListAlertPayBills from '@salesforce/apex/PolicySummaryEventController.logClickListAlertPayBills';

import policySummaryAlert from 'c/policySummaryAlert';
import { getNavigateCalledWith } from 'lightning/navigation';

const multipleAlertList = require('./data/multipleAlertList.json');
const singleAlertList = require('./data/singleAlertList.json');
const accountList = require('./data/accountList.json');


//#region Mocks

jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardAlertBillingAcctNum',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardAlertPayBills',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListAlertPayBills',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListAlertBillingAcctNum',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

//#endregion

describe('c-policy-summary-alert', () => {
    let policySummaryAlertComp;

    beforeEach(() => {
        policySummaryAlertComp = createElement('c-policy-summary-alert', {
            is: policySummaryAlert
        });
        policySummaryAlertComp.alerts = multipleAlertList;
        policySummaryAlertComp.alert = policySummaryAlertComp.alerts[0];

    });

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        policySummaryAlertComp = null;
        jest.clearAllMocks();
    })

    const { setImmediate } = require('timers')
    function flushPromises() {
        return new Promise(resolve => setImmediate(resolve));
    }

    test('popoverHeader and alert list should be multiple', async () => {
        const clickHandler = jest.fn();
        policySummaryAlertComp.addEventListener("alertclick", clickHandler);
        policySummaryAlertComp.accountPageRecordId = '123'
        document.body.appendChild(policySummaryAlertComp);

        await flushPromises();

        return Promise.resolve()
            .then(() => {
                const alertLengthText = policySummaryAlertComp.shadowRoot.querySelector('span[data-id="alertLength"]').textContent;
                expect(alertLengthText).toEqual('(2)')
            })
            .then(() => {
                expect(clickHandler).not.toHaveBeenCalled();
                const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
                handler.click();
            })
            .then(() => {
                expect(clickHandler).toHaveBeenCalled();
                expect(clickHandler.mock.calls[0][0].detail.value).toEqual('123')
                const popoverHeaderText = policySummaryAlertComp.shadowRoot.querySelector('h2[data-id="popoverHeader"]').textContent;
                expect(popoverHeaderText).toEqual('Multiple warnings');
            });

    });

    test('popoverHeader and alertList should be single', async () => {
        policySummaryAlertComp.alerts = singleAlertList;
        policySummaryAlertComp.alert = policySummaryAlertComp.alerts[0];
        document.body.appendChild(policySummaryAlertComp);

        await flushPromises();

        return Promise.resolve()
            .then(() => {
                const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
                handler.click()
            })
            .then(() => {

                const popoverHeaderText = policySummaryAlertComp.shadowRoot.querySelector('h2[data-id="popoverHeader"]').textContent;
                expect(popoverHeaderText).toEqual('Warning');
                expect(policySummaryAlertComp.shadowRoot.querySelector('p[data-id="alertLength"]')).toBeNull(); // since alertLength is false this should not appear

            });

    });

    test('No popoverHeader and alertList should be single', async () => {
        policySummaryAlertComp.alerts = singleAlertList;
        policySummaryAlertComp.alert = policySummaryAlertComp.alerts[1];
        document.body.appendChild(policySummaryAlertComp);

        await flushPromises();

        return Promise.resolve()
            .then(() => {
                const alertLengthText = policySummaryAlertComp.shadowRoot.querySelector('span[data-id="alertLength"]')
                expect(alertLengthText).toBeFalsy();
            })
            .then(() => {
                const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
                handler.click()
            })
            .then(() => {

                const popoverHeaderText = policySummaryAlertComp.shadowRoot.querySelector('h2[data-id="popoverHeader"]').textContent;
                expect(popoverHeaderText).toEqual('Warning');
                expect(policySummaryAlertComp.shadowRoot.querySelector('p[data-id="alertLength"]')).toBeNull(); // since alertLength is false this should not appear

            });

    });

    it('should dispay the right billing account number', async () => {

        document.body.appendChild(policySummaryAlertComp);

        await flushPromises();

        return Promise.resolve()
            .then(() => {
                const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
                handler.click()
            })
            .then(() => {

                const urlText = policySummaryAlertComp.shadowRoot.querySelector('a[data-id="c1"]').textContent;
                expect(urlText).toEqual('1227350151');

            });

    });

    it('should open pay bills with the current page record id', async () => {

        policySummaryAlertComp.accountPageRecordId = '1234';
        document.body.appendChild(policySummaryAlertComp);
        window.open = jest.fn();

        await flushPromises();

        return Promise.resolve()
            .then(() => {
                const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
                handler.click()
            })
            .then(() => {
                const payBills = policySummaryAlertComp.shadowRoot.querySelector('a[data-id="launchPayBills"]');
                payBills.click();

                expect(window.open).toHaveBeenCalledWith("/c/ExternalLinkApp.app?linkId=232&accountId=1234");
                expect(logClickCardAlertPayBills).not.toHaveBeenCalled();
                expect(logClickListAlertPayBills).toHaveBeenCalled();
            });
    });

    it('should open pay bills as card view with the current page record id', async () => {

        policySummaryAlertComp.accountPageRecordId = '1234';
        policySummaryAlertComp.isCardView = true;
        document.body.appendChild(policySummaryAlertComp);
        window.open = jest.fn();

        await flushPromises();

        return Promise.resolve()
            .then(() => {
                const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
                handler.click()
            })
            .then(() => {
                const payBills = policySummaryAlertComp.shadowRoot.querySelector('a[data-id="launchPayBills"]');
                payBills.click();

                expect(window.open).toHaveBeenCalledWith("/c/ExternalLinkApp.app?linkId=232&accountId=1234");
                expect(logClickCardAlertPayBills).toHaveBeenCalled();
                expect(logClickListAlertPayBills).not.toHaveBeenCalled();
            });
    });

    it('should open new list picker modal when Pay Bills button is clicked on a household page', async () => {

        document.body.appendChild(policySummaryAlertComp);

        policySummaryAlertComp.recordId = '1234';
        policySummaryAlertComp.isHousehold = true;
        policySummaryAlertComp.accountList = accountList;
        window.open = jest.fn();

        await flushPromises();

        const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
        handler.click()

        await flushPromises();

        const payBillsButton = policySummaryAlertComp.shadowRoot.querySelector('a[data-id="launchPayBills"]');
        payBillsButton.click();

        await flushPromises();

        let listPickerModal = policySummaryAlertComp.shadowRoot.querySelector('[data-id="listPicker"]');
        let cancelButton = listPickerModal.shadowRoot.querySelector('[data-id="cancelButton"]');
        expect(listPickerModal).toBeTruthy();

        cancelButton.click();

        await flushPromises();

        listPickerModal = policySummaryAlertComp.shadowRoot.querySelector('[data-id="listPicker"]');
        expect(listPickerModal).toBeFalsy();
    });

    it('list picker modal should launch pay bills', async () => {

        document.body.appendChild(policySummaryAlertComp);

        policySummaryAlertComp.recordId = '1234';
        policySummaryAlertComp.isHousehold = true;
        policySummaryAlertComp.accountList = accountList;
        window.open = jest.fn();

        await flushPromises();

        const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
        handler.click()

        await flushPromises();

        const payBillsButton = policySummaryAlertComp.shadowRoot.querySelector('a[data-id="launchPayBills"]');
        payBillsButton.click();

        await flushPromises();

        let listPickerModal = policySummaryAlertComp.shadowRoot.querySelector('[data-id="listPicker"]');
        let accountItem = listPickerModal.shadowRoot.querySelector('[data-id="1"]');
        expect(listPickerModal).toBeTruthy();

        accountItem.click();

        await flushPromises();

        expect(window.open).toHaveBeenCalledWith("/c/ExternalLinkApp.app?linkId=232&accountId=1");

    });

    test('onMouseOut event - No urls', async () => {

        document.body.appendChild(policySummaryAlertComp);

        await flushPromises();

        return Promise.resolve()
            .then(() => {
                const mouseOutEvent = new CustomEvent("mouseout", {
                    bubbles: true,
                });
                const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
                handler.dispatchEvent(mouseOutEvent);
            })
            .then(() => {
                const urlText = policySummaryAlertComp.shadowRoot.querySelector('a[data-id="c1"]');
                const popoverHeaderText = policySummaryAlertComp.shadowRoot.querySelector('h2[data-id="popoverHeader"]');
                const payBillsButton = policySummaryAlertComp.shadowRoot.querySelector('a[data-id="launchPayBills"]');

                expect(urlText).toBeFalsy();
                expect(popoverHeaderText).toBeFalsy();
                expect(payBillsButton).toBeFalsy();

            });
    });


    it('should close the template when close button is clicked', async () => {

        document.body.appendChild(policySummaryAlertComp);

        await flushPromises();

        const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
        handler.click()

        await flushPromises();


        const closeButton = policySummaryAlertComp.shadowRoot.querySelector('lightning-button[data-id="closeButton"');
        closeButton.click();

        await flushPromises();

        expect(policySummaryAlertComp.shadowRoot.querySelector('lightning-button[data-id="closeButton"')).toBeFalsy();

    });



    it("should navigate to correct billing account", async () => {

        document.body.appendChild(policySummaryAlertComp);
        await flushPromises();

        const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
        handler.click()

        await flushPromises();
        const billingAccountLink = policySummaryAlertComp.shadowRoot.querySelector('a[data-id="c1"]');
        billingAccountLink.click();
        const { pageReference } = getNavigateCalledWith();
        await Promise.resolve();
        expect(pageReference.type).toBe('standard__recordPage');
        expect(pageReference.attributes.objectApiName).toBe('Billing_Account__c');
        expect(pageReference.attributes.actionName).toBe('view');
        expect(logClickListAlertBillingAcctNum).toHaveBeenCalled();
        expect(logClickCardAlertBillingAcctNum).not.toHaveBeenCalled();
    });

    it("should navigate to correct billing account on card view", async () => {

        policySummaryAlertComp.isCardView = true;

        document.body.appendChild(policySummaryAlertComp);
        await flushPromises();

        const handler = policySummaryAlertComp.shadowRoot.querySelector('[data-id="hover"]');
        handler.click()

        await flushPromises();
        const billingAccountLink = policySummaryAlertComp.shadowRoot.querySelector('a[data-id="c1"]');
        billingAccountLink.click();
        const { pageReference } = getNavigateCalledWith();
        await Promise.resolve();
        expect(pageReference.type).toBe('standard__recordPage');
        expect(pageReference.attributes.objectApiName).toBe('Billing_Account__c');
        expect(pageReference.attributes.actionName).toBe('view');
        expect(logClickListAlertBillingAcctNum).not.toHaveBeenCalled();
        expect(logClickCardAlertBillingAcctNum).toHaveBeenCalled();
    });

})
