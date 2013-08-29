gumbo-rb
========

Ruby binding for [gumbo parser](https://github.com/google/gumbo-parser), via [ffi](https://github.com/ffi/ffi)

Get started
------------

Install
[gumbo-parser](https://github.com/google/gumbo-parser#installation) by
follow the instructions. And

`gem i gumbo-rb`

Examples
--------------

```ruby
require 'gumbo'

text = IO.read(File.expand_path("../test_data/index.html", __FILE__))

doc = Gumbo.parse(text)

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

else
  title = title_node.content.children[0]
  puts title.content
end
```

checkout more
[examples](https://github.com/isaiah/gumbo-rb/tree/master/examples)


