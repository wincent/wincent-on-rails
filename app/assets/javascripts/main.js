'use strict';

var Wincent = {
  Ajax: require('./Ajax'),
  Articles: require('./Articles'),
  Git: require('./Git'),
  Issues: require('./Issues'),
  Menu: require('./Menu'),
  Posts: require('./Posts'),
  Snippets: require('./Snippets'),
  Spinner: require('./Spinner'),
  Topics: require('./Topics')
};

Wincent.Ajax.init();
Wincent.Git.init();

module.exports = Wincent;
