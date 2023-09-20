export const extractName = party => {
    let name = '';
    if (party) {
        if (party.firstName && party.lastName) {
            name += party.firstName + ' ';
            if (party.middleName) {
                name += party.middleName + ' ';
            }
            name += party.lastName;
        } else if (party.fullName) {
            name += party.fullName;
        }
    }

    return name;
}

export const extractBirthday = party => {
    let birthday = '';
    if (party.birthDate) {
        birthday = party.birthDate.substring(0, 10);
    }
    return birthday;
}

const extractLicenseDate = party => {
    let license = '';
    if (party.originalLicenseDate) {
        license = party.originalLicenseDate.substring(0, 10);
    }
    return license;
}

const getDisplayDetails = (birthDate, licenseDate) => {
    if (birthDate || licenseDate) {
        const birthDateStr = birthDate ? 'Birth Date: ' + birthDate : '';
        const divider = birthDate && licenseDate ? ' | ' : '';
        const licenseDateStr = licenseDate ? 'License Date: ' + licenseDate : '';

        return birthDateStr + divider + licenseDateStr;
    }
    return '';
}

const getClientId = party => {
    let clientId = '';

    if (party && party.partyIdentifier) {
        clientId = party.partyIdentifier;
    }

    return clientId;
}

export const buildRole = (party, NAME_LENGTH) => {
    const name = extractName(party.partyName);
    const birthDate = extractBirthday(party);
    const licenseDate = extractLicenseDate(party);
    const displayDetails = getDisplayDetails(birthDate, licenseDate);
    const clientId = getClientId(party);
    const shouldDisplayDetails = birthDate ? true : (licenseDate ? true : false);
    const roleId = 'role-' + name;

    const role = {
        name,
        birthDate,
        licenseDate,
        displayDetails,
        displayName: name,
        shouldDisplayDetails,
        roleId,
        clientId,
        driverLicense: 'N/A',
        gender: 'N/A'
    }

    if (role.name && role.name.length > NAME_LENGTH) {
        role.displayName = role.name.substring(0, NAME_LENGTH) + '...';
    }

    return role;
}