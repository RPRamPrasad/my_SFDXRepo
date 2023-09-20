export const getAutoInsurableRiskAddress = insurableRisk => {
    let address = 'N/A';

    if (insurableRisk.autoInsurableRiskLocation && insurableRisk.autoInsurableRiskLocation.postalAddress) {
        const { postalAddress } = insurableRisk.autoInsurableRiskLocation;

        address = postalAddress.fullStreetAddressText + '\n' + postalAddress.cityName + ', ' + postalAddress.postalStateCode;
    }

    return address;
}