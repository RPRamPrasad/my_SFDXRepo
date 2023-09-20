import { DSS_INACTIVE_ERROR_CODE, NO_ENROLLMENT_DATE_ERROR_CODE, INCORRECT_PRODUCT_CODE_ERROR_CODE, BEACON_SHIPPED_ERROR_CODE,CCC_BEACON_SHIPPED_ERROR_CODE,TECHNICAL_ERROR_CODE,CCC_TECHNICAL_ERROR_CODE, PAGE_1_BODY, PAGE_2_BODY, PAGE_3_BODY, PAGE_4_BODY, PAGE_30_BODY, PAGE_31_BODY, PAGE_32_BODY, PAGE_33_BODY,PAGE_99_BODY,PAGE_100_BODY,PAGE_101_BODY } from './constants';

const modalBodyContent = [
    { pageId: 0, bodyHTML: PAGE_1_BODY, showContinue: false, showPrevious: false, showSubmit: false, showReasons: false, showYesNo: true, showAddress: false, showSpinner: false, errorPage: false },
    { pageId: 1, bodyHTML: PAGE_2_BODY, showContinue: true, showPrevious: true, showSubmit: false, showReasons: false, showYesNo: false, showAddress: false, showSpinner: false, errorPage: false },
    { pageId: 2, bodyHTML: PAGE_3_BODY, showContinue: true, showPrevious: true, showSubmit: false, showReasons: true, showYesNo: false, showAddress: false, showSpinner: false, errorPage: false },
    { pageId: 3, bodyHTML: PAGE_4_BODY, showContinue: false, showPrevious: true, showSubmit: true, showReasons: false, showYesNo: false, showAddress: true, showSpinner: true, errorPage: false },
    { pageId: 30, bodyHTML: PAGE_30_BODY, showContinue: false, showPrevious: false, showSubmit: false, showSpinner: false, errorPage: true, showReqSupport: false, errorCode: DSS_INACTIVE_ERROR_CODE },
    { pageId: 31, bodyHTML: PAGE_31_BODY, showContinue: false, showPrevious: false, showSubmit: false, errorPage: true, showSpinner: true, showReqSupport: true, errorCode: BEACON_SHIPPED_ERROR_CODE },
    { pageId: 32, bodyHTML: PAGE_32_BODY, showContinue: false, showPrevious: false, showSubmit: false, showSpinner: false, showReqSupport: false, errorPage: true, errorCode: NO_ENROLLMENT_DATE_ERROR_CODE },
    { pageId: 33, bodyHTML: PAGE_33_BODY, showContinue: false, showPrevious: false, showSubmit: false, showSpinner: false, errorPage: true, showReqSupport: false, errorCode: INCORRECT_PRODUCT_CODE_ERROR_CODE },
    { pageId: 99, bodyHTML: PAGE_99_BODY, showContinue: false, showPrevious: false, showSubmit: false, showSpinner: true, errorPage: true, showReqSupport: true, errorCode: TECHNICAL_ERROR_CODE },
    { pageId: 100, bodyHTML: PAGE_100_BODY, showContinue: false, showPrevious: false, showSubmit: false, showSpinner: true, errorPage: true, showReqSupport: false, errorCode: CCC_TECHNICAL_ERROR_CODE },
    { pageId: 101, bodyHTML: PAGE_101_BODY, showContinue: false, showPrevious: false, showSubmit: false, errorPage: true, showSpinner: true, showReqSupport: false, errorCode: CCC_BEACON_SHIPPED_ERROR_CODE }

];

// const errorCodePages = { 'DSS_NOT_ACTIVE': 30, 'BEACON_SHIPPED_LAST_7_DAYS': 31 };
// const errorCodeSupportElements = { 'HERCULES_CHAT': 30, 'ACMT_CASE': 31 };

export const getPageByPageId = pageIndex => {
    return modalBodyContent.find(page => page.pageId === pageIndex);
}

export const getPageByErrorCode = errorCode => {
    // find specific page content associated to error and return page ID
    const errorPage = modalBodyContent.find(page => page.errorCode === errorCode);
    // determine which HTML elements need to show - errorCodeSupportElements
    return errorPage.pageId;
}