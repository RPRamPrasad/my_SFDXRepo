import { LightningElement,api } from 'lwc';
export default class SobjectRowDisplay extends LightningElement  {

    @api
    title
    @api
    titleIconName
    @api
    titleIconSize
    @api
    sobjectName
    @api
    fieldData
    @api
    numberOfRows
    @api
    viewAllNavigationPayload
    @api
    noRowsFoundMessage
    @api
    queryFilterCriteria
}