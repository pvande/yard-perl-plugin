require File.dirname(__FILE__) + '/yard/parser/perl'
require File.dirname(__FILE__) + '/yard/handlers/perl/base'
require File.dirname(__FILE__) + '/yard/handlers/perl/package_handler'
require File.dirname(__FILE__) + '/yard/handlers/perl/sub_handler'
require File.dirname(__FILE__) + '/yard/serializers/pod_serializer'
require File.dirname(__FILE__) + '/yard/formatters/pod_formatter'
require File.dirname(__FILE__) + '/yard/templates/helpers/pod_helper'



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

    class Ruby::Legacy::TokenList
      def parse_content(content)
        lex = Ruby::Legacy::RubyLex.new(content)

        # if Perl...

        op = lex.instance_variable_get(:@OP)
        head = op.instance_variable_get(:@head)
        tree = head.instance_variable_get(:@Tree)

        op.def_rule('\%') do |op, io|
          t = lex.identify_identifier
          t.set_text("\\%#{t.text}")
        end

        tree['%'].postproc = proc do |op, io|
          if @lex_state == EXPR_BEG || @lex_state == EXPR_MID
            lex.identify_quotation('%')
          elsif lex.peek(0) == '='
            lex.getc
            Token(TkOPASGN, "%").set_text("%=")
          elsif @lex_state == EXPR_ARG and @space_seen and lex.peek(0) !~ /\s/
            lex.identify_quotation('%')
          else
            @lex_state = EXPR_BEG
            Token("%").set_text("%")
          end
        end

        # end

        while tk = lex.token do
          self << convert_token(lex, tk)
        end
      end
    end
  end

  module Templates
    module Engine
      register_template_path File.join(File.dirname(__FILE__), '..', 'templates')
    end
  end

  module Tags
    Library.define_tag "Method Scope", :scope
  end
end