const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD'
});

const valid = (value) => value === 0 || !!value;

const buildCoveragePremium = (coverage) => {
    let premium;

    if (coverage.coveragePremiumAmount) {
        premium = coverage.coveragePremiumAmount;
    }

    return premium;
}

const buildCoverageProperties = (unformattedCoverage) => {
    let coverages = {
        ratingCode: '',
        limitPerPerson: null,
        limitPerAccident: null,
        limit: null,
        aggregateLimit: null,
        glassDeductible: null,
        deductible: null,
        limitPerOccurrence: null,
        limitPerDay: null,
        limitPerWeek: null,
        limitPerMonth: null,
        limitPercentage: null,
        deathLimit: null,
        numberOfPeople: null,
        numberOfWeeks: null,
        tortOptions: null
    };

    unformattedCoverage.coverageProperty.forEach(coverageProp => {

        switch (coverageProp.systemName) {
            case 'RATE_CD':
                coverages.ratingCode = coverageProp.valueText;
                break;
            case 'LIMIT_PER_PERSON':
                coverages.limitPerPerson = coverageProp.valueNum / 1000;
                break;
            case 'LIMIT_PER_ACCIDENT':
                coverages.limitPerAccident = coverageProp.valueNum / 1000;
                break;
            case 'LIMIT_PER_MONTH':
                coverages.limitPerMonth = coverageProp.valueNum;
                break;
            case 'LIMIT':
                coverages.limit = coverageProp.valueNum;
                break;
            case 'AGGREGATE_LIMIT':
                coverages.aggregateLimit = coverageProp.valueText ? coverageProp.valueText : coverageProp.valueNum;
                break;
            case 'GLASS_DEDUCTIBLE':
                coverages.glassDeductible = coverageProp.valueNum;
                break;
            case 'DEDUCTIBLE':
                coverages.deductible = coverageProp.valueNum;
                break;
            case 'LIMIT_PER_OCCURRENCE':
                coverages.limitPerOccurrence = coverageProp.valueNum;
                break;
            case 'LIMIT_PER_DAY':
                coverages.limitPerDay = coverageProp.valueNum;
                break;
            case 'WEEKLY_DOLLAR_LIMIT':
                coverages.limitPerWeek = coverageProp.valueNum;
                break;
            case 'LIMIT_PERCENTAGE':
                coverages.limitPercentage = coverageProp.valueNum;
                break;
            case 'DEATH_LIMIT':
                coverages.deathLimit = coverageProp.valueNum;
                break;
            case 'NUMBER_OF_PEOPLE':
                coverages.numberOfPeople = coverageProp.valueNum;
                break;
            case 'NUMBER_OF_WEEKS':
                coverages.numberOfWeeks = coverageProp.valueNum;
                break;
            case 'TORT_OPTIONS':
                coverages.tortOptions = coverageProp.valueText;
                break;
            default:
                break;
        }
    });

    return coverages;
}

// To eliminate codescan violations from sonarQube, formatCoverages has been divided into 3 parts. 
const formatCoverages0 = (coverageProps) => {
    let coverageStrip = '';
    let value = '';
    let deductible = '';

    if (valid(coverageProps.limitPerPerson) && valid(coverageProps.limitPerAccident)) {
        coverageStrip += ' ' + coverageProps.limitPerPerson + '/' + coverageProps.limitPerAccident;
        value = formatter.format(coverageProps.limitPerPerson * 1000) + '/person, ' + formatter.format(coverageProps.limitPerAccident * 1000) + '/accident';

    } else if (valid(coverageProps.limitPerWeek) && valid(coverageProps.limitPerAccident)) {
        coverageStrip += ' ' + coverageProps.limitPerWeek + '/' + coverageProps.limitPerAccident;
        value = formatter.format(coverageProps.limitPerWeek) + '/week, ' + formatter.format(coverageProps.limitPerAccident * 1000) + '/accident';

    } else if (valid(coverageProps.limitPerAccident) && valid(coverageProps.deductible)) {
        coverageStrip += ' ' + coverageProps.deductible + '/' + coverageProps.limitPerAccident;
        value = formatter.format(coverageProps.limitPerAccident * 1000) + '/accident';
        deductible = formatter.format(coverageProps.deductible);

    } else if (valid(coverageProps.aggregateLimit) && valid(coverageProps.deductible)) {
        coverageStrip += ' ' + coverageProps.deductible + '/' + coverageProps.aggregateLimit;
        deductible = formatter.format(coverageProps.deductible);
        value = Number.isInteger(coverageProps.aggregateLimit) ? formatter.format(coverageProps.aggregateLimit) : coverageProps.aggregateLimit;

    } else if (valid(coverageProps.aggregateLimit) && valid(coverageProps.limitPerDay)) {
        coverageStrip += ' ' + coverageProps.limitPerDay + '/' + coverageProps.aggregateLimit;
        value = formatter.format(coverageProps.limitPerDay) + '/day, ' +
            (Number.isInteger(coverageProps.aggregateLimit) ? formatter.format(coverageProps.aggregateLimit) : coverageProps.aggregateLimit);

    }

    return { coverageStrip, value, deductible };
}

