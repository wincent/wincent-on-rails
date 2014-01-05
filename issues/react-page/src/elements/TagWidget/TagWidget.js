/**
 * @jsx React.DOM
 */
"use strict";

var React               = require("React"),
    ReactStyle          = require("ReactStyle"),
    TagAutocomplete     = require("../TagAutocomplete/TagAutocomplete"),
    TagInput            = require("../TagInput/TagInput"),
    TagPill             = require("../TagPill/TagPill"),
    TagWidgetStyleRules = require("../TagWidget/TagWidgetStyleRules");

var TAB_KEY_CODE       = 9,  // accept autocomplete suggestion
    RETURN_KEY_CODE    = 13, // add tag/accept autocomplete suggestion
    ESCAPE_KEY_CODE    = 27, // blur input field/close autocomplete menu
    UP_KEY_CODE        = 38, // previous autocomplete suggestion
    DOWN_KEY_CODE      = 40; // next autocomplete suggestion

ReactStyle.addRules(TagWidgetStyleRules);

var TagWidget = React.createClass({
  getInitialState: function() {
    return {
      tags:                    [],
      availableCompletions:    [],
      filteredCompletions:     [],
      pending:                 [], // for styling purposes
      autocompleteSelectedIdx: undefined,
      duplicateTag:            undefined
    };
  },

  componentDidMount: function() {
    // get available completions from the server
    var request = new XMLHttpRequest();
    request.open("GET", "/tags.json");

    request.onreadystatechange = function() {
      if (request.status === 200 && request.readyState === 4) {
        this.state.availableCompletions = JSON.parse(request.responseText);
        this.setState(this.state);
      }
    }.bind(this);

    request.send();
  },

  // Takes the available completions and filters them based on TagInput value
  filterCompletions: function(string) {
    if (string === "") {
      return []; // don't show suggestions if user hasn't inputed anything
    } else {
      return this.state.availableCompletions.filter(function(completion) {
        // candidate must match, and must not already be present in tags list
        return completion.indexOf(string) !== -1 &&
        this.state.tags.indexOf(completion) === -1;
      }.bind(this));
    }
  },

  clearDuplicateMarker: function() {
    if (this.state.duplicateTag) {
      this.state.duplicateTag = undefined;
      this.setState(this.state);
    }
  },

  handleClick: function(event) {
    // if outside of input area, focus input
    var tagInput = this.refs.tagInput.getDOMNode();
    if (event.target !== tagInput) {
      tagInput.focus();
    }
  },

  // re-filter the autocomplete list on any input,
  // clear duplicate indicator
  handleChange: function(event) {
    var tagInput = this.refs.tagInput.getDOMNode();
    if (event.target === tagInput) {
      var oldList = this.state.filteredCompletions,
          newList = this.filterCompletions(tagInput.value);

      if (newList.length !== oldList.length ||
          newList.some(function(string, idx) { return oldList[idx] !== string; })) {
        this.state.filteredCompletions = newList;
        this.setState(this.state);
      }

      this.clearDuplicateMarker();
    }
  },

  handleKeyDown: function(event) {
    var keyCode        = event.keyCode,
        completions    = this.state.filteredCompletions,
        maxSelectedIdx = completions.length - 1, // -1 if no completions
        oldSelectedIdx = this.state.autocompleteSelectedIdx,
        newSelectedIdx;

    if (keyCode === ESCAPE_KEY_CODE) {
      var input = this.refs.tagInput.getDOMNode();
      input.blur();
      this.state.filteredCompletions = [];
    } else if (typeof oldSelectedIdx === "undefined" &&
        maxSelectedIdx >= 0 &&
        (keyCode === DOWN_KEY_CODE || keyCode === TAB_KEY_CODE)) {
      // first time here, and there are completions available; select first
      newSelectedIdx = 0;
    } else if (typeof oldSelectedIdx !== "undefined") {
        // we've been here before, and a completion is currently selected
        if (keyCode === UP_KEY_CODE && oldSelectedIdx > 0) {
          newSelectedIdx = oldSelectedIdx - 1;
        } else if (keyCode === DOWN_KEY_CODE && oldSelectedIdx < maxSelectedIdx) {
          newSelectedIdx = oldSelectedIdx + 1;
        } else if (keyCode === RETURN_KEY_CODE || keyCode === TAB_KEY_CODE) {
          // accept selected suggestion
          this.refs.tagInput.getDOMNode().value = '';
          this.pushTag(this.state.filteredCompletions[oldSelectedIdx]);
        } else {
          // non-special keys are allowed to pass through
          return;
        }
    } else if (keyCode === RETURN_KEY_CODE) {
      // no completions selected; add currently inputed text
      var input = this.refs.tagInput.getDOMNode(),
          value = input.value;
      this.pushTag(value);
      input.value = '';
      return;
    } else {
      // no completions selected, not a special key, let it through
      return;
    }

    event.preventDefault();
    this.state.autocompleteSelectedIdx = newSelectedIdx;
    this.setState(this.state);
  },

  pushTag: function(newTag) {
    newTag = newTag
      .trim()
      .toLowerCase()
      .replace(/ +/g, '.')           // spaces become dots
      .replace(/[^a-z0-9.]+/gi, ''); // all other illegal chars get eaten

    // NOTE: might want to provide better feedback for the edge case where the
    // entire thing gets eaten
    if (newTag.length) {
      if (this.state.tags.indexOf(newTag) === -1) {
        // tag is not a dupe
        this.state.tags.push(newTag);

        if (this.props.resourceURL) {
          // widget is attached to a saved resource; make an Ajax request now
          this.createTagging(newTag);
        } else {
          // widget is attached to an unsaved resource; no immediate Ajax
          this.setState(this.state);
        }
      } else {
        // tag is a dupe
        this.state.duplicateTag = newTag;
      }
    }

    this.state.autocompleteSelectedIdx = undefined;
    this.state.filteredCompletions = [];
    this.setState(this.state);
  },

  createTagging: function(newTag) {
    this.state.pending.push(newTag);

    // DEBUGGING: replace with actual Ajax request
    setTimeout(function() {
      this.state.pending.splice(this.state.pending.indexOf(newTag), 1);
      this.setState(this.state);
    }.bind(this), 1000);
  },

  // callback invoked when someone clicks on an autocomplete suggestion
  handleTagPush: function(newTag) {
    var input = this.refs.tagInput.getDOMNode();
    input.value = '';
    this.pushTag(newTag);
  },

  // callback invokved when someone "selects" an autocomplete suggestion via
  // mouseEnter
  handleTagSelect: function(element) {
    var tagIdx = this.state.filteredCompletions.indexOf(element.innerHTML);
    this.state.autocompleteSelectedIdx = tagIdx;
    this.setState(this.state);
  },

  handleTagPop: function() {
    if (this.state.tags.length) {
      this.clearDuplicateMarker();
      this.state.tags.pop();
      this.setState(this.state);
    }
  },

  handleTagDelete: function(name) {
    this.clearDuplicateMarker();
    this.state.tags.splice(this.state.tags.indexOf(name), 1);
    this.setState(this.state);
  },

  render: function() {
    var tagPills = this.state.tags.map(function(name) {
      var isDuplicate = name === this.state.duplicateTag,
          isPending   = this.state.pending.indexOf(name) !== -1;

      return <TagPill name={name}
                      isDuplicate={isDuplicate}
                      isPending={isPending}
                      onTagDelete={this.handleTagDelete} />;
    }.bind(this));

    return (
      <div className={TagWidgetStyleRules.tagWidget}
           onChange={this.handleChange}
           onClick={this.handleClick}
           onDragStart={this.handleDragStart}
           onKeyDown={this.handleKeyDown}>
        {tagPills}
        <input type="hidden"
               name={this.props.resourceName}
               value={this.state.tags.join(" ")} />
        <TagInput ref="tagInput" onTagPop={this.handleTagPop} />
        <TagAutocomplete completions={this.state.filteredCompletions}
                         selectedIdx={this.state.autocompleteSelectedIdx}
                         onTagPush={this.handleTagPush}
                         onTagSelect={this.handleTagSelect} />
      </div>
    );
  },
});

module.exports = TagWidget;
