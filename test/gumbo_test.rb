require_relative './test_helper'

class TestGumbo < MiniTest::Unit::TestCase
        def setup
        end

        def test_word_parse
                output = Gumbo.parse("Test")
                doctype_node = output.document
                assert_equals(doctype_node.type, :document)
        end
end
