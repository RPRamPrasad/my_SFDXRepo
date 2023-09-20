import { LightningElement, api } from 'lwc';
export default class CaseRowDisplay extends LightningElement {


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
        this.title = 'Cases';
        this.titleIconName = 'standard:case';
        this.titleIconSize ='large';
        this.sobjectName = 'Case';
        this.fieldData = [{ fieldName: 'CaseNumber', fieldLabel: 'Case Number', hyperlinkToSobjectFieldName: 'Id' },
        { fieldName: 'Assigned_To__r.Name', fieldLabel: 'Assigned To'},
        { fieldName: 'Status', fieldLabel: 'Status' },
        { fieldName: 'Subject', fieldLabel: 'Subject' },
        { fieldName: 'Priority', fieldLabel: 'Priority' }
        ];

        this.viewAllNavigationPayload = {
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.accountId,
                objectApiName: 'Account',
                relationshipApiName: 'Cases',
                actionName: 'view'
            }
        };
        this.noRowsFoundMessage = 'No cases were found';

        this.queryFilterCriteria = [{
            enable: true,
            filterFieldName: 'AccountId',
            queryNullValues: false,
            filterValues: [this.accountId],
            filterType: 'LIST_OF_STRING'
        }];
    }

}