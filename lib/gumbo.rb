require "ffi"

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

  AttributeNamespace = enum(:none, :xlink, :xml, :xmlns)

  class Attribute < FFI::Struct
    layout :namespace, AttributeNamespace,
      :name, :string,
      :original_name, StringPiece,
      :value, :string,
      :original_value, StringPiece,
      :name_start, SourcePosition,
      :name_end, SourcePosition,
      :value_start, SourcePosition,
      :value_end, SourcePosition

    def namespace
      self[:namespace]
    end

    def name
      self[:name]
    end

    def value
      self[:value]
    end

    AttributeNamespace.symbols.each do |attr|
      define_method "#{attr.to_s}?" do
        self[:namespace] == attr
      end
    end
  end

  class Vector < FFI::Struct
    layout :data, :pointer,
      :length, :uint,
      :capacity, :uint

    @@type = FFI::Pointer

    include Enumerable

    def length
      self.get(:length)
    end

    alias_method :size, :length

    alias_method :get, :[]

    def data
      @data ||= self.get(:data).read_array_of_pointer(self.length)
    end

    def [](idx)
      if idx < self.length
        @@type.new(self.data[idx])
      end
    end

    def each
      data.each{|ptr| yield @@type.new(ptr)}
    end

    def <=>(a, b)
      0
    end

    def self.type=(t)
      @@type = t
    end
  end

  class NodeVector < Vector
    layout :data, :pointer,
      :length, :uint,
      :capacity, :uint
  end

  class AttributeVector < Vector
    layout :data, :pointer,
      :length, :uint,
      :capacity, :uint

    @@type = Attribute
  end


  enum :quirks_mode, [:no_quirks, :quirks, :limited_quirks]

  class Document < FFI::Struct
    layout :children, NodeVector,
      :has_doctype, :bool,
      :name, :string,
      :public_identifier, :string,
      :system_identifier, :string,
      :doc_type_quirks_mode, :quirks_mode

    def name
      self[:name]
    end

    def children
      self[:children]
    end

    def to_s
      "Document"
    end
  end

  TagNamespace = enum :html, :svg, :mahtml

  HTML_TAG = enum(:HTML,
                  :HEAD,
                  :TITLE,
                  :BASE,
                  :LINK,
                  :META,
                  :STYLE,
                  :SCRIPT,
                  :NOSCRIPT,
                  :BODY,
                  :SECTION,
                  :NAV,
                  :ARTICLE,
                  :ASIDE,
                  :H1,
                  :H2,
                  :H3,
                  :H4,
                  :H5,
                  :H6,
                  :HGROUP,
                  :HEADER,
                  :FOOTER,
                  :ADDRESS,
                  :P,
                  :HR,
                  :PRE,
                  :BLOCKQUOTE,
                  :OL,
                  :UL,
                  :LI,
                  :DL,
                  :DT,
                  :DD,
                  :FIGURE,
                  :FIGCAPTION,
                  :DIV,
                  :A,
                  :EM,
                  :STRONG,
                  :SMALL,
                  :S,
                  :CITE,
                  :Q,
                  :DFN,
                  :ABBR,
                  :TIME,
                  :CODE,
                  :VAR,
                  :SAMP,
                  :KBD,
                  :SUB,
                  :SUP,
                  :I,
                  :B,
                  :MARK,
                  :RUBY,
                  :RT,
                  :RP,
                  :BDI,
                  :BDO,
                  :SPAN,
                  :BR,
                  :WBR,
                  :INS,
                  :DEL,
                  :IMAGE,
                  :IMG,
                  :IFRAME,
                  :EMBED,
                  :OBJECT,
                  :PARAM,
                  :VIDEO,
                  :AUDIO,
                  :SOURCE,
                  :TRACK,
                  :CANVAS,
                  :MAP,
                  :AREA,
                  :MATH,
                  :MI,
                  :MO,
                  :MN,
                  :MS,
                  :MTEXT,
                  :MGLYPH,
                  :MALIGNMARK,
                  :ANNOTATION_XML,
                  :SVG,
                  :FOREIGNOBJECT,
                  :DESC,
                  :TABLE,
                  :CAPTION,
                  :COLGROUP,
                  :COL,
                  :TBODY,
                  :THEAD,
                  :TFOOT,
                  :TR,
                  :TD,
                  :TH,
                  :FORM,
                  :FIELDSET,
                  :LEGEND,
                  :LABEL,
                  :INPUT,
                  :BUTTON,
                  :SELECT,
                  :DATALIST,
                  :OPTGROUP,
                  :OPTION,
                  :TEXTAREA,
                  :KEYGEN,
                  :OUTPUT,
                  :PROGRESS,
                  :METER,
                  :DETAILS,
                  :SUMMARY,
                  :COMMAND,
                  :MENU,
                  :APPLET,
                  :ACRONYM,
                  :BGSOUND,
                  :DIR,
                  :FRAME,
                  :FRAMESET,
                  :NOFRAMES,
                  :ISINDEX,
                  :LISTING,
                  :XMP,
                  :NEXTID,
                  :NOEMBED,
                  :PLAINTEXT,
                  :RB,
                  :STRIKE,
                  :BASEFONT,
                  :BIG,
                  :BLINK,
                  :CENTER,
                  :FONT,
                  :MARQUEE,
                  :MULTICOL,
                  :NOBR,
                  :SPACER,
                  :TT,
                  :U,
                  :UNKNOWN)

  class Element < FFI::Struct
    layout :children, NodeVector,
      :tag, HTML_TAG,
      :tag_namespace, TagNamespace,
      :original_tag, StringPiece,
      :original_end_tag, StringPiece,
      :start_pos, SourcePosition,
      :end_pos, SourcePosition,
      :attributes, AttributeVector

    def tag
      self[:tag]
    end

    def namespace
      self[:tag_namespace]
    end

    def original_tag
      self[:original_tag][:data]
    end

    def attributes
      self[:attributes]
    end

    def attribute(name)
      self.attributes.find{|x| x.name == name}.value
    end

    def children
      self[:children]
    end

    HTML_TAG.symbols.each do |tag|
      define_method "#{tag.to_s.downcase}_tag?" do
        self[:tag] == tag
      end
    end

    TagNamespace.symbols.each do |ns|
      define_method "#{ns.to_s}_ns?" do
        self[:tag_namespace] == ns
      end
    end
  end

  class Text < FFI::Struct
    layout :text, :string,
      :original_text, StringPiece,
      :start_pos, SourcePosition

    def to_s
      self[:text]
    end
  end

  NodeType = enum(:document, :element, :text, :cdata, :comment, :whitespace)

  class NodeUnion < FFI::Union
    layout :document, Document,
      :element, Element,
      :text, Text
  end

  class Node < FFI::Struct
    layout :type, NodeType,
      :parent, :pointer,
      :index_within_parent, :size_t,
      :parse_flags, :pointer,
      :v, NodeUnion

    def type
      self[:type]
    end

    def content
      NodeType[self.type] < 2 ? self[:v][self.type] : self[:v][:text]
    end

    def method_missing(name, *args)
      content.respond_to?(name) ? content.send(name) : content[name]
    end

    NodeType.symbols.each do |nt|
      define_method "#{nt}?" do
        self[:type] == nt
      end
    end
  end

  NodeVector.type = Node

  class Options < FFI::Struct
    layout :alocator, :pointer,
      :deallocator, :pointer,
      :tab_stop, :int,
      :stop_on_first_error, :bool,
      :max_utf8_decode_errors, :int,
      :verbatim_mode, :bool,
      :preserve_entities, :bool
  end

  class HTML < FFI::Struct
    layout :document, Node.ptr,
      :root, Node.ptr,
      :errors, Vector

    def document
      self[:document][:v][:document]
    end

    def root
      self[:root][:v][:element]
    end

    def errors
      self[:errors]
    end
  end

  attach_function :parse_with_options, :gumbo_parse_with_options, [:pointer, :string, :size_t], :pointer

  attach_function :parse, :gumbo_parse, [:string], HTML.ptr
end
