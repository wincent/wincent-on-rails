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

var BACKSPACE_KEY_CODE = 8,  // delete selected pill
    TAB_KEY_CODE       = 9,  // accept autocomplete suggestion
    RETURN_KEY_CODE    = 13, // add tag/accept autocomplete suggestion
    ESCAPE_KEY_CODE    = 27, // blur input field/close autocomplete menu
    LEFT_KEY_CODE      = 37, // select previous pill
    UP_KEY_CODE        = 38, // previous autocomplete suggestion
    RIGHT_KEY_CODE     = 39, // select next pill
    DOWN_KEY_CODE      = 40; // next autocomplete suggestion

ReactStyle.addRules(TagWidgetStyleRules);

// The TagWidget provides tag "pilling" and autocomplete. It manages a related
// set of subcomponents (TagInput, TagAutocomplete, TagPill).
var TagWidget = React.createClass({
  getInitialState: function() {
    return {
      tags:                       [],
      availableCompletions:       [],
      filteredCompletions:        [],
      pending:                    [], // for styling purposes
      selectedAutocompleteIndex:  undefined,
      selectedPillIndex:          undefined,
      duplicateTag:               undefined
    };
  },

  componentDidMount: function() {
    // get available completions from the server
    var request = new XMLHttpRequest();
    request.open("GET", "/tags.json");

    request.onreadystatechange = function() {
      if (request.status === 200 && request.readyState === 4) {
        this.setState({
          availableCompletions: JSON.parse(request.responseText)
        });
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
      }, this);
    }
  },

  // Remove the duplicate marker from a tag.
  //
  // If the user tries to add the same tag twice, we apply some styling to the
  // previously added tag as a hint. This method removes that styling.
  clearDuplicateMarker: function() {
    if (this.state.duplicateTag) {
      this.setState({ duplicateTag: undefined });
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
        this.setState({ filteredCompletions: newList });
      }

      this.clearDuplicateMarker();
    }
  },

  // Pressing left will select the next pill to the left.
  //
  // If the cursor is not at the left of the input field (ie. not next to the
  // pills), does nothing.
  handleLeftKeyDown: function(event) {
    var input = this.refs.tagInput.getDOMNode();
    if (input === event.target && input.selectionStart === 0) {
      if (this.state.tags.length) {
        this.setState({ selectedPillIndex: this.state.tags.length - 1 });

        // can't just blur() the tagInput as we still need key events
        this.forceFocus();
      }
    } else if (typeof this.state.selectedPillIndex !== "undefined" &&
                this.state.selectedPillIndex > 0) {
      this.setState({ selectedPillIndex: this.state.selectedPillIndex - 1 });
    }
  },

  // Pressing right will select the next pill to the right.
  //
  // If no pill is selected, does nothing.
  handleRightKeyDown: function() {
    if (typeof this.state.selectedPillIndex !== "undefined") {
      if (this.state.selectedPillIndex < this.state.tags.length - 1) {
        this.setState({ selectedPillIndex: this.state.selectedPillIndex + 1 });
      } else {
        this.setState({ selectedPillIndex: undefined });
        this.refs.tagInput.getDOMNode().focus();
      }
      event.preventDefault();
    }
  },

  // Deletes any selected pill.
  //
  // Does nothing if no pill is selected.
  handleBackspaceKeyDown: function(event) {
    if (typeof this.state.selectedPillIndex !== "undefined") {
      var tags = this.state.tags.slice(0),
          index;
      tags.splice(this.state.selectedPillIndex, 1)

      if (this.state.selectedPillIndex < tags.length) {
        index = this.state.selectedPillIndex;
      } else {
        // deleting the last tag
        this.refs.tagInput.getDOMNode().focus();
      }

      this.setState({ tags: tags, selectedPillIndex: index });

      event.preventDefault(); // don't let back button perform page navigation
    }
  },

  handleKeyDown: function(event) {
    var keyCode        = event.keyCode,
        completions    = this.state.filteredCompletions,
        maxSelectedIdx = completions.length - 1, // -1 if no completions
        oldSelectedIdx = this.state.selectedAutocompleteIndex,
        newSelectedIdx;

    if (keyCode === LEFT_KEY_CODE) {
      return this.handleLeftKeyDown(event);
    } else if (keyCode === RIGHT_KEY_CODE) {
      return this.handleRightKeyDown();
    } else if (keyCode === BACKSPACE_KEY_CODE) {
      return this.handleBackspaceKeyDown(event);
    } else if (keyCode === ESCAPE_KEY_CODE) {
      this.refs.tagInput.getDOMNode().blur();
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
    this.setState({ selectedAutocompleteIndex: newSelectedIdx });
  },

  // On losing focus, clear selection from seleted pill.
  handleBlur: function(event) {
    if (typeof this.state.selectedPillIndex !== "undefined" &&
        this.getDOMNode() === event.target) {
      this.setState({ selectedPillIndex: undefined });
    }
  },

  handleFocus: function(event) {
    if (!this.forcingFocus) {
      // likely we were tabbed into; forward focus to the TagInput
      this.refs.tagInput.getDOMNode().focus();
    } else {
      this.forcingFocus = false;
    }
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
        this.setState({ tags: this.state.tags.concat(newTag) });

        if (this.props.resourceURL) {
          // widget is attached to a saved resource; make an Ajax request now
          this.createTagging(newTag);
        }
      } else {
        // tag is a dupe
        this.setState({ duplicateTag: newTag });
      }
    }

    this.setState({
      selectedAutocompleteIndex: undefined,
      filteredCompletions:     []
    });
  },

  createTagging: function(newTag) {
    this.state.pending.push(newTag);

    // DEBUGGING: replace with actual Ajax request
    setTimeout(function() {
      var pending = this.state.pending.slice(0);
      pending.splice(pending.indexOf(newTag), 1);
      this.setState({ pending: pending });
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
  handleAutocompleteSelect: function(element) {
    var tagIdx = this.state.filteredCompletions.indexOf(element.innerHTML);
    this.setState({ selectedAutocompleteIndex: tagIdx });
  },

  handleTagPop: function() {
    if (this.state.tags.length) {
      this.clearDuplicateMarker();
      this.setState({ tags: this.state.tags.slice(0, -1) });
    }
  },

  handleTagSelect: function(name) {
    this.setState({ selectedPillIndex: this.state.tags.indexOf(name) });
    this.forceFocus();
  },

  handleTagDelete: function(name) {
    this.clearDuplicateMarker();
    var tags = this.state.tags.slice(0);
    tags.splice(tags.indexOf(name), 1)
    this.setState({ tags: tags });
  },

  forceFocus: function() {
    // This is somewhat of a nasty hack; sometimes we have to programmatically
    // apply focus to the widget (for example, when we blur the TagInput, we
    // need to keep focus on the TagWidget itself in order to continue receiving
    // key events).
    //
    // We need a way of distinguishing between these artificial events and
    // natural events due to things like tabbing into the TagWidget. We can't
    // rely on setState followed by reading state in another handler, because of
    // batching. Instead we have to set a flag property directly on this class.
    this.forcingFocus = true;
    this.getDOMNode().focus();
  },

  render: function() {
    var tagPills = this.state.tags.map(function(name, i) {
      var isDuplicate = name === this.state.duplicateTag,
          isPending   = this.state.pending.indexOf(name) !== -1,
          isSelected  = i === this.state.selectedPillIndex;

      return <TagPill name={name}
                      isDuplicate={isDuplicate}
                      isPending={isPending}
                      isSelected={isSelected}
                      onTagSelect={this.handleTagSelect}
                      onTagDelete={this.handleTagDelete} />;
    }, this);

    return (
      <div tabIndex="0"
           className={TagWidgetStyleRules.tagWidget}
           onChange={this.handleChange}
           onClick={this.handleClick}
           onDragStart={this.handleDragStart}
           onKeyDown={this.handleKeyDown}
           onBlur={this.handleBlur}
           onFocus={this.handleFocus}>
        {tagPills}
        <input type="hidden"
               name={this.props.resourceName}
               value={this.state.tags.join(" ")} />
        <TagInput ref="tagInput" onTagPop={this.handleTagPop} />
        <TagAutocomplete completions={this.state.filteredCompletions}
                         selectedIdx={this.state.selectedAutocompleteIndex}
                         onTagPush={this.handleTagPush}
                         onAutocompleteSelect={this.handleAutocompleteSelect} />
      </div>
    );
  },
});

module.exports = TagWidget;
