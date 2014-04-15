'use strict';

var React = require('React');

var BACKSPACE_KEY_CODE = 8,  // delete tag
    TAB_KEY_CODE       = 9;  // switches focus to previous element

var TagInput = React.createClass({
  handleFocus: function(event) {
    // don't let the event bubble up to TagWidget, otherwise it will try to send
    // focus straight back to us due to its handleFocus implementation
    event.stopPropagation();
  },

  handleInput: function(event) {
    // resize dynamically
    var input    = event.target;
    var newWidth = this.getTextWidth(input);
    input.style.width = newWidth + 'px';
  },

  handleKeyDown: function(event) {
    var keyCode = event.keyCode;
    var input   = this.getDOMNode();

    if (keyCode === BACKSPACE_KEY_CODE) {
      if (input.selectionStart !== 0 && input.selectionEnd !== 0) {
        this.pendingDeletion = true;
      } else if (input.selectionStart === 0 &&
                 input.selectionEnd === 0 &&
                 !this.pendingDeletion) {
        // special case: we want backspace to delete a tag only if it is a keyDown
        // followed by a keyUp at position 0; we do not want it to happen if it is
        // a series of keyDown starting at position > 0 (ie. because of pressing
        // and holding the backspace key)
        this.props.onTagPop();
        event.preventDefault();
      }
    } else if (keyCode === TAB_KEY_CODE && event.shiftKey) {
      this.props.onShiftTab();
    }
  },

  handleKeyUp: function(event) {
    var keyCode = event.keyCode;
    var input   = this.getDOMNode();
    var value   = input.value;

    if (keyCode === BACKSPACE_KEY_CODE) {
      // see note in the handleKeyDown() method for info about this special case
      this.pendingDeletion = false;
    }
  },

  // TODO: put this somewhere more general
  escapeHTML: function(string) {
    return string
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/'/g, '&quot;');
  },

  getTextWidth: function(input) {
    // copy the input value to a hidden div with the same styling as the input,
    // then measure the width of that
    var hiddenDiv = document.createElement("div");
    var styles    = window.getComputedStyle(input);
    var value     = this.escapeHTML(input.value + "w"); // 1-char of padding

    hiddenDiv.style.position      = 'absolute';
    hiddenDiv.style.left          = '-10000px';
    hiddenDiv.style.top           = '-10000px';
    hiddenDiv.style.padding       = '0';
    hiddenDiv.style.fontFamily    = styles['font-family'];
    hiddenDiv.style.fontSize      = styles['font-size'];
    hiddenDiv.style.fontWeight    = styles['font-weight'];
    hiddenDiv.style.letterSpacing = styles['letter-spacing'];
    hiddenDiv.style.whitespace    = 'nowrap';
    hiddenDiv.innerHTML           = value.replace(/ /g, '&nbsp;');

    document.body.appendChild(hiddenDiv);
    var width = hiddenDiv.clientWidth;
    document.body.removeChild(hiddenDiv);
    return width;
  },

  render: function() {
    return (
      <input
        className={TagInputStyleRules.tagInput}
        type="text"
        onFocus={this.handleFocus}
        onInput={this.handleInput}
        onKeyDown={this.handleKeyDown}
        onKeyUp={this.handleKeyUp}
        autoComplete="off"
      />
    );
  }
});

module.exports = TagInput;
