/**
 * @jsx React.DOM
 */
var React = require('react/addons');

var cloneWithProps = React.addons.cloneWithProps;
var cx = React.addons.classSet;

var Thing = React.createClass({
  render: function() {
    // proof that JSX works
    return cloneWithProps(<span>foo</span>, {});
  }
});

// proof that ES6 transforms work:
['A', 'b', 'c'].map((thing, idx) => thing + ':' + idx);
