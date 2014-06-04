'use strict';

var injectTagWidget = require('./injectTagWidget');

var Snippets = {
  init: function() {
    injectTagWidget('snippet');
  }
};

module.exports = Snippets;
