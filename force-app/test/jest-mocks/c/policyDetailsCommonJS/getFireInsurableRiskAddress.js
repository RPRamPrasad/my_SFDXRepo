export const getFireInsurableRiskAddress = insurableRisk => {
    let address = 'N/A';

    if (insurableRisk.riskLocation && insurableRisk.riskLocation.postalAddress) {
        const { postalAddress } = insurableRisk.riskLocation;

        address = postalAddress.fullStreetAddressText + '\n' + postalAddress.cityName + ', ' + postalAddress.postalStateCode;
    }

    return address;
}