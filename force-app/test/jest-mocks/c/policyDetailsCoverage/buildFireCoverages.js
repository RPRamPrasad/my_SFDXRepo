const formatter = new Intl.NumberFormat('en-US', {style: 'currency', currency: 'USD'});

const textOrNumCurrency = prop => {
    return prop.valueText ? prop.valueText : formatter.format(prop.valueNum);
}

const textOrNum = prop => {
    return prop.valueText ? prop.valueText : prop.valueNum;
}

const buildCoveragePremium = (coverage) => {
    let premium;

    if (coverage.coveragePremiumAmount) {
        premium = coverage.coveragePremiumAmount;
    }

    return premium;
}

const buildLimitVal = (prop, limitVal) => {
    return `${limitVal}${prop?.valueText ? `${prop.valueText}, ` : (prop?.valueNum ? `${prop.valueNum}, ` : '')}`;
}

export const readPropLimits = (prop, limitVal = '', dedVal = '') => {
    if (prop?.name === 'Limit Per Person') {
        limitVal = `${limitVal}${textOrNumCurrency(prop)}/person, `;
    } else if (prop?.name === 'Limit Per Occurrence') {
        limitVal = `${limitVal}${textOrNumCurrency(prop)}/occurrence, `;
    } else if (prop?.name === 'Limit Per Employee') {
        limitVal = `${limitVal}${textOrNumCurrency(prop)}/employee, `;
    } else if (prop?.name === 'Limit Percentage') {
        limitVal = `${limitVal}${textOrNum(prop)}%, `;
    } else if (prop?.name === 'Limit Basis') {
        limitVal = `${limitVal}${textOrNum(prop)}, `;
    } else if (prop?.name === 'Annual Aggregate Limit') {
        limitVal = `${limitVal}${textOrNumCurrency(prop)} aggregate, `;
    } else if (prop?.name === 'Deductible Percentage') {
        dedVal = `${dedVal}${textOrNum(prop)}%, `.replace('%%', '%'); 
    } else if (prop?.name === 'Deductible Per Occurrence') {
        dedVal = `${dedVal}${textOrNumCurrency(prop)}, `;
    } else if (prop?.name === 'Collision Deductible') {
        dedVal = `${dedVal}${textOrNumCurrency(prop)}, `;
    } else if (prop?.name === 'Duration Period') {
        limitVal = `${limitVal}${textOrNum(prop)} days, `;
    } else if (prop?.name === 'On Premises Limit') {
        limitVal = `${limitVal}${formatter.format(prop.valueNum)} on premises, `;
    } else if (prop?.name === 'Off Premises Limit') {
        limitVal = `${limitVal}${formatter.format(prop.valueNum)} off premises, `;
    } else if (prop?.name === 'Limit Days') {
        limitVal = `${limitVal}${prop.valueNum} days, `;
    } else {
        limitVal = buildLimitVal(prop, limitVal);
    }

    return { limitVal, dedVal }; 
}

const buildPropValues = (coverage) => {
    let limitVal = '';
    let dedVal = '';

    if (coverage.coverageProperty) {
        for (const prop of coverage.coverageProperty) {
            if (prop.name) {
                ({ limitVal, dedVal } = readPropLimits(prop, limitVal, dedVal));
            }
        }
    }

    return { limitVal, dedVal };
}

export const buildFireCoverages = coverages => {
    const coverageData = [];

    for (const coverage of coverages) {
        let coverageRow = {
            abbreviation: ''
        };
        
        if (coverage.name) {
            coverageRow.name = coverage.name;
        
            if (coverage.abbreviation) {
                coverageRow.abbreviation = coverage.abbreviation;
            }

            let { limitVal, dedVal } = buildPropValues(coverage);

            // Take off the last comma and space from each
            if (limitVal) {
                limitVal = limitVal.slice(0, -2);
            }

            if (dedVal) {
                dedVal = dedVal.slice(0, -2);
            }

            coverageRow.value = limitVal;
            coverageRow.deductible = dedVal;

            const premium = buildCoveragePremium(coverage);
            coverageRow.premium = premium;
            
            coverageData.push(coverageRow);
        }
    }

    return coverageData;
}