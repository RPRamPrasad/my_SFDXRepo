const PROTOCOL = {
    mobile: 'tel:',
    ciscoTel: 'ciscotel:'
}

const MOBILE_THEME = 'theme4t';

const getBaseUrl = (userPreference) => {
    if (userPreference.theme && 
            MOBILE_THEME === userPreference.theme.toLowerCase()) {
        return PROTOCOL.mobile;
    }

    return PROTOCOL.ciscoTel;
}

export {
    getBaseUrl
}