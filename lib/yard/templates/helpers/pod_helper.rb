module YARD
  module Templates::Helpers
    module PODHelper
      include MarkupHelper
      include ModuleHelper

      def format(str)
        Formatters::PODFormatter.new(options[:files].first, @object).convert(str)
      end
    end
  end
end