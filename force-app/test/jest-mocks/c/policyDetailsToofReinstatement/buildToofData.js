import { formatDate } from 'c/policyDetailsCommonJS';

export const buildToofDate = details => {

    let toofList = [];

    if (details.timeOutOfForces?.length) {
        const timeOutOfForcesList = details.timeOutOfForces;

        timeOutOfForcesList
            .filter(getToofDates => getToofDates.timeOutOfForceStartDate || getToofDates.timeOutOfForceEndDate)
            .forEach(getToofDates => {
                let toofDate;
                let startDate;
                let endDate;

                if (toofList.length < 5) {
                    if (getToofDates.timeOutOfForceStartDate && getToofDates.timeOutOfForceEndDate) {
                        startDate = formatDate(getToofDates.timeOutOfForceStartDate);
                        endDate = formatDate(getToofDates.timeOutOfForceEndDate);
                        toofDate = startDate + ' to ' + endDate;

                    } else if (getToofDates.timeOutOfForceStartDate) {
                        toofDate = formatDate(getToofDates.timeOutOfForceStartDate);
                    }

                    if (toofDate) {
                        toofList.push(toofDate);
                    }
                }
            });
    }

    return toofList;
}

export const buildToofSource = details => {
    let toofSourceName;

    if (details.timeOutOfForces?.length && details.timeOutOfForces[0].timeOutOfForceCancellationSourceName) {
        toofSourceName = details.timeOutOfForces[0].timeOutOfForceCancellationSourceName;

        if (details.timeOutOfForces[0].timeOutOfForceCancellationReasonText) {
            toofSourceName = toofSourceName + ' - ' + details.timeOutOfForces[0].timeOutOfForceCancellationReasonText;
        }
    }

    return toofSourceName;
}

export const buildAppDate = details => {
    let appDate;

    if (details.reinstatementApplicationDate) {        
        appDate = formatDate(details.reinstatementApplicationDate);
    }

    return appDate;
}