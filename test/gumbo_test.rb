require_relative './test_helper'

class TestGumbo < MiniTest::Unit::TestCase
  def setup
  end

  def test_word_parse
    output = Gumbo.parse("Test")
    doctype_node = output[:document]
    assert_equal(:document, doctype_node.type)
    document = doctype_node[:v][:document]
    assert_equal('', document[:name])
    assert_equal('', document[:public_identifier])
    assert_equal('', document[:system_identifier])

    root = output[:root]
    assert(root.element?)
    assert(root.html_tag?)
    assert(root.html_ns?)
    assert_equal(2, root.children.length)

    head = root.children[0]
    assert(head.element?)
  end
end
