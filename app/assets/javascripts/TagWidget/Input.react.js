'use strict';

import React from 'react/addons';

import Keys from '../Keys';

import escapeHTML from '../escapeHTML';

export default class Input extends React.Component {
  handleFocus(event) {
    // don't let the event bubble up to TagWidget, otherwise it will try to send
    // focus straight back to us due to its handleFocus implementation
    event.stopPropagation();
  }

  handleInput(event) {
    // resize dynamically
    var input    = event.target;
    var newWidth = this.getTextWidth(input);
    input.style.width = newWidth + 'px';
  }

  handleKeyDown(event) {
    var keyCode = event.keyCode;
    var input   = React.findDOMNode(this);

    if (keyCode === Keys.BACKSPACE) {
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
    } else if (keyCode === Keys.TAB && event.shiftKey) {
      this.props.onShiftTab();
    }
  }

  handleKeyUp(event) {
    var keyCode = event.keyCode;
    var input   = React.findDOMNode(this);
    var value   = input.value;

    if (keyCode === Keys.BACKSPACE) {
      // see note in the handleKeyDown() method for info about this special case
      this.pendingDeletion = false;
    }
  }

  getTextWidth(input) {
    // copy the input value to a hidden div with the same styling as the input,
    // then measure the width of that
    var hiddenDiv = document.createElement("div");
    var styles    = window.getComputedStyle(input);
    var value     = escapeHTML(input.value + "w"); // 1-char of padding

    hiddenDiv.style.position      = 'absolute';
    hiddenDiv.style.left          = '-10000px';
    hiddenDiv.style.top           = '-10000px';
    hiddenDiv.style.padding       = '0';
    hiddenDiv.style.fontFamily    = styles['font-family'];
    hiddenDiv.style.fontSize      = styles['font-size'];
    hiddenDiv.style.fontWeight    = styles['font-weight'];
    hiddenDiv.style.letterSpacing = styles['letter-spacing'];
    hiddenDiv.style.whiteSpace    = 'nowrap';
    hiddenDiv.innerHTML           = value.replace(/ /g, '&nbsp;');

    document.body.appendChild(hiddenDiv);
    var width = hiddenDiv.clientWidth;
    document.body.removeChild(hiddenDiv);
    return width;
  }

  render() {
    return (
      <input
        autoComplete="off"
        className="tagInput"
        name={this.props.name}
        onFocus={this.handleFocus.bind(this)}
        onInput={this.handleInput.bind(this)}
        onKeyDown={this.handleKeyDown.bind(this)}
        onKeyUp={this.handleKeyUp.bind(this)}
        type="text"
        value={this.props.value}
      />
    );
  }
}
