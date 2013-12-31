"use strict";

var ReactStyle = require("ReactStyle");

// show no more than 10 autocomplete entries at a time
var VISIBLE_AUTOCOMPLETE_ENTRIES = 10;

var TagAutocompleteStyleRules = ReactStyle.create({
  '.tagAutocomplete' : {
    background : '#fff',
    border     : '1px solid #ddd',
    boxShadow  : '0 0 1px #ccc',
    top        : '100%',
    display    : 'none',
    left       : 0,
    maxHeight  : (VISIBLE_AUTOCOMPLETE_ENTRIES * 100) + '%',
    overflowY  : 'scroll',
    position   : 'absolute',
    width      : '100%',
  },
  '.tagAutocomplete.active' : {
    display : 'block'
  },
  '.tagAutocomplete ul' : {
    listStyleType : 'none',
    margin        : 0,
    padding       : 0,
  },
  '.tagAutocomplete li' : {
    borderBottom        : '1px solid #efefef',
    padding             : '5px',
    '-khtmlUserSelect'  : 'none',
    '-mozUserSelect'    : 'none',
    '-webkitUserSelect' : 'none',
    userSelect          : 'none'
  },
  '.tagAutocomplete li:last-child' : {
    border : 0
  },
  '.tagAutocomplete li.selected' : {
    background: '#efefef'
  },
  '.tagAutocomplete li:active' : {
    background: '#ddd'
  }
});

TagAutocompleteStyleRules.VISIBLE_AUTOCOMPLETE_ENTRIES = VISIBLE_AUTOCOMPLETE_ENTRIES;

module.exports = TagAutocompleteStyleRules;
