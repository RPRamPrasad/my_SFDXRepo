import { createElement } from 'lwc';
import listPickerModal from 'c/listPickerModal';

const TITLE = 'ListPickerTest';
const PAGE_SIZE = 3;

const items = require('./data/items.json');
const duplicateItems = require('./data/duplicateItems.json');

describe('List Picker Modal Component', () => {

    let listPickerModalInstance;

    beforeEach(() => {

        listPickerModalInstance = createElement('c-list-picker-modal', {
            is: listPickerModal
        });

        listPickerModalInstance.title = TITLE;
        listPickerModalInstance.pageSize = PAGE_SIZE;
        listPickerModalInstance.list = items;

    })


    const { setImmediate } = require('timers')
function flushPromises() {
        
        return new Promise(resolve => setImmediate(resolve));
    }

    it('List Picker Modal Happy Path Page Loaded', async () => {

        document.body.appendChild(listPickerModalInstance);

        // Verify Page Title
        let titleField = listPickerModalInstance.shadowRoot.querySelector('[data-id="title"]');
        expect(titleField.textContent).toEqual(TITLE);

        //Verify that the correct number of accounts have loaded
        const pagination = listPickerModalInstance.shadowRoot.querySelector('[data-id="listPickerPaginatior"]');
        expect(pagination.totalDataSize).toEqual(items.length);

        // Verify the first link is loaded, this will be more throughly tested when focusing on pagination.
        const itemList = listPickerModalInstance.shadowRoot.querySelector('[data-id="itemList"]');
        const itemListButtons = itemList.querySelectorAll('lightning-button');
        expect(itemListButtons.length).toEqual(PAGE_SIZE);
        expect(itemListButtons[0].label).toEqual(items[0].label);


    });

    it('List Picker Modal Duplicate Items Path Loaded', async () => {

        listPickerModalInstance.list = duplicateItems;
        document.body.appendChild(listPickerModalInstance);
        await flushPromises();
        // Verify Page Title
        let titleField = listPickerModalInstance.shadowRoot.querySelector('[data-id="title"]');
        expect(titleField.textContent).toEqual(TITLE);

        // Verify the first link is loaded, this will be more throughly tested when focusing on pagination.
        const itemList = listPickerModalInstance.shadowRoot.querySelector('[data-id="itemList"]');
        const itemListButtons = itemList.querySelectorAll('lightning-button');
        expect(itemListButtons.length).toEqual(PAGE_SIZE);
        expect(itemListButtons[0].label).toEqual("Kirk");


    });

    it('List Picker options testing', async () => {
        let a = {"Value": "1", "label": "A"};
        let b = {"Value": "2", "label": "B"};
        let c = {"Value": "3", "label": "a"};

        listPickerModalInstance.list = [b, a];
        document.body.appendChild(listPickerModalInstance);
        expect(listPickerModalInstance.sortedList).toEqual([a, b]);

        listPickerModalInstance.list = [a, b];
        document.body.appendChild(listPickerModalInstance);
        expect(listPickerModalInstance.sortedList).toEqual([a, b]);

        listPickerModalInstance.list = [c, a];
        document.body.appendChild(listPickerModalInstance);
        expect(listPickerModalInstance.sortedList).toEqual([c, a]);

        listPickerModalInstance.list = [a, c];
        document.body.appendChild(listPickerModalInstance);
        expect(listPickerModalInstance.sortedList).toEqual([a, c]);

        listPickerModalInstance.list = [b, c];
        document.body.appendChild(listPickerModalInstance);
        expect(listPickerModalInstance.sortedList).toEqual([c, b]);

        listPickerModalInstance.list = [c, b];
        document.body.appendChild(listPickerModalInstance);
        expect(listPickerModalInstance.sortedList).toEqual([c, b]);

        listPickerModalInstance.list = [a, b, c];
        document.body.appendChild(listPickerModalInstance);
        expect(listPickerModalInstance.sortedList).toEqual([a, c, b]);

        listPickerModalInstance.list = [b, a, c];
        document.body.appendChild(listPickerModalInstance);
        expect(listPickerModalInstance.sortedList).toEqual([a, c, b]);

        listPickerModalInstance.list = [c, b, a];
        document.body.appendChild(listPickerModalInstance);
        expect(listPickerModalInstance.sortedList).toEqual([c, a, b]);
    });


    it('List Picker Modal Click a Link', async () => {

        document.body.appendChild(listPickerModalInstance);

        let itemClickEventRefrence;

        // Adding Event Listner so we can determine if item click event dispatched.
        listPickerModalInstance.addEventListener('itemclick', (event) => { itemClickEventRefrence = event });

        // Verify the first link is loaded, this will be more throughly tested when focusing on pagination.
        const itemList = listPickerModalInstance.shadowRoot.querySelector('[data-id="itemList"]');
        const firstItemButton = itemList.querySelectorAll('lightning-button')[0];
        firstItemButton.click();

        // Flush Promises
        await flushPromises();

        // Verify that the item click even returns the correct id.
        expect(itemClickEventRefrence.detail).toEqual(items[0].value);

    });


    it('List Picker Modal Pagination required', async () => {

        document.body.appendChild(listPickerModalInstance);

        await flushPromises();

        //Validate Initial Values
        const itemList = listPickerModalInstance.shadowRoot.querySelector('[data-id="itemList"]');
        let itemListButtons = itemList.querySelectorAll('lightning-button');
        expect(itemListButtons.length).toEqual(PAGE_SIZE);
        expect(itemListButtons[0].label).toEqual(items[0].label);

        // Now go to page two, only one result will show here will hardcode for lack of better option.
        let paginationchangedEvent = new CustomEvent('paginationchanged', {
            'detail': '2'
        });

        const pagination = listPickerModalInstance.shadowRoot.querySelector('[data-id="listPickerPaginatior"]');
        pagination.dispatchEvent(paginationchangedEvent);

        await flushPromises();

        itemListButtons = itemList.querySelectorAll('lightning-button');
        expect(itemListButtons.length).toEqual(3);
        expect(itemListButtons[0].label).toEqual(items[2].label);

        // Back to page one again no super neccessary but why not
        paginationchangedEvent = new CustomEvent('paginationchanged', {
            'detail': '1'
        });
        pagination.dispatchEvent(paginationchangedEvent);

        await flushPromises();

        itemListButtons = itemList.querySelectorAll('lightning-button');
        expect(itemListButtons.length).toEqual(PAGE_SIZE);
        expect(itemListButtons[0].label).toEqual(items[0].label);

    });

    it('List Picker Modal Pagination not required', async () => {

        // For this test we will increase page size to prevent pagination.
        listPickerModalInstance.pageSize = 6;
        document.body.appendChild(listPickerModalInstance);

        await flushPromises();

        //All we care about for this test is checking that pagination is falsy.
        const pagination = listPickerModalInstance.shadowRoot.querySelector('[data-id="listPickerPaginatior"]');
        expect(pagination).toBeFalsy();

    });


    it('List Picker Modal Cancel Button', async () => {

        document.body.appendChild(listPickerModalInstance);

        // This variable will be used to track close event.
        let closeEventReference;

        // Create Listener for close event and verify that it is undefined before click.
        listPickerModalInstance.addEventListener('close', (event) => { closeEventReference = event });
        expect(closeEventReference).toBeUndefined();

        // Now Click the close button and verify the event is no longer undefined
        let cancelButton = listPickerModalInstance.shadowRoot.querySelector('[data-id="cancelButton"]');
        cancelButton.click();
        expect(closeEventReference).toBeDefined();

    });



});