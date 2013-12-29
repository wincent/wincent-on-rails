"use strict";

var ReactStyle = require("ReactStyle");

var TagAutocompleteStyleRules = ReactStyle.create({
  '.tagAutocomplete' : {
    background : '#fff',
    border     : '1px solid #ddd',
    boxShadow  : '0 0 1px #ccc',
    top        : '100%',
    display    : 'none',
    left       : 0,
    maxHeight  : '1000%', // show no more than 10 autocomplete entries
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

module.exports = TagAutocompleteStyleRules;
