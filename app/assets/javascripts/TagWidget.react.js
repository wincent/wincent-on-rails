/**
 * @jsx React.DOM
 */

'use strict';

var React = require('react/addons');

var Keys = require('./Keys');

// The TagWidget provides tag "pilling" and autocomplete. It manages a related
// set of subcomponents (TagWidget.Input, TagWidget.Autocomplete,
// TagWidget.Pill).
class TagWidget extends React.Component {
  constructor(props) {
    super(props);
    var tags =
      props.pendingTags &&
      props.pendingTags.trim().length &&
      props.pendingTags.trim().split(/ +/) || [];
    this.state = {
      tags:                       tags,
      availableCompletions:       [],
      filteredCompletions:        [],
      pending:                    [], // for styling purposes
      selectedAutocompleteIndex:  undefined,
      selectedPillIndex:          undefined,
      duplicateTag:               undefined,
    };
  }

  componentDidMount() {
    // get available completions from the server
    var request = new XMLHttpRequest();
    request.open('GET', '/tags.json');

    request.onreadystatechange = () => {
      if (request.status === 200 && request.readyState === 4) {
        this.setState({
          availableCompletions: JSON.parse(request.responseText)
        });
      }
    };

    request.send();
  }

  // Takes the available completions and filters them based on TagInput value
  filterCompletions(string) {
    if (string === '') {
      return []; // don't show suggestions if user hasn't inputed anything
    } else {
      return this.state.availableCompletions.filter(function(completion) {
        // candidate must match, and must not already be present in tags list
        return completion.indexOf(string) !== -1 &&
        this.state.tags.indexOf(completion) === -1;
      }, this);
    }
  }

  // Remove the duplicate marker from a tag.
  //
  // If the user tries to add the same tag twice, we apply some styling to the
  // previously added tag as a hint. This method removes that styling.
  clearDuplicateMarker() {
    if (this.state.duplicateTag) {
      this.setState({duplicateTag: undefined});
    }
  }

  onShiftTab() {
    var event = document.createEvent('Events');
    event.initEvent('keydown', true, true);
    event.keyIdentifier = 'U+0009';
    event.keyCode = Keys.TAB;
    event.which = Keys.TAB;
    event.shiftKey = true;

    this.forceFocus();
    React.findDOMNode(this).dispatchEvent(event);
  }

  handleClick(event) {
    // if outside of input area, focus input
    var tagInput = React.findDOMNode(this._tagInput);
    if (event.target !== tagInput) {
      tagInput.focus();
    }
  }

  // re-filter the autocomplete list on any input,
  // clear duplicate indicator
  handleChange(event) {
    var tagInput = React.findDOMNode(this._tagInput);
    if (event.target === tagInput) {
      var oldList = this.state.filteredCompletions,
          newList = this.filterCompletions(tagInput.value);

      if (newList.length !== oldList.length ||
        newList.some((string, idx) => oldList[idx] !== string)) {
        this.setState({filteredCompletions: newList});
      }

      this.clearDuplicateMarker();
    }
  }

  // Pressing left will select the next pill to the left.
  //
  // If the cursor is not at the left of the input field (ie. not next to the
  // pills), does nothing.
  handleLeftKeyDown(event) {
    var input = React.findDOMNode(this._tagInput);
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
  }

  // Pressing right will select the next pill to the right.
  //
  // If no pill is selected, does nothing.
  handleRightKeyDown() {
    if (typeof this.state.selectedPillIndex !== 'undefined') {
      if (this.state.selectedPillIndex < this.state.tags.length - 1) {
        this.setState({selectedPillIndex: this.state.selectedPillIndex + 1});
      } else {
        this.setState({selectedPillIndex: undefined});
        React.findDOMNode(this._tagInput).focus();
      }
      event.preventDefault();
    }
  }

  // Deletes any selected pill.
  //
  // Does nothing if no pill is selected.
  handleDelete(event) {
    if (typeof this.state.selectedPillIndex !== 'undefined') {
      var tags = this.state.tags.slice(0),
          index;
      tags.splice(this.state.selectedPillIndex, 1)

      if (this.state.selectedPillIndex < tags.length) {
        index = this.state.selectedPillIndex;
      } else {
        // deleting the last tag
        React.findDOMNode(this._tagInput).focus();
      }

      this.setState({tags: tags, selectedPillIndex: index});

      event.preventDefault(); // don't let backspace perform page navigation
    }
  }

