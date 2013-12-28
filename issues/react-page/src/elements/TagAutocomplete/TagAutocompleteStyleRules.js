"use strict";

var ReactStyle = require("ReactStyle");

var TagAutocompleteStyleRules = ReactStyle.create({
  '.tagAutocomplete': {
    border    : '1px solid #ddd',
    boxShadow : '0 0 1px #ccc',
    top       : '100%',
    display   : 'none',
    left      : 0,
    position  : 'absolute',
    width     : '100%',
    zIndex    : -1
  }
});

module.exports = TagAutocompleteStyleRules;
