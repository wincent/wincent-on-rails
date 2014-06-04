'use strict';

var injectTagWidget = require('./injectTagWidget');

var Articles = {
  init: function() {
    injectTagWidget('article');
  }
};

module.exports = Articles;