  handleKeyDown(event) {
    var keyCode        = event.keyCode,
        completions    = this.state.filteredCompletions,
        maxSelectedIdx = completions.length - 1, // -1 if no completions
        oldSelectedIdx = this.state.selectedAutocompleteIndex,
        newSelectedIdx;

    if (keyCode === Keys.LEFT) {
      return this.handleLeftKeyDown(event);
    } else if (keyCode === Keys.RIGHT) {
      return this.handleRightKeyDown();
    } else if (keyCode === Keys.BACKSPACE || keyCode === Keys.DELETE) {
      return this.handleDelete(event);
    } else if (keyCode === Keys.ESCAPE) {
      React.findDOMNode(this._tagInput).blur();
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
          React.findDOMNode(this._tagInput).value = '';
          this.pushTag(this.state.filteredCompletions[oldSelectedIdx]);
        } else {
          // non-special keys are allowed to pass through
          return;
        }
    } else if (keyCode === Keys.RETURN) {
      // no completions selected; add currently inputed text
      var input = React.findDOMNode(this._tagInput),
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
  }

  // On losing focus, clear selection from selected pill.
  handleBlur(event) {
    if (typeof this.state.selectedPillIndex !== 'undefined' &&
        React.findDOMNode(this) === event.target) {
      this.setState({selectedPillIndex: undefined});
    }
  }

  handleFocus(event) {
    if (!this.forcingFocus) {
      // likely we were tabbed into; forward focus to the TagInput
      React.findDOMNode(this._tagInput).focus();
    } else {
      this.forcingFocus = false;
    }
  }

  /**
   * @returns true if a tag was actually pushed
   */
  pushTag(newTag) {
    newTag = newTag
      .trim()
      .toLowerCase()
      .replace(/ +/g, '.')          // spaces become dots
      .replace(/[^a-z0-9.]+/gi, '') // all other illegal chars get eaten
      .replace(/\.\.+/g, '.');      // consecutive dots get squished

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
  }

  createTagging(newTag) {
    this.state.pending.push(newTag);

    // DEBUGGING: replace with actual Ajax request
    setTimeout(() => {
      var pending = this.state.pending.slice(0);
      pending.splice(pending.indexOf(newTag), 1);
      this.setState({pending: pending});
    }, 1000);
  }

  // callback invoked when someone clicks on an autocomplete suggestion
  onTagPush(newTag) {
    var input = React.findDOMNode(this._tagInput);
    input.value = '';
    this.pushTag(newTag);
  }

  // callback invokved when someone "selects" an autocomplete suggestion via
  // mouseEnter
  onAutocompleteSelect(element) {
    var tagIdx = this.state.filteredCompletions.indexOf(element.innerHTML);
    this.setState({selectedAutocompleteIndex: tagIdx});
  }

  onTagPop() {
    if (this.state.tags.length) {
      this.clearDuplicateMarker();
      this.setState({tags: this.state.tags.slice(0, -1)});
    }
  }

  onTagSelect(name) {
    this.setState({selectedPillIndex: this.state.tags.indexOf(name)});
    this.forceFocus();
  }

  onTagDelete(name) {
    this.clearDuplicateMarker();
    var tags = this.state.tags.slice(0);
    tags.splice(tags.indexOf(name), 1)
    this.setState({tags: tags});
  }

  forceFocus() {
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
    React.findDOMNode(this).focus();
  }

  _renderTagPills() {
    return this.state.tags.map((name, i) => (
      <TagWidget.Pill
        isDuplicate={name === this.state.duplicateTag}
        isPending={this.state.pending.indexOf(name) !== -1}
        isSelected={i === this.state.selectedPillIndex}
        key={name}
        name={name}
        onTagDelete={this.onTagDelete.bind(this)}
        onTagSelect={this.onTagSelect.bind(this)}
      />
    ));
  }

  render() {
    return (
      <div
        className="tagWidget"
        onBlur={this.handleBlur.bind(this)}
        onChange={this.handleChange.bind(this)}
        onClick={this.handleClick.bind(this)}
        onFocus={this.handleFocus.bind(this)}
        onKeyDown={this.handleKeyDown.bind(this)}
        tabIndex="0">
        {this._renderTagPills()}
        <TagWidget.Input
          name={this.props.resourceName}
          onShiftTab={this.onShiftTab.bind(this)}
          onTagPop={this.onTagPop.bind(this)}
          ref={ref => this._tagInput = ref}
        />
        <input
          name={this.props.resourceName}
          type="hidden"
          value={this.state.tags.join(' ')}
        />
        <TagWidget.Autocomplete
          completions={this.state.filteredCompletions}
          onAutocompleteSelect={this.onAutocompleteSelect.bind(this)}
          onTagPush={this.onTagPush.bind(this)}
          selectedIdx={this.state.selectedAutocompleteIndex}
        />
      </div>
    );
  }
}

TagWidget.Autocomplete = require('./TagWidget/Autocomplete.react');
TagWidget.Input = require('./TagWidget/Input.react');
TagWidget.Pill = require('./TagWidget/Pill.react');

module.exports = TagWidget;
