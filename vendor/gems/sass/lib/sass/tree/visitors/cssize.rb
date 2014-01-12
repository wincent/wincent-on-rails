# A visitor for converting a static Sass tree into a static CSS tree.
class Sass::Tree::Visitors::Cssize < Sass::Tree::Visitors::Base
  # @param root [Tree::Node] The root node of the tree to visit.
  # @return [(Tree::Node, Sass::Util::SubsetMap)] The resulting tree of static nodes
  #   *and* the extensions defined for this tree
  def self.visit(root); super; end

  protected

  # Returns the immediate parent of the current node.
  # @return [Tree::Node]
  attr_reader :parent

  def initialize
    @parent_directives = []
    @extends = Sass::Util::SubsetMap.new
  end

  # If an exception is raised, this adds proper metadata to the backtrace.
  def visit(node)
    super(node)
  rescue Sass::SyntaxError => e
    e.modify_backtrace(:filename => node.filename, :line => node.line)
    raise e
  end

  # Keeps track of the current parent node.
  def visit_children(parent)
    with_parent parent do
      parent.children = visit_children_without_parent(parent)
      parent
    end
  end

  # Like {#visit\_children}, but doesn't set {#parent}.
  #
  # @param node [Sass::Tree::Node]
  # @return [Array<Sass::Tree::Node>] the flattened results of
  #   visiting all the children of `node`
  def visit_children_without_parent(node)
    node.children.map {|c| visit(c)}.flatten
  end

  MERGEABLE_DIRECTIVES = [Sass::Tree::MediaNode]

  # Runs a block of code with the current parent node
  # replaced with the given node.
  #
  # @param parent [Tree::Node] The new parent for the duration of the block.
  # @yield A block in which the parent is set to `parent`.
  # @return [Object] The return value of the block.
  def with_parent(parent)
    if parent.is_a?(Sass::Tree::DirectiveNode)
      if MERGEABLE_DIRECTIVES.any? {|klass| parent.is_a?(klass)}
        old_parent_directive = @parent_directives.pop
      end
      @parent_directives.push parent
    end

    old_parent, @parent = @parent, parent
    yield
  ensure
    @parent_directives.pop if parent.is_a?(Sass::Tree::DirectiveNode)
    @parent_directives.push old_parent_directive if old_parent_directive
    @parent = old_parent
  end

  # In Ruby 1.8, ensures that there's only one `@charset` directive
  # and that it's at the top of the document.
  #
  # @return [(Tree::Node, Sass::Util::SubsetMap)] The resulting tree of static nodes
  #   *and* the extensions defined for this tree
  def visit_root(node)
    yield

    if parent.nil?
      # In Ruby 1.9 we can make all @charset nodes invisible
      # and infer the final @charset from the encoding of the final string.
      if Sass::Util.ruby1_8?
        charset = node.children.find {|c| c.is_a?(Sass::Tree::CharsetNode)}
        node.children.reject! {|c| c.is_a?(Sass::Tree::CharsetNode)}
        node.children.unshift charset if charset
      end

      imports = Sass::Util.extract!(node.children) do |c|
        c.is_a?(Sass::Tree::DirectiveNode) && !c.is_a?(Sass::Tree::MediaNode) &&
          c.resolved_value =~ /^@import /i
      end
      charset_and_index = Sass::Util.ruby1_8? &&
        node.children.each_with_index.find {|c, _| c.is_a?(Sass::Tree::CharsetNode)}
      if charset_and_index
        index = charset_and_index.last
        node.children = node.children[0..index] + imports + node.children[index + 1..-1]
      else
        node.children = imports + node.children
      end
    end

    return node, @extends
  rescue Sass::SyntaxError => e
    e.sass_template ||= node.template
    raise e
  end

  # A simple struct wrapping up information about a single `@extend` instance. A
  # single {ExtendNode} can have multiple Extends if either the parent node or
  # the extended selector is a comma sequence.
  #
  # @attr extender [Sass::Selector::Sequence]
  #   The selector of the CSS rule containing the `@extend`.
  # @attr target [Array<Sass::Selector::Simple>] The selector being `@extend`ed.
  # @attr node [Sass::Tree::ExtendNode] The node that produced this extend.
  # @attr directives [Array<Sass::Tree::DirectiveNode>]
  #   The directives containing the `@extend`.
  # @attr result [Symbol]
  #   The result of this extend. One of `:not_found` (the target doesn't exist
  #   in the document), `:failed_to_unify` (the target exists but cannot be
  #   unified with the extender), or `:succeeded`.
  Extend = Struct.new(:extender, :target, :node, :directives, :result)

  # Registers an extension in the `@extends` subset map.
  def visit_extend(node)
    node.resolved_selector.members.each do |seq|
      if seq.members.size > 1
        raise Sass::SyntaxError.new("Can't extend #{seq.to_a.join}: can't extend nested selectors")
      end

      sseq = seq.members.first
      if !sseq.is_a?(Sass::Selector::SimpleSequence)
        raise Sass::SyntaxError.new("Can't extend #{seq.to_a.join}: invalid selector")
      elsif sseq.members.any? {|ss| ss.is_a?(Sass::Selector::Parent)}
        raise Sass::SyntaxError.new("Can't extend #{seq.to_a.join}: can't extend parent selectors")
      end

      sel = sseq.members
      parent.resolved_rules.members.each do |member|
        unless member.members.last.is_a?(Sass::Selector::SimpleSequence)
          raise Sass::SyntaxError.new("#{member} can't extend: invalid selector")
        end

        @extends[sel] = Extend.new(member, sel, node, @parent_directives.dup, :not_found)
      end
    end

    []
  end

  # Modifies exception backtraces to include the imported file.
  def visit_import(node)
    visit_children_without_parent(node)
  rescue Sass::SyntaxError => e
    e.modify_backtrace(:filename => node.children.first.filename)
    e.add_backtrace(:filename => node.filename, :line => node.line)
    raise e
  end

  # Bubbles the `@media` directive up through RuleNodes
  # and merges it with other `@media` directives.
  def visit_media(node)
    yield unless bubble(node)

    bubbled = node.children.select do |n|
      n.is_a?(Sass::Tree::AtRootNode) || n.is_a?(Sass::Tree::MediaNode)
    end
    node.children -= bubbled

    bubbled = bubbled.map do |n|
      next visit(n) if n.is_a?(Sass::Tree::AtRootNode)
      # Otherwise, n should be a MediaNode.
      next [] unless n.resolved_query = n.resolved_query.merge(node.resolved_query)
      n
    end.flatten

    (node.children.empty? ? [] : [node]) + bubbled
  end

  # Bubbles the `@supports` directive up through RuleNodes.
  def visit_supports(node)
    visit_directive(node) {yield}
  end

  # Asserts that all the traced children are valid in their new location.
  def visit_trace(node)
    visit_children_without_parent(node)
  rescue Sass::SyntaxError => e
    e.modify_backtrace(:mixin => node.name, :filename => node.filename, :line => node.line)
    e.add_backtrace(:filename => node.filename, :line => node.line)
    raise e
  end

  # Bubbles a directive up through RuleNodes.
  def visit_directive(node)
    return yield unless node.has_children
    yield unless (bubbled = bubble(node))
    at_roots = node.children.select {|n| n.is_a?(Sass::Tree::AtRootNode)}
    node.children -= at_roots
    at_roots.map! {|n| visit(n)}.flatten
    (bubbled && node.children.empty? ? [] : [node]) + at_roots
  end

  # Converts nested properties into flat properties
  # and updates the indentation of the prop node based on the nesting level.
  def visit_prop(node)
    if parent.is_a?(Sass::Tree::PropNode)
      node.resolved_name = "#{parent.resolved_name}-#{node.resolved_name}"
      node.tabs = parent.tabs + (parent.resolved_value.empty? ? 0 : 1) if node.style == :nested
    end

    yield

    result = node.children.dup
    if !node.resolved_value.empty? || node.children.empty?
      node.send(:check!)
      result.unshift(node)
    end

    result
  end

  # Updates the indentation of the rule node based on the nesting
  # level. The selectors were resolved in {Perform}.
  def visit_rule(node)
    yield

    rules = node.children.select {|c| c.is_a?(Sass::Tree::RuleNode) || c.bubbles?}
    props = node.children.reject {|c| c.is_a?(Sass::Tree::RuleNode) || c.bubbles? || c.invisible?}

    rules.map {|c| c.is_a?(Sass::Tree::AtRootNode) ? visit(c) : c}.flatten

    unless props.empty?
      node.children = props
      rules.each {|r| r.tabs += 1} if node.style == :nested
      rules.unshift(node)
    end

    rules.last.group_end = true unless parent.is_a?(Sass::Tree::RuleNode) || rules.empty?

    rules
  end

  def visit_atroot(node)
    if @parent_directives.any? {|n| node.exclude_node?(n)}
      return node if node.exclude_node?(parent)

      new_rule = parent.dup
      new_rule.children = node.children
      node.children = [new_rule]
      return node
    end

    results = visit_children_without_parent(node)
    results.each {|n| n.tabs += node.tabs}
    results.last.group_end = node.group_end unless results.empty?
    results
  end

  private

  def bubble(node)
    return unless parent.is_a?(Sass::Tree::RuleNode)
    new_rule = parent.dup
    new_rule.children = node.children
    node.children = with_parent(node) {Array(visit(new_rule))}
    # If the last child is actually the end of the group,
    # the parent's cssize will set it properly
    node.children.last.group_end = false unless node.children.empty?
    true
  end
end
