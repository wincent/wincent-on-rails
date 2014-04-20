'use strict';

var Wincent = {
  Ajax: require('./Ajax'),
  Articles: require('./Articles'),
  Git: require('./Git'),
  Menu: require('./Menu'),
  Spinner: require('./Spinner')
};

Wincent.Ajax.init();
Wincent.Git.init();

module.exports = Wincent;
