# frozen_string_literal: true

module ActiveRecord
  class SqlContext
    def coalesce(*args)
      exprs = args.map { |arg| arg_to_expression(arg) }

      ArelNodeWrapper.new(Arel::Nodes::NamedFunction.new(
        "COALESCE",
        exprs
      ))
    end

    def lower(arg)
      ArelNodeWrapper.new(Arel::Nodes::NamedFunction.new(
        "LOWER",
        [arg_to_expression(arg)]
      ))
    end

    private
      def arg_to_expression(arg)
        if arg.respond_to?(:to_arel)
          arg.to_arel
        else
          Arel::Nodes.build_quoted(arg)
        end
      end
  end
end
