javascript: (() => {
    let mapping = [];
    document.querySelectorAll(".BudgetItemRow-content").forEach((el, index) => {
        const name = el.querySelectorAll(".BudgetItem-label input")[0].value;
        const integer = el.querySelector(".money-integer").innerHTML;
        const fractional = el.querySelector(".money-fractional").innerHTML;
        
        mapping.push(`${name},${integer}.${fractional}`);
    });

    console.log(mapping);
})();