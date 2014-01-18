"use strict";

var ReactStyle = require("ReactStyle");

var TagWidgetStyleRules = ReactStyle.create({
  '.tagWidget' : {
    border    : '1px solid #ddd',
    padding   : '2px',
    position  : 'relative'
  },
  '.tagWidget:focus' : {
    outline : 0
  }
});

module.exports = TagWidgetStyleRules;
