const USER_DIAL_PREFERENCE = {
    elevenDigits: '11',
    tenDigits: '10',
    sevenDigits: '7'
}

const removeNonDigits = (phoneNumber) => {
    return phoneNumber.replace(/\D/g,'');
}

const formatPhoneForSevenDigits = (phoneNumber) => {
    return phoneNumber.slice(-7);
}

const formatPhoneForTenDigits = (phoneNumber) => {
    return phoneNumber.slice(-10);
}

const formatPhoneForElevenDigits = (phoneNumber) => {
    if (phoneNumber.length === 10) {
        return "1" + phoneNumber;
    }

    return phoneNumber;
}

const formatPhoneNumberForUserPreference = (userPreference, phoneNumber) => {

    const digitsOnlyPhoneNumber = removeNonDigits(phoneNumber);

    switch (userPreference.clickToDialPreference) {
        case USER_DIAL_PREFERENCE.sevenDigits:
            return formatPhoneForSevenDigits(digitsOnlyPhoneNumber);
        case USER_DIAL_PREFERENCE.tenDigits:
            return formatPhoneForTenDigits(digitsOnlyPhoneNumber);
        default:
            return formatPhoneForElevenDigits(digitsOnlyPhoneNumber);
    }
}

export { 
    USER_DIAL_PREFERENCE,
    formatPhoneNumberForUserPreference
};

