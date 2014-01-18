"use strict";

var ReactStyle = require("ReactStyle");

var TagInputStyleRules = ReactStyle.create({
  '.tagInput': {
    border        : 0,
    margin        : '5px 0',    // matches TagPill border + vertical margins
    textTransform : 'lowercase' // cheaper to do it in CSS than JS
  },
  '.tagInput:focus': {
    outline: 0
  }
});

module.exports = TagInputStyleRules;
