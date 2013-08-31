$:.unshift(File.expand_path("../../lib", __FILE__))
require 'gumbo'

text = IO.read(File.expand_path("../test_data/index.html", __FILE__))

Gumbo.parse(text) do |doc|

  root_children = doc.root.children
  head = root_children.find do |child|
    child.type == :element && child.content.tag == :HEAD
  end

  head_children = head.content.children
  title_node = head_children.find do |child|
    child.type == :element && child.content.tag == :TITLE
  end

  if title_node.content.children.length != 1
    puts "<empty title>"
  end

  title = title_node.content.children[0]
  puts title.content
end
