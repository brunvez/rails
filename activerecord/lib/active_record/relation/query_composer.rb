# frozen_string_literal: true

module ActiveRecord
  class QueryComposer
    def initialize(scope)
      @scope = scope
      @arel_table = scope.arel_table
      @reflections = scope._reflections
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
      attr_reader :scope, :arel_table, :reflections

      def define_attribute_accessors
        scope.attribute_names.each do |attr|
          define_singleton_method attr do
            @attribute_nodes[attr] ||= Node.new(arel_table[attr])
          end
        end
      end

      class Node
        MAPPED_METHODS = {
          eq: :==,
          not_eq: :!=,
          gt: :>,
          gteq: :>=,
          lt: :<,
          lteq: :<=,
          in: :in,
          and: :and,
          or: :or,
          matches: :like,
          does_not_match: :not_like
        }

        def initialize(arel_node)
          @arel_node = arel_node
        end

        MAPPED_METHODS.each do |arel_method, exposed_method|
          define_method exposed_method do |other|
            other = other.arel_node if self.class == other.class
            Node.new(arel_node.public_send(arel_method, other))
          end
        end

        def to_arel
          arel_node
        end

        protected
          attr_reader :arel_node
      end
  end
end
