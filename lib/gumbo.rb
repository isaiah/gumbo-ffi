require 'ffi'

module Gumbo 
        extend FFI::Library
        if FFI::Platform.mac?
          ffi_lib "/usr/local/lib/libgumbo.dylib"
        else
          ffi_lib "/usr/local/lib/libgumbo.so"
        end

        class StringPiece < FFI::Struct
                layout :data,   :string,
                       :length, :size_t
        end

        class SourcePosition < FFI::Struct
                layout :line, :uint,
                       :column, :uint,
                       :offset, :uint
        end

        enum :attribute_namespace, [:none, :xlink, :xml, :xmlns]

        class Attribute < FFI::Struct
                layout :namespace, :attribute_namespace,
                       :name, :string,
                       :original_name, StringPiece,
                       :value, :string,
                       :original_value, StringPiece,
                       :name_start, SourcePosition,
                       :name_end, SourcePosition,
                       :value_start, SourcePosition,
                       :value_end, SourcePosition

                def name
                  self[:name]
                end

                def value
                  self[:value]
                end
        end

        class Vector < FFI::Struct
                layout :data, :pointer,
                       :length, :uint,
                       :capacity, :uint

                alias_method :get, :[]

                include Enumerable

                def [](idx)
                  if idx < self.get(:length)
                    self.get(:data).get_pointer(idx)
                  end
                end

                def each
                  (0...length).each{|idx| yield self.get(:data).get_pointer(idx)}
                end

                def <=>(a, b)
                  0
                end

                def length
                  self.get(:length)
                end
        end

        AttributeVector = Vector

        NodeVector = Vector

        enum :quirks_mode, [:no_quirks, :quirks, :limited_quirks]

        class Document < FFI::Struct
                include Enumerable
                layout :children, NodeVector,
                       :has_doctype, :bool,
                       :name, :pointer,
                       :public_identifier, :string,
                       :system_identifier, :string,
                       :doc_type_quirks_mode, :quirks_mode

                def each
                end

                def to_s
                        "Document"
                end
        end

        enum :namespace, [:html, :svg, :mahtml]

        enum :tag,  ['HTML',
                     'HEAD',
                     'TITLE',
                     'BASE',
                     'LINK',
                     'META',
                     'STYLE',
                     'SCRIPT',
                     'NOSCRIPT',
                     'BODY',
                     'SECTION',
                     'NAV',
                     'ARTICLE',
                     'ASIDE',
                     'H1',
                     'H2',
                     'H3',
                     'H4',
                     'H5',
                     'H6',
                     'HGROUP',
                     'HEADER',
                     'FOOTER',
                     'ADDRESS',
                     'P',
                     'HR',
                     'PRE',
                     'BLOCKQUOTE',
                     'OL',
                     'UL',
                     'LI',
                     'DL',
                     'DT',
                     'DD',
                     'FIGURE',
                     'FIGCAPTION',
                     'DIV',
                     'A',
                     'EM',
                     'STRONG',
                     'SMALL',
                     'S',
                     'CITE',
                     'Q',
                     'DFN',
                     'ABBR',
                     'TIME',
                     'CODE',
                     'VAR',
                     'SAMP',
                     'KBD',
                     'SUB',
                     'SUP',
                     'I',
                     'B',
                     'MARK',
                     'RUBY',
                     'RT',
                     'RP',
                     'BDI',
                     'BDO',
                     'SPAN',
                     'BR',
                     'WBR',
                     'INS',
                     'DEL',
                     'IMAGE',
                     'IMG',
                     'IFRAME',
                     'EMBED',
                     'OBJECT',
                     'PARAM',
                     'VIDEO',
                     'AUDIO',
                     'SOURCE',
                     'TRACK',
                     'CANVAS',
                     'MAP',
                     'AREA',
                     'MATH',
                     'MI',
                     'MO',
                     'MN',
                     'MS',
                     'MTEXT',
                     'MGLYPH',
                     'MALIGNMARK',
                     'ANNOTATION_XML',
                     'SVG',
                     'FOREIGNOBJECT',
                     'DESC',
                     'TABLE',
                     'CAPTION',
                     'COLGROUP',
                     'COL',
                     'TBODY',
                     'THEAD',
                     'TFOOT',
                     'TR',
                     'TD',
                     'TH',
                     'FORM',
                     'FIELDSET',
                     'LEGEND',
                     'LABEL',
                     'INPUT',
                     'BUTTON',
                     'SELECT',
                     'DATALIST',
                     'OPTGROUP',
                     'OPTION',
                     'TEXTAREA',
                     'KEYGEN',
                     'OUTPUT',
                     'PROGRESS',
                     'METER',
                     'DETAILS',
                     'SUMMARY',
                     'COMMAND',
                     'MENU',
                     'APPLET',
                     'ACRONYM',
                     'BGSOUND',
                     'DIR',
                     'FRAME',
                     'FRAMESET',
                     'NOFRAMES',
                     'ISINDEX',
                     'LISTING',
                     'XMP',
                     'NEXTID',
                     'NOEMBED',
                     'PLAINTEXT',
                     'RB',
                     'STRIKE',
                     'BASEFONT',
                     'BIG',
                     'BLINK',
                     'CENTER',
                     'FONT',
                     'MARQUEE',
                     'MULTICOL',
                     'NOBR',
                     'SPACER',
                     'TT',
                     'U',
                     'UNKNOWN',
                     ]

        class Element < FFI::Struct
                layout :children, NodeVector,
                       :tag, :tag,
                       :tag_namespace, :namespace,
                       :original_tag, StringPiece,
                       :original_end_tag, StringPiece,
                       :start_pos, SourcePosition,
                       :end_pos, SourcePosition,
                       :attributes, AttributeVector

                def attributes
                  self[:attributes]
                end

                def attribute(name)
                  self.attributes.find{|x| x.name == name}.value
                end
        end

        class Text < FFI::Struct
                layout :text, :string,
                       :original_text, StringPiece,
                       :start_pos, SourcePosition
        end

        enum :node_type, [:document, :element, :text, :cdata, :comment, :whitespace]

        class NodeUnion < FFI::Union
                layout :document, Document,
                       :element, Element,
                       :text, Text
        end

        class Node < FFI::Struct
                layout :type, :node_type,
                       :parent, :pointer,
                       :index_within_parent, :size_t,
                       :parse_flags, :pointer,
                       :v, NodeUnion

                def type
                  self[:type]
                end

                def value
                  self[:v][self.type]
                end
        end

        class Options < FFI::Struct
                layout :alocator, :pointer,
                       :deallocator, :pointer,
                       :tab_stop, :int,
                       :stop_on_first_error, :bool,
                       :max_utf8_decode_errors, :int,
                       :verbatim_mode, :bool,
                       :preserve_entities, :bool
        end

        class Output < FFI::Struct
                layout :document, Node.ptr,
                       :root, Node.ptr,
                       :errors, Vector
        end

        attach_function :parse_with_options, :gumbo_parse_with_options, [:pointer, :string, :size_t], :pointer

        attach_function :parse, :gumbo_parse, [:string], Output.ptr

end

if __FILE__ == $0
        text = IO.read(File.expand_path("../../../../c/gumbo-parser/docs/html/index.html", __FILE__))
        ptr = Gumbo.parse(text)
        puts ptr[:document][:index_within_parent]
        puts ptr[:document][:v][:document][:name].read_string
        ptr[:document][:v][:document][:children].each do |pointr|
          node = Gumbo::Node.new(pointr)
          puts Gumbo::Attribute.new(node.value.attributes[0]).value
          puts Gumbo::Attribute.new(node.value.attributes[0]).value
        end
end
