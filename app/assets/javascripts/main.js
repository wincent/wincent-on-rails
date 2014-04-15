/**
 * @jsx React.DOM
 */

'use strict';

var React = require('react/addons');

var TagWidget = require('./TagWidget');

window.Wincent = {};
Wincent.Menu = require('./Menu');
Wincent.Spinner = require('./Spinner');
Wincent.Ajax = require('./Ajax');
Wincent.Git = require('./Git');

// once all is done, these won't be global
window.$ = require('jquery');
window._ = require('underscore');

// initializers:
Wincent.Ajax.init();
Wincent.Git.init();
