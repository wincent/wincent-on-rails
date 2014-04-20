/**
 * @jsx React.DOM
 */

'use strict';

window.Wincent = {};
Wincent.Ajax = require('./Ajax');
Wincent.Git = require('./Git');
Wincent.Menu = require('./Menu');
Wincent.Spinner = require('./Spinner');
Wincent.TagWidget = require('./TagWidget');

// once all is done, these won't be global
window.$ = require('jquery');
window._ = require('underscore');
window.React = require('react/addons');

// initializers:
Wincent.Ajax.init();
Wincent.Git.init();
