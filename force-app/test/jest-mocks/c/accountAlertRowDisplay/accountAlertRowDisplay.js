import { LightningElement, api } from 'lwc';
export default class AccountAlertRowDisplay extends LightningElement {

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
        this.title = 'Account Alerts';
        this.titleIconName = 'custom:custom53';
        this.titleIconSize = 'large';
        this.sobjectName = 'Account_Note__c';
        this.fieldData = [{ fieldName: 'Name', fieldLabel: 'Name', hyperlinkToSobjectFieldName: 'Id' },
        { fieldName: 'Comments__c', fieldLabel: 'Comments'},
        { fieldName: 'FORMAT(CreatedDate)', fieldLabel: 'Created Date' },
        { fieldName: 'CreatedBy.Name', fieldLabel: 'Created By' }
        ];
        //name, assigned to, stage, lob
        this.viewAllNavigationPayload = {
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.accountId,
                objectApiName: 'Account',
                relationshipApiName: 'Account_Notes__r',
                actionName: 'view'
            }
        };
        this.noRowsFoundMessage = 'No account alerts were found';

        this.queryFilterCriteria = [{
            enable: true,
            filterFieldName: 'Account__c',
            queryNullValues: false,
            filterValues: [this.accountId],
            filterType: 'LIST_OF_STRING'
        },{
            enable: true,
            filterFieldName: 'Alert__c',
            queryNullValues: false,
            filterValue: true,
            filterType: 'BOOLEAN'
        }];
    }

}