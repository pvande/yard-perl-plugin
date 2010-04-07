require File.dirname(__FILE__) + '/yard/parser/perl'
require File.dirname(__FILE__) + '/yard/handlers/perl/base'
require File.dirname(__FILE__) + '/yard/handlers/perl/package_handler'
require File.dirname(__FILE__) + '/yard/handlers/perl/sub_handler'
require File.dirname(__FILE__) + '/yard/serializers/pod_serializer'



# Monkeypatches for YARD 0.5.4
module YARD
  module Handlers
    class Processor
      alias :handler_base_namespace_without_perl :handler_base_namespace
      def handler_base_namespace
        case parser_type
        when :perl; Perl
        else handler_base_namespace_without_perl
        end
      end
    end
  end

  module Parser
    class SourceParser
      alias :parser_type_for_filename_without_perl :parser_type_for_filename
      def parser_type_for_filename(filename)
        case (File.extname(filename)[1..-1] || "").downcase
        when "pl", "pm"
          :perl
        else # when "rb", "rbx", "erb"
          parser_type_for_filename_without_perl(filename)
        end
      end

      alias :parse_statements_without_perl :parse_statements
      def parse_statements(content)
        return Perl.parse(content, file) if parser_type == :perl
        parse_statements_without_perl(content)
      end
    end
  end

  module Templates
    module Engine
      register_template_path File.join(File.dirname(__FILE__), '..', 'templates')
    end
  end
end