'use strict';

var React = require('React');

var Keys = require('./Keys');
var TagAutocomplete = require('./TagAutocomplete');
var TagInput = require('./TagInput');
var TagPill = require('./TagPill');

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
    request.open('GET', '/tags.json');

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
    if (string === '') {
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
      this.setState({duplicateTag: undefined});
    }
  },

  onShiftTab: function() {
    var event = document.createEvent('Events');
    event.initEvent('keydown', true, true);
    event.keyIdentifier = 'U+0009';
    event.keyCode = Keys.TAB;
    event.which = Keys.TAB;
    event.shiftKey = true;

    this.forceFocus();
    this.getDOMNode().dispatchEvent(event);
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
        newList.some((string, idx) => oldList[idx] !== string)) {
        this.setState({filteredCompletions: newList});
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
        this.setState({selectedPillIndex: this.state.tags.length - 1});

        // can't just blur() the tagInput as we still need key events
        this.forceFocus();
      }
    } else if (typeof this.state.selectedPillIndex !== 'undefined' &&
                this.state.selectedPillIndex > 0) {
      this.setState({selectedPillIndex: this.state.selectedPillIndex - 1});
    }
  },

  // Pressing right will select the next pill to the right.
  //
  // If no pill is selected, does nothing.
  handleRightKeyDown: function() {
    if (typeof this.state.selectedPillIndex !== 'undefined') {
      if (this.state.selectedPillIndex < this.state.tags.length - 1) {
        this.setState({selectedPillIndex: this.state.selectedPillIndex + 1});
      } else {
        this.setState({selectedPillIndex: undefined});
        this.refs.tagInput.getDOMNode().focus();
      }
      event.preventDefault();
    }
  },

  // Deletes any selected pill.
  //
  // Does nothing if no pill is selected.
  handleBackspaceKeyDown: function(event) {
    if (typeof this.state.selectedPillIndex !== 'undefined') {
      var tags = this.state.tags.slice(0),
          index;
      tags.splice(this.state.selectedPillIndex, 1)

      if (this.state.selectedPillIndex < tags.length) {
        index = this.state.selectedPillIndex;
      } else {
        // deleting the last tag
        this.refs.tagInput.getDOMNode().focus();
      }

      this.setState({tags: tags, selectedPillIndex: index});

      event.preventDefault(); // don't let back button perform page navigation
    }
  },

  handleKeyDown: function(event) {
    var keyCode        = event.keyCode,
        completions    = this.state.filteredCompletions,
        maxSelectedIdx = completions.length - 1, // -1 if no completions
        oldSelectedIdx = this.state.selectedAutocompleteIndex,
        newSelectedIdx;

    if (keyCode === Keys.LEFT) {
      return this.handleLeftKeyDown(event);
    } else if (keyCode === Keys.RIGHT) {
      return this.handleRightKeyDown();
    } else if (keyCode === Keys.BACKSPACE) {
      return this.handleBackspaceKeyDown(event);
    } else if (keyCode === Keys.ESCAPE) {
      this.refs.tagInput.getDOMNode().blur();
      this.state.filteredCompletions = [];
    } else if (typeof oldSelectedIdx === 'undefined' &&
        maxSelectedIdx >= 0 &&
        (keyCode === Keys.DOWN || keyCode === Keys.TAB)) {
      // first time here, and there are completions available; select first
      newSelectedIdx = 0;
    } else if (typeof oldSelectedIdx !== 'undefined') {
        // we've been here before, and a completion is currently selected
        if (keyCode === Keys.UP && oldSelectedIdx > 0) {
          newSelectedIdx = oldSelectedIdx - 1;
        } else if (keyCode === Keys.DOWN && oldSelectedIdx < maxSelectedIdx) {
          newSelectedIdx = oldSelectedIdx + 1;
        } else if (keyCode === Keys.RETURN || keyCode === Keys.TAB) {
          // accept selected suggestion
          this.refs.tagInput.getDOMNode().value = '';
          this.pushTag(this.state.filteredCompletions[oldSelectedIdx]);
        } else {
          // non-special keys are allowed to pass through
          return;
        }
    } else if (keyCode === Keys.RETURN) {
      // no completions selected; add currently inputed text
      var input = this.refs.tagInput.getDOMNode(),
          value = input.value;
      if (this.pushTag(value)) {
        event.preventDefault(); // prevent form submission
      }
      input.value = '';
      return;
    } else {
      // no completions selected, not a special key, let it through
      return;
    }

    event.preventDefault();
    this.setState({selectedAutocompleteIndex: newSelectedIdx});
  },

  // On losing focus, clear selection from selected pill.
  handleBlur: function(event) {
    if (typeof this.state.selectedPillIndex !== 'undefined' &&
        this.getDOMNode() === event.target) {
      this.setState({selectedPillIndex: undefined});
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

  /**
   * @returns true if a tag was actually pushed
   */
  pushTag: function(newTag) {
    newTag = newTag
      .trim()
      .toLowerCase()
      .replace(/ +/g, '.')           // spaces become dots
      .replace(/[^a-z0-9.]+/gi, ''); // all other illegal chars get eaten

    // NOTE: might want to provide better feedback for the edge case where the
    // entire thing gets eaten
    if (newTag.length) {
      var pushedTag = true;
      if (this.state.tags.indexOf(newTag) === -1) {
        // tag is not a dupe
        this.setState({tags: this.state.tags.concat(newTag)});

        if (this.props.resourceURL) {
          // widget is attached to a saved resource; make an Ajax request now
          this.createTagging(newTag);
        }
      } else {
        // tag is a dupe
        this.setState({duplicateTag: newTag});
      }
    }

    this.setState({
      selectedAutocompleteIndex: undefined,
      filteredCompletions:     []
    });

    return pushedTag;
  },

  createTagging: function(newTag) {
    this.state.pending.push(newTag);

    // DEBUGGING: replace with actual Ajax request
    setTimeout(function() {
      var pending = this.state.pending.slice(0);
      pending.splice(pending.indexOf(newTag), 1);
      this.setState({pending: pending});
    }.bind(this), 1000);
  },

  // callback invoked when someone clicks on an autocomplete suggestion
  onTagPush: function(newTag) {
    var input = this.refs.tagInput.getDOMNode();
    input.value = '';
    this.pushTag(newTag);
  },

  // callback invokved when someone "selects" an autocomplete suggestion via
  // mouseEnter
  onAutocompleteSelect: function(element) {
    var tagIdx = this.state.filteredCompletions.indexOf(element.innerHTML);
    this.setState({selectedAutocompleteIndex: tagIdx});
  },

  onTagPop: function() {
    if (this.state.tags.length) {
      this.clearDuplicateMarker();
      this.setState({tags: this.state.tags.slice(0, -1)});
    }
  },

  onTagSelect: function(name) {
    this.setState({selectedPillIndex: this.state.tags.indexOf(name)});
    this.forceFocus();
  },

  onTagDelete: function(name) {
    this.clearDuplicateMarker();
    var tags = this.state.tags.slice(0);
    tags.splice(tags.indexOf(name), 1)
    this.setState({tags: tags});
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

      return (
        <TagPill
          name={name}
          isDuplicate={isDuplicate}
          isPending={isPending}
          isSelected={isSelected}
          onTagSelect={this.onTagSelect}
          onTagDelete={this.onTagDelete}
        />
      );
    }, this);

    return (
      <div
        tabIndex="0"
        className="tagWidget"
        onChange={this.handleChange}
        onClick={this.handleClick}
        onDragStart={this.handleDragStart}
        onKeyDown={this.handleKeyDown}
        onBlur={this.handleBlur}
        onFocus={this.handleFocus}>
        {tagPills}
        <input
          type="hidden"
          name={this.props.resourceName}
          value={this.state.tags.join(' ')}
        />
        <TagInput
          ref="tagInput"
          onTagPop={this.onTagPop}
          onShiftTab={this.onShiftTab}
        />
        <TagAutocomplete
          completions={this.state.filteredCompletions}
          selectedIdx={this.state.selectedAutocompleteIndex}
          onTagPush={this.onTagPush}
          onAutocompleteSelect={this.onAutocompleteSelect}
        />
      </div>
    );
  },
});

module.exports = TagWidget;
