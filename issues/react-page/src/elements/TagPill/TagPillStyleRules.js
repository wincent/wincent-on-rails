"use strict";

var ReactStyle = require("ReactStyle");

var TagPillStyleRules = ReactStyle.create({
  '.tagPill' : {
    background          : '#eeeff4',
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
    background : '#c8c9c0', // FIXME: placeholder only
  },
  '.tagPill a' : {
    display        : 'inline-block',
    fontWeight     : 'bold',
    marginLeft     : '.25em',
    padding        : '0 .25em',
    textDecoration : 'none'
  },
  '.tagPill a:hover, .tagPill a:focus' : {
    background : '#666', // FIXME: placeholder only
    color      : '#aaa'  // FIXME: placeholder only
  },
  '.tagPill a:active' : {
    color : '#999' // FIXME: placeholder only
  },
  '.tagPill.dragging' : {
    opacity : '.4'
  }
});

module.exports = TagPillStyleRules;
