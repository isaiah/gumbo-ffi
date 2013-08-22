$:.unshift(File.expand_path("../../lib", __FILE__))
require 'gumbo'

text = IO.read(File.expand_path("../../../../c/gumbo-parser/docs/html/index.html", __FILE__))
doc = Gumbo.parse(text)

head = nil
root_children = doc.root.children
root_children.each do |child|
  if child.type == :element && child.content.tag == :HEAD
    head = child
    break
  end
end

head_children = head.content.children
head_children.each do |child|
  if child.type == :element && child.content.tag == :TITLE
          if child.content.children.length != 1
                  puts "<empty title>"
                  break
          end
          title = child.content.children[0]
          puts title.content
          break
  end
end
