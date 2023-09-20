import { createElement } from 'lwc';
import SendToCustomerModal from 'c/sendToCustomerModal';

describe('c-send-to-customer-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });


it('Do not show no email error message', () => {
    const element = createElement('c-send-to-customer-modal', {
        is: SendToCustomerModal
    });
    element.customerName='Customer';
    element.customerEmail='customer@sf.com';
    element.isModalOpen=true;
    document.body.appendChild(element);
    const div=element.shadowRoot.querySelector('[data-id="noEmail"]');
    expect(div).toBeNull();
});

it('Shows the no email error message', () => {
    const element = createElement('c-send-to-customer-modal', {
        is: SendToCustomerModal
    });
    element.customerName='Customer';
    element.customerEmail=null;
    element.isModalOpen=true;
    document.body.appendChild(element);
    const div=element.shadowRoot.querySelector('[data-id="noEmail"]');
    expect(div.textContent).toBe('There is no email address for this customer. Please ask the customer to provide a valid email.');
});
it('Closes Modal', () => {
    const element = createElement('c-send-to-customer-modal', {
        is: SendToCustomerModal
    });
    element.customerName='Customer';
    element.customerEmail='';
    element.isModalOpen=true;
    document.body.appendChild(element);
    const handler = jest.fn();
    element.addEventListener('closemodal', handler);
    const div=element.shadowRoot.querySelector('[data-id="cancelButton"]');
    div.dispatchEvent(new CustomEvent('click'));
    return Promise.resolve().then(() =>{
        expect(element.isModalOpen).toBe(false);
        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.showModal).toBe(false);
    });
});

it('Handle Send Button', () => {
    const element = createElement('c-send-to-customer-modal', {
        is: SendToCustomerModal
    });
    element.customerName='Customer';
    element.customerEmail='customer@gmail.com';
    element.isModalOpen=true;
    document.body.appendChild(element);
    const handler = jest.fn();
    element.addEventListener('sendconfirmation', handler);
    const div=element.shadowRoot.querySelector('[data-id="saveButton"]');
    div.dispatchEvent(new CustomEvent('click'));
    return Promise.resolve().then(() =>{

        expect(element.isModalOpen).toBe(false);
        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.sendEmail).toBe(true);
        expect(handler.mock.calls[0][0].detail.userEmail).toBe(element.customerEmail);
    });
});


it('Handle changes in Input Email field', () => {
    const element = createElement('c-send-to-customer-modal', {
        is: SendToCustomerModal
    });
    element.customerName='Customer';
    element.customerEmail='customer@gmail.com';
    element.isModalOpen=true;
    document.body.appendChild(element);
    const div=element.shadowRoot.querySelector('lightning-input');
    div.value='abc@sf.com'
    div.dispatchEvent(new CustomEvent('change'));
    return Promise.resolve().then(() =>{
        expect(element.customerEmail).toBe('abc@sf.com');
    });

    
});

it('Handles changes in Input Email field with no email', () => {
    const element = createElement('c-send-to-customer-modal', {
        is: SendToCustomerModal
    });
    element.customerName='Customer';
    element.customerEmail='customer@gmail.com';
    element.isModalOpen=true;
    document.body.appendChild(element);
     
    const div=element.shadowRoot.querySelector('lightning-input');
    div.value=''
    
    div.dispatchEvent(new CustomEvent('change'));
    return Promise.resolve().then(() =>{
        const errorMessage=element.shadowRoot.querySelector('[data-id="noEmail"]');
        expect(errorMessage.textContent).toBe('There is no email address for this customer. Please ask the customer to provide a valid email.');
    });

    
});

it('When the email is not present initially and the value is entered later', () => {
    const element = createElement('c-send-to-customer-modal', {
        is: SendToCustomerModal
    });
    element.customerName='Customer';
    element.customerEmail=null;
    element.isModalOpen=true;
    document.body.appendChild(element);
     
    const div=element.shadowRoot.querySelector('lightning-input');
    div.value='abc@sf.com'
    
    div.dispatchEvent(new CustomEvent('change'));
    return Promise.resolve().then(() =>{
        const errorMessage=element.shadowRoot.querySelector('[data-id="noEmail"]');
        expect(errorMessage).toBeNull();
    });
    
});
});