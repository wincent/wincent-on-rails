/**
 * @jsx React.DOM
 */
"use strict";

var React              = require("React"),
    ReactStyle         = require("ReactStyle"),
    TagInputStyleRules = require("./TagInputStyleRules");

var RETURN_KEY_CODE    = 13,
    ESCAPE_KEY_CODE    = 27,
    ZERO_KEY_CODE      = 48,
    NINE_KEY_CODE      = ZERO_KEY_CODE + 9,
    UPPER_A_KEY_CODE   = 65,
    UPPER_Z_KEY_CODE   = UPPER_A_KEY_CODE + 25,
    BACKSPACE_KEY_CODE = 8,
    DELETE_KEY_CODE    = 46;

ReactStyle.addRules(TagInputStyleRules);

var TagInput = React.createClass({
  getInitialState: function() {
    return {};
  },

  componentDidMount: function() {
  },

  componentWillMount: function() {
  },

  handleInput: function(event) {
    // resize dynamically
    var input    = event.target,
        newWidth = this.getTextWidth(input);
    input.style.width = newWidth + "px";
  },

  handleKeyDown: function(event) {
    var keyCode  = event.keyCode,
        shiftKey = event.shiftKey && !event.altKey && !event.ctrlKey,
        modifier = event.shiftKey || event.altKey || event.ctrlKey;

    if (keyCode === RETURN_KEY_CODE) {
      var input = this.getDOMNode();
      this.props.onTagInput(input.value.trim());
      input.value = '';
    } else if (keyCode === ESCAPE_KEY_CODE) {
      this.getDOMNode().blur();
    } else if ((keyCode >= ZERO_KEY_CODE && keyCode <= NINE_KEY_CODE && !modifier) ||
        (keyCode >= UPPER_A_KEY_CODE && keyCode <= UPPER_Z_KEY_CODE && (!modifier || shiftKey))) {
      // all good
    } else {
      event.preventDefault(); // not allowed, still need to deal with pasting as well
    }
  },

  // TODO: put this somewhere more general
  escapeHTML: function(string) {
    return string
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  },

  getTextWidth: function(input) {
    // copy the input value to a hidden div with the same styling as the input,
    // then measure the width of that
    var hiddenDiv = document.createElement("div"),
        styles    = window.getComputedStyle(input),
        value     = this.escapeHTML(input.value + "w"); // 1-char of padding

    hiddenDiv.style.position      = "absolute";
    hiddenDiv.style.left          = "-10000px";
    hiddenDiv.style.top           = "-10000px";
    hiddenDiv.style.padding       = "0";
    hiddenDiv.style.fontFamily    = styles['font-family'];
    hiddenDiv.style.fontSize      = styles['font-size'];
    hiddenDiv.style.fontWeight    = styles['font-weight'];
    hiddenDiv.style.letterSpacing = styles['letter-spacing'];
    hiddenDiv.style.whitespace    = 'nowrap';
    hiddenDiv.innerHTML           = value;

    document.body.appendChild(hiddenDiv);
    var width = hiddenDiv.clientWidth;
    document.body.removeChild(hiddenDiv);
    return width;
  },

  render: function() {
    return (
      <input className={TagInputStyleRules.tagInput}
             type="text"
             onInput={this.handleInput}
             onKeyDown={this.handleKeyDown}
             autoComplete="off">
      </input>
    );
  }
});

module.exports = TagInput;
