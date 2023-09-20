import { LightningElement, api } from 'lwc';
export default class OpportunityRowDisplay extends LightningElement {


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
        this.title = 'Opportunities';
        this.titleIconName = 'standard:opportunity';
        this.titleIconSize = 'large';
        this.sobjectName = 'Opportunity';
        this.fieldData = [{ fieldName: 'Name', fieldLabel: 'Name', hyperlinkToSobjectFieldName: 'Id' },
        { fieldName: 'Assigned_To__r.Name', fieldLabel: 'Assigned To' },
        { fieldName: 'Product__c', fieldLabel: 'Product' },
        { fieldName: 'StageName', fieldLabel: 'Stage' },
        { fieldName: 'Total_Calls_Made__c', fieldLabel: 'Total Contacts Made' }
        ];
        //name, assigned to, stage, lob
        this.viewAllNavigationPayload = {
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.accountId,
                objectApiName: 'Account',
                relationshipApiName: 'Opportunities',
                actionName: 'view'
            }
        };
        this.noRowsFoundMessage = 'No opportunities were found';

        this.queryFilterCriteria = [{
            enable: true,
            filterFieldName: 'AccountId',
            queryNullValues: false,
            filterValues: [this.accountId],
            filterType: 'LIST_OF_STRING'
        }];
    }

}