'use strict';

/**
 * Main Browserify bundle source; gets compiled to bundle.js and can be required
 * using: require('wincent').
 */
var Wincent = {
  Ajax: require('./Ajax'),
  Articles: require('./Articles'),
  Menu: require('./Menu'),
  Posts: require('./Posts'),
  Snippets: require('./Snippets'),
  Spinner: require('./Spinner'),
};

Wincent.Ajax.init();

module.exports = Wincent;
