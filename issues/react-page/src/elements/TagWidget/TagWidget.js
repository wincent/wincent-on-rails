/**
 * Copyright 2013 Facebook, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @jsx React.DOM
 */
"use strict";

var React               = require("React"),
    ReactStyle          = require("ReactStyle"),
    TagPill             = require("../TagPill/TagPill.js"),
    TagInput            = require("../TagInput/TagInput.js"),
    TagWidgetStyleRules = require("../TagWidget/TagWidgetStyleRules.js");

ReactStyle.addRules(TagWidgetStyleRules);

var TagWidget = React.createClass({
  getInitialState: function() {
    return { data: ['foo', 'bar', 'foo.bar'] };
  },

  componentDidMount: function() {
  },

  componentWillUnmount: function() {
  },

  handleClick: function(event) {
    // if outside of input area, focus input
    var tagInput = this.refs.tagInput.getDOMNode();
    if (event.target !== tagInput) {
      tagInput.focus();
    }
  },

  handleTagInput: function(newTag) {
    this.state.data.push(newTag);
    this.setState(this.state);
  },

  render: function() {
    return (
      <div className={TagWidgetStyleRules.tagWidget}
           onClick={this.handleClick}>
        {this.state.data.map(function(s) { return <TagPill name={s} />; })}
        <TagInput ref="tagInput"
                  onTagInput={this.handleTagInput} />
      </div>
    );
  },
});

module.exports = TagWidget;
