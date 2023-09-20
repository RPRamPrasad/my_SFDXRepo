const CONSENT_STATE_LIST = ['IL','CA','CO'];
export default function calculateRequestedEndDate(requestedEndDate, billingState) {
    if (CONSENT_STATE_LIST.includes(billingState)) {
      requestedEndDate = new Date(
        requestedEndDate.setDate(requestedEndDate.getDate() + 29)
      );
    } else {
      requestedEndDate = new Date(
        requestedEndDate.setDate(requestedEndDate.getDate() + 89)
      );
    }
    return requestedEndDate;
  }