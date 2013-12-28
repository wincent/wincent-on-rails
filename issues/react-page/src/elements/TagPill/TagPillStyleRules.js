"use strict";

var ReactStyle = require("ReactStyle");

var TagPillStyleRules = ReactStyle.create({
  '.tagPill' : {
    background          : '#eeeff4',
    border              : '1px solid #3b5999',
    borderRadius        : '2px',
    display             : 'inline-block',
    margin              : '2px',
    padding             : '0 .5em',
    '-khtmlUserSelect'  : 'none',
    '-mozUserSelect'    : 'none',
    '-webkitUserSelect' : 'none',
    userSelect          : 'none',
    whiteSpace          : 'nowrap'
  },
  '.tagPill:after' : {
    content: '' // could use this for checkbox (or not)
  },
  '.tagPill a' : {
    display        : 'inline-block',
    fontWeight     : 'bold',
    marginLeft     : '.5em',
    textDecoration : 'none'
  },
  '.tagPill.dragging' : {
    opacity : '.4'
  }
});

module.exports = TagPillStyleRules;
