class Ingredient {
    constructor(referenceValue, reference){
        this.referenceValue = this.getDecimalValue(referenceValue);
        this.reference = reference;
    }

    getServingsValue(newServing, oldServing){
        if(isNaN(this.referenceValue)){
            return null;
        }

        return this.referenceValue * newServing / oldServing;
    }

    calcAndRenderNewServingsValue(newServing, oldServing){
        const newServingsValue = this.trimValue(this.getServingsValue(newServing, oldServing));

        if(newServingsValue != null){
            this.reference.innerHTML = newServingsValue.toString().includes(".")
                ? this.decimalToFraction(newServingsValue)
                : newServingsValue;
        }
    }

    // "45 1/3" -> "45" (level of precision hinders understanding)
    trimValue(servingsValue){
        if(this.referenceValue >= 10){
            return servingsValue.toFixed(0);
        }
        return servingsValue;
    }

    toString(){
        return "value: " + this.referenceValue + ", reference html: " + this.reference.innerHTML;
    }

    // from: http://jsfiddle.net/5QrhQ/5/ or https://stackoverflow.com/a/23575406
    decimalToFraction(decimal){
        var len = decimal.toString().length - 2;
        
        var denominator = Math.pow(10, len);
        var numerator = decimal * denominator;
        
        var divisor = this.gcd(numerator, denominator);    
        
        numerator /= divisor;
        denominator /= divisor; 

        return numerator > denominator 
            ? Math.floor(numerator / denominator) + " " + numerator % denominator + '/' + Math.floor(denominator)
            : Math.floor(numerator) + '/' + Math.floor(denominator);
    }
    gcd(a, b) {
        if (b < 0.0000001) return a;                // Since there is a limited precision we need to limit the value.
    
        return this.gcd(b, Math.floor(a % b));           // Discard any fractions due to limitations in precision.
    };
    getDecimalValue(value){
        return value.includes("/")
            ? this.fractionToDecimal(value)
            : Number.parseFloat(value);
    } 
    // from https://stackoverflow.com/a/49246271 
    fractionToDecimal(fraction) {
        const actualFraction = this.expandedFractionToSimple(fraction);    
    
        return actualFraction
          .split('/')
          .reduce((numerator, denominator, i) =>
            numerator / (i ? denominator : 1)
          );
    }
    expandedFractionToSimple(fraction){
        if(fraction.includes(" ")){
            factorSplit = fraction.split(" ");
            factor = factorSplit[0];
            
            fractionSplit = factorSplit[1].split("/");
            numerator = fractionSplit[0];
            denominator = fractionSplit[1];
            
            return ((Number.parseInt(factor) * Number.parseInt(denominator)) + Number.parseInt(numerator)) + "/" + Number.parseInt(denominator);
        }    
        return fraction;
    }

}

let ingredients = [];
// create a Ingredient Element for every HTML ELement
const ingredientHTMLElements = document.querySelectorAll('tr > td:first-child');
ingredientHTMLElements.forEach((ingredient) => ingredients.push(new Ingredient(ingredient.innerHTML, ingredient)));


const servingsInput = document.querySelector('input#servings_number');
var referenceServings = servingsInput.value;

/// react to servings input
servingsInput.addEventListener("change", calculateServings);
function calculateServings(){
    const newPortion = servingsInput.value;

    for (var i = 0; i  < ingredients.length; i++) {
        ingredients[i].calcAndRenderNewServingsValue(newPortion, referenceServings);
    }
}