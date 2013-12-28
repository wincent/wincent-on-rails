"use strict";

var ReactStyle = require("ReactStyle");

var TagPillStyleRules = ReactStyle.create({
  '.tagPill' : {
    background          : 'hsl(230, 21.4%, 94.5%)', // #eeeff4
    border              : '1px solid #3b5999',
    borderRadius        : '2px',
    display             : 'inline-block',
    margin              : '2px',
    padding             : '0 0 0 .5em',
    '-khtmlUserSelect'  : 'none',
    '-mozUserSelect'    : 'none',
    '-webkitUserSelect' : 'none',
    userSelect          : 'none',
    whiteSpace          : 'nowrap'
  },
  '.tagPill:hover, .tagPill:focus' : {
    background : 'hsl(230, 21.4%, 74.5%)',
  },
  '.tagPill a' : {
    display        : 'inline-block',
    fontWeight     : 'bold',
    marginLeft     : '.25em',
    padding        : '0 .25em',
    textDecoration : 'none'
  },
  '.tagPill a:hover, .tagPill a:focus' : {
    background : 'hsl(230, 21.4%, 54.5%)',
    color      : 'hsl(230, 21.4%, 100%)',
  },
  '.tagPill a:active' : {
    color : 'hsl(230, 21.4%, 90%)',
  },
  '.tagPill.dragging' : {
    opacity : '.4'
  }
});

module.exports = TagPillStyleRules;
