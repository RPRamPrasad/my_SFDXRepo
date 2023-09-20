export function sortUserByName(a, b){
    var nameA = a.Name.toUpperCase();
    var nameB = b.Name.toUpperCase(); 
    if (nameA < nameB) {
        return -1;
    }
    if (nameA > nameB) {
        return 1;
    }

    return 0; 
}

export function sortUsersByCurrentUserIsActiveAndName(a,b) {
    if (a.IsCurrentUser) {
        return -1;
    } else if (b.IsCurrentUser) {
        return 1;
    } else if (a.IsActive && !b.IsActive) {
        return -1;
    } else if (!a.IsActive && b.IsActive) {
        return 1;
    }

    let aName = a.Name.toLowerCase();
    let bName = b.Name.toLowerCase();

    if (aName < bName) {
        return -1;
    } else if (aName > bName) {
        return 1;
    }

    return 0;
}