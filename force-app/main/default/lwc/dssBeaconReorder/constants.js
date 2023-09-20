export const DSS_INACTIVE_ERROR_CODE = 'DSS_NOT_ACTIVE';
export const NO_ENROLLMENT_DATE_ERROR_CODE = 'NO_ENROLLMENT_DATE';
export const INCORRECT_PRODUCT_CODE_ERROR_CODE = 'INCORRECT_PRODUCT_CODE';
export const BEACON_SHIPPED_ERROR_CODE = 'BEACON_SHIPPED_LAST_10_DAYS';
export const CCC_BEACON_SHIPPED_ERROR_CODE = 'CCC_BEACON_SHIPPED_LAST_10_DAYS';
export const TECHNICAL_ERROR_CODE = 'TECHNICAL_ERROR';
export const CCC_TECHNICAL_ERROR_CODE = 'CCC_TECHNICAL_ERROR';


// modal body content
export const PAGE_1_BODY = '<p>First, a review is necessary to determine if a reorder is required. Once completed, if a new beacon is needed, a request will be submitted to have a new beacon shipped to the customer. Support is available in case any error occurs along the way.</p><br /><br /><p>Does the Customer currently have a beacon?</p>';

export const PAGE_2_BODY = "<p>Before submitting this request, let's try some self help steps to see if we can get the original beacon working.</p>"
                         + "<br />"
                         + "<p>Please try to lightly shake the device and hold the button down on the beacon for 5-8 seconds.</p>"
                         + "<ul>"
                            + "<li>If the light illuminates*, then the beacon battery is not dead, continue to pair the device.</li>"
                            + "<p><small>*Ask the Customer to restart their phone. If it still does not pair, turn off Bluetooth and then back on to try to pair the beacon</small></p>"
                            + "<li>If the light is continuously is blinking, the device is defective and a new beacon should be ordered</li>"
                            + "<li>If the beacon light does not illuminate after the troubleshooting suggested above, please proceed to order the customer a new beacon.</li>"
                         + "</ul>"
                         + "<p><small>*The light on the beacon only illuminates for a few moments, then turns off to conserve battery life.</small></p>";

export const PAGE_3_BODY = '<p>Why does a new beacon need to be ordered?</p>';

export const PAGE_4_BODY = "<p>Verify the address below is correct for shipping the new beacon.</p>"
                         + "<br />"
                         + "<p>Mailing Address:</p>"
                         + "<br />";

// error codes
export const PAGE_30_BODY = '<p>This vehicle is not currently enrolled in Drive Safe & Save™ Mobile. You may need to check pending policy transactions or submit a new request. Note: Customer consent is required to add the discount to the policy.</p>';
export const PAGE_31_BODY = '<p>A beacon has been shipped within the last 10 days. Please review the tracking information, and request support below if a beacon is still needed.</p>';
export const PAGE_32_BODY = '<p>The customer must complete the enrollment steps in the Drive Safe & Save™ app, which includes ordering a beacon.</p>';
export const PAGE_33_BODY = '<p>The customer is not currently enrolled in Drive Safe & Save™ Mobile that requires a beacon.</p>'; //NEEDS MMR VALIDATION
export const PAGE_99_BODY = '<p>A technical error has occurred. Please request support below to initiate the reorder process.</p>';
export const PAGE_100_BODY = `<p>This workflow is unavailable. To continue to process your request, please follow the beacon reorder process using the <a href="/apex/VFP_ExternalLink?LinkId=215&accountId=undefined" target="_blank" data-id="popDSSLink">Drive Safe & Save Beacon Reorder tool</a> in ECRM. Refer to procedural resources to confirm process and beacon eligibility.</p>`;
export const PAGE_101_BODY = `<p>A beacon has been shipped in the last 10 days. Please confirm shipping status inside the Drive Safe & Save Beacon Status tool and verify the customer still needs a beacon sent. If one is needed, then follow the beacon reorder process using the <a href="/apex/VFP_ExternalLink?LinkId=215&accountId=undefined" target="_blank" data-id="popDSSLink">Drive Safe & Save Beacon Reorder tool</a> in ECRM.</p>`;

export const REORDER_REASONS = [
    { label: 'Customer did not receive beacon package', value: 'A-Did not receive beacon package'},
    { label: 'Customer left beacon in prior vehicle or beacon is damaged', value: 'A-Beacon left in prior vehicle or damaged'},
    { label: 'Customer does not have beacon but USPS tracking shows package delivered', value: 'A-Does not have beacon but shows as delivered'},
    { label: 'Beacon light will not turn on', value: 'A-Beacon light will not turn on'},
];
export const REORDER_REASONS_CCC = [
    { label: 'Customer did not receive beacon package', value: 'C-Did not receive beacon package'},
    { label: 'Customer left beacon in prior vehicle or beacon is damaged', value: 'C-Beacon left in prior vehicle or damaged'},
    { label: 'Customer does not have beacon but USPS tracking shows package delivered', value: 'C-Does not have beacon but shows as delivered'},
    { label: 'Beacon light will not turn on', value: 'C-Beacon light will not turn on'},
];