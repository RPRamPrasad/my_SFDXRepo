export default function distributeEvenly(numberToDistibuteTo, numberOfItemsToDistribute) {
    let values = [];
    let mod = numberOfItemsToDistribute % numberToDistibuteTo;
    
    let value = (numberOfItemsToDistribute - mod) / numberToDistibuteTo;
    values = Array(numberToDistibuteTo).fill(value);

    for(let i=0;i<mod;i++){
        values[i] = values[i] + 1;
    }
    

    return values;
}