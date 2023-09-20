import { LightningElement, api } from 'lwc';
export default class SimpleConversationRowDisplay extends LightningElement {
    @api
    accountId;

    @api
    get numberOfRows() {
        return this.numberOfRowsHolder;
    }

    set numberOfRows(value) {
        this.numberOfRowsHolder = value;
        this.setValues();
    }
    
    setValues(){
        this.title = 'Simple Conversation';
        this.titleIconName = 'custom:custom112';
        this.titleIconSize ='large';
        this.sobjectName = 'SimpleConversation__c';
        this.fieldData = [{ fieldName: 'Name', fieldLabel: 'Name', hyperlinkToSobjectFieldName: 'Id'},
            { fieldName: 'AppointmentStartDateTime__c', fieldLabel: 'Start Time'},
            { fieldName: 'AppointmentEndDateTime__c', fieldLabel: 'End Time' },
            { fieldName: 'Status__c', fieldLabel: 'Status'},
            { fieldName: 'ConductedBy__r.Name', fieldLabel: 'Conducted By'},
        ];

        this.viewAllNavigationPayload = {
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.accountId,
                objectApiName: 'Account',
                relationshipApiName: 'Simple_Conversations__r',
                actionName: 'view'
            }
        };
    
        this.noRowsFoundMessage = 'No simple conversations were found';

        this.queryFilterCriteria = [{
            enable: true,
            filterFieldName: 'Account__c',
            queryNullValues: false,
            filterValues: [this.accountId],
            filterType: 'LIST_OF_STRING'
        }];
    }
}