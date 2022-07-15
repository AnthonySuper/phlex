# frozen_string_literal: true

module Phlex
  class Tag
    DASH = "-"
    SPACE = " "
    UNDERSCORE = "_"
    NAMESPACE_DELINEATOR = "::"

    attr_reader :tag_name

    def initialize(tag_name:, **attributes)
      @tag_name = tag_name
      @classes = String.new
      self.attributes = attributes
    end

    def attributes=(attributes)
      self.classes = attributes.delete(:class)
      @attributes = attributes
    end

    def classes=(value)
      case value
      when String
        @classes << value.prepend(SPACE)
      when Symbol
        @classes << value.to_s.prepend(SPACE)
      when Array
        @classes << value.join(SPACE).prepend(SPACE)
      when nil
        return
      else
        raise ArgumentError, "Classes must be String, Symbol, or Array<String>."
      end
    end

    private

    def opening_tag_content
      tag_name + attributes
    end

    def attributes
      attributes = @attributes.dup
      attributes[:class] = classes
      attributes.compact!
      attributes.transform_values! { ERB::Util.html_escape(_1) }
      attributes = attributes.map { |k, v| %Q(#{k}="#{v}") }.join(SPACE)
      attributes.prepend(SPACE) unless attributes.empty?
      attributes
    end

    def classes
      return if @classes.empty?
      @classes.gsub!(UNDERSCORE, DASH)
      @classes.strip!
      @classes
    end
  end
end
