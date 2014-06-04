'use strict';

var injectTagWidget = require('./injectTagWidget');

var Issues = {
  init: function() {
    injectTagWidget('issue');
  }
};

module.exports = Issues;