const formatCoverages1 = (coverageProps) => {
    let coverageStrip = '';
    let value = '';
    let deductible = '';

    if (valid(coverageProps.glassDeductible) && valid(coverageProps.deductible)) {
        coverageStrip += ' ' + coverageProps.deductible;
        deductible = formatter.format(coverageProps.deductible);

    } else if (valid(coverageProps.numberOfWeeks) && valid(coverageProps.limitPerDay)) {
        coverageStrip += ' ' + coverageProps.limitPerDay + '/' + coverageProps.numberOfWeeks;
        value = formatter.format(coverageProps.limitPerDay) + '/day, ' + coverageProps.numberOfWeeks + ' weeks';

    } else if (valid(coverageProps.numberOfWeeks) && valid(coverageProps.limitPerMonth)) {
        coverageStrip += ' ' + coverageProps.limitPerMonth + '/' + coverageProps.numberOfWeeks;
        value = formatter.format(coverageProps.limitPerMonth) + '/month, ' + coverageProps.numberOfWeeks + ' weeks';

    } else if (valid(coverageProps.limitPerOccurrence) && valid(coverageProps.limitPerDay)) {
        coverageStrip += ' ' + coverageProps.limitPerDay + '/' + coverageProps.limitPerOccurrence;
        value = formatter.format(coverageProps.limitPerDay) + '/day, ' + formatter.format(coverageProps.limitPerOccurrence) + '/occurrence';

    } else if (valid(coverageProps.limitPerOccurrence) && valid(coverageProps.limitPercentage)) {
        coverageStrip += ' ' + coverageProps.limitPercentage + '%/' + coverageProps.limitPerOccurrence;
        value = coverageProps.limitPercentage + '%, ' + formatter.format(coverageProps.limitPerOccurrence) + '/occurrence';

    } else if (valid(coverageProps.deathLimit) && valid(coverageProps.numberOfPeople)) {
        coverageStrip += ' ' + coverageProps.deathLimit;
        value = formatter.format(coverageProps.deathLimit) + '/death, ' + coverageProps.numberOfPeople + ' people';

    }

    return { coverageStrip, value, deductible };
}

const formatCoverages2 = (coverageProps) => {
    let coverageStrip = '';
    let value = '';
    let deductible = '';

    if (valid(coverageProps.limitPerAccident)) {
        coverageStrip += ' ' + coverageProps.limitPerAccident;
        value = formatter.format(coverageProps.limitPerAccident * 1000) + '/accident';

    } else if (valid(coverageProps.limitPerPerson)) {
        coverageStrip += ' ' + coverageProps.limitPerPerson * 1000;
        value = formatter.format(coverageProps.limitPerPerson * 1000) + '/person';

    } else if (valid(coverageProps.limit)) {
        coverageStrip += ' ' + coverageProps.limit;
        value = formatter.format(coverageProps.limit);

    } else if (valid(coverageProps.aggregateLimit)) {
        coverageStrip += ' ' + coverageProps.aggregateLimit;
        value = Number.isInteger(coverageProps.aggregateLimit) ? formatter.format(coverageProps.aggregateLimit) : coverageProps.aggregateLimit;

    } else if (valid(coverageProps.glassDeductible)) {
        coverageStrip += ' ' + coverageProps.glassDeductible;
        deductible = formatter.format(coverageProps.glassDeductible);

    } else if (valid(coverageProps.deductible)) {
        coverageStrip += ' ' + coverageProps.deductible;
        deductible = formatter.format(coverageProps.deductible);

    } else if (valid(coverageProps.tortOptions)) {
        coverageStrip += ' ' + coverageProps.tortOptions + ' TORT';
        value = coverageProps.tortOptions;

    }

    return { coverageStrip, value, deductible };
}

export const buildAutoCoverages = (coverages) => {
    let coverageText = '';
    let formattedCoverages = [];
    let totalPremium = 0;

    const filteredCoverages = coverages.filter(coverage => coverage.name && coverage.abbreviation);

    filteredCoverages.forEach((coverage, index) => {

        const coverageProps = buildCoverageProperties(coverage);

        let formattedData;
        formattedData = formatCoverages0(coverageProps);
        if (!formattedData.coverageStrip && !formattedData.value && !formattedData.deductible) {
            formattedData = formatCoverages1(coverageProps);
            if (!formattedData.coverageStrip && !formattedData.value && !formattedData.deductible) {
                formattedData = formatCoverages2(coverageProps);
            }
        }

        const premium = buildCoveragePremium(coverage);
        totalPremium += premium ? premium : 0;

        coverageText += coverage.abbreviation + formattedData.coverageStrip;

        if (index + 1 < filteredCoverages.length) {
            coverageText += ', ';
        }

        formattedCoverages.push({
            name: coverage.name,
            abbreviation: coverage.abbreviation,
            ratingCode: coverageProps.ratingCode,
            value: formattedData.value,
            deductible: formattedData.deductible,
            premium
        });

        if (Number.isInteger(coverageProps.glassDeductible)) {
            formattedCoverages.push({
                name: 'Glass Coverage',
                abbreviation: coverage.abbreviation,
                ratingCode: '',
                value: '',
                deductible: formatter.format(coverageProps.glassDeductible)
            });
        }
    });

    totalPremium = totalPremium.toFixed(2);

    return { coverageText, formattedCoverages, totalPremium };
}