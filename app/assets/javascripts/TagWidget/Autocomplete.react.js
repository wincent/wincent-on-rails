'use strict';

var React = require('react/addons');

var cx = React.addons.classSet;

// keep in sync with _TagAutocomplete.scss
// TODO: figure out how to share constants between Sass and broswerified JS
var VISIBLE_AUTOCOMPLETE_ENTRIES = 10;

class Autocomplete extends React.Component {
  componentDidUpdate() {
    var menu      = React.findDOMNode(this);
    var selection = this._selected && React.findDOMNode(this._selected);

    if (selection) {
      // is selection off the bottom of the scrollable area?
      var count = VISIBLE_AUTOCOMPLETE_ENTRIES,
          delta = selection.offsetTop -
                  (menu.scrollTop + count * selection.clientHeight);
      if (delta > 0) {
        menu.scrollTop += (delta + selection.clientHeight);
      }

      // is selection off the top of the scrollable area?
      delta = menu.scrollTop - selection.offsetTop;
      if (delta > 0) {
        menu.scrollTop -= delta;
      }
    }
  }

  handleClick(event) {
    this.props.onTagPush(event.target.innerHTML);
  }

  handleMouseEnter(event) {
    // at the moment React supports mouseEnter but not mouseOver (see:
    // https://github.com/facebook/react/issues/340); this is fine, as
    // mouseEnter is actually better, but it also explains why things look a
    // little weird here: we have to "unpack" the native event below, and it
    // appears to be a mouseOut event under the covers
    this.props.onAutocompleteSelect(event.nativeEvent.toElement);
  }

  render() {
    var completions = this.props.completions.map(function(completion, i) {
      if (this.props.selectedIdx === i) {
        return (
          <li
            className="TagAutocomplete selected"
            key={completion}
            onClick={this.handleClick.bind(this)}
            onMouseEnter={this.handleMouseEnter.bind(this)}
            ref={ref => this._selected = ref}>
            {completion}
          </li>
        );
      } else {
        return (
          <li
            key={completion}
            onClick={this.handleClick.bind(this)}
            onMouseEnter={this.handleMouseEnter.bind(this)}>
            {completion}
          </li>
        );
      }
    }, this);

    var classes = cx({
      'tagAutocomplete': true,
      'active': this.props.completions.length
    });

    return (
      <div className={classes}>
        <ul>{completions}</ul>
      </div>
    );
  }
}

module.exports = Autocomplete;
