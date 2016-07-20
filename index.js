// ---
// target: includes/contributor/_index.md
// ---
// ## Module Exports
//
// The `groc` module exports the `CLI` interface.

// Register the CoffeeScript compiler
require('coffee-script/register');

// Declare the interfaces exported
module.exports = {
  CLI:          require('./lib/cli'),
};
