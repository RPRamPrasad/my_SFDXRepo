import LightningDatatable from 'lightning/datatable';
import urlLinkListCell from './urlLinkListCell.html';
import billingButtonSfpp from './billingButtonSfpp.html';
import billingButtonSfBilling from './billingButtonSfBilling.html';
import billingStatus from './billingStatus.html';
import billingLobInfoHover from './billingLobInfoHover.html';

export default class BillingTable extends LightningDatatable {
    static customTypes = {
        urlLinkList: {
            template: urlLinkListCell
        },
        sfppButton: {
            template: billingButtonSfpp,
            typeAttributes: ['billingAccountNumber', 'stateAgentCode', 'status']
        },
        sfBillingButton: {
            template: billingButtonSfBilling,
            typeAttributes: ['billingAccountNumber', 'billingAccountUrl', 'billingAccountUrlDescription']
        },
        accountStatus: {
            template: billingStatus,
            typeAttributes: ['billingStatus', 'cancellationDate', 'accountType']
        }, 
        infoHover: {
            template: billingLobInfoHover,
            typeAttributes: ['displayValue','displayType', 'hoverText']
        }
    };
}
