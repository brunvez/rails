# frozen_string_literal: true

module ActiveRecord
  class QueryComposer
    def initialize(model)
      @model = model
      @arel_table = model.arel_table
      @reflections = model._reflections
      @attribute_nodes = {}
      define_attribute_accessors
    end

    def method_missing(name, *_args)
      if reflections.key?(name.to_s)
        self.class.new(reflections[name.to_s].klass)
      else
        super
      end
    end

    private
      attr_reader :model, :arel_table, :reflections

      def define_attribute_accessors
        model.attribute_names.each do |attr|
          define_singleton_method attr do
            @attribute_nodes[attr] ||= ArelNodeWrapper.new(arel_table[attr])
          end
        end
      end
  end

  class ArelNodeWrapper
    MAPPED_METHODS = {
      eq: :==,
      not_eq: :!=,
      gt: :>,
      gteq: :>=,
      lt: :<,
      lteq: :<=,
      in: :in,
      and: :and,
      or: :or
    }

    def initialize(node)
      @node = node
    end

    MAPPED_METHODS.each do |arel_method, exposed_method|
      define_method exposed_method do |other|
        other = other.node if other.is_a?(ArelNodeWrapper)
        ArelNodeWrapper.new(node.public_send(arel_method, other))
      end
    end

    def to_arel
      node
    end

    protected
      attr_reader :node
  end
end
