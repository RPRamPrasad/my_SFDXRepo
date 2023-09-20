import { createElement } from 'lwc';
import AgentStatusTracker from 'c/agentStatusTrackerModal';

const { setImmediate } = require('timers');

function flushPromises() {
    return new Promise(resolve => setImmediate(resolve));
}

describe('c-agent-status-tracker', () => {

    let  agentStatusTracker;

    beforeEach(() => {
        agentStatusTracker = createElement('c-agent-status-tracker-modal', {
            is:  AgentStatusTracker
        });
        document.body.appendChild(agentStatusTracker);
    })

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        agentStatusTracker = null;       
    });

    it('opens Modal before DV is loading the data', async () => {        
        await  agentStatusTracker.openModal();
        expect(agentStatusTracker.isModalOpen).toBe(true);       
        await Promise.resolve();
       
        const linkMsg = agentStatusTracker.shadowRoot.querySelector('.agent-status-tracker-lnk-container');
        const linkCall = agentStatusTracker.shadowRoot.querySelector('.agent-status-tracker-lnk');
        expect(linkCall.textContent).toEqual("here");
        expect(linkCall.href).toContain("https://sfeucnet01873.opr.statefarm.org/");
        expect(linkMsg.textContent).toBe( "Click here to view the Agent Status Tracker to obtain the status of a policy transaction.");
        
    });


    it('closes Modal with all the values reset', async () => {
        agentStatusTracker.isModalOpen = true;
        await flushPromises();
        const closeButton =  agentStatusTracker.shadowRoot.querySelector('button[data-id="closeButton"]');
        closeButton.dispatchEvent(new CustomEvent('click'));
        expect(agentStatusTracker.isModalOpen).toBe(false);
    });
   
});



























   

   

    

       