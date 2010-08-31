require 'textpow'

# @private
def __p(*path) File.join(File.dirname(__FILE__), 'yard', *path) end

module YARD
  module Parser
    module Perl
      PerlSyntax = Textpow::SyntaxNode.load(__p('..', '..', 'Perl.syntax'))
      autoload :PerlParser, __p('parser', 'perl')
    end
    
    SourceParser.register_parser_type :perl, Perl::PerlParser, %w[ pm pl ]
  end

  module Handlers
    module Perl
      autoload :Base,             __p('handlers', 'perl', 'base')
      autoload :PackageHandler,   __p('handlers', 'perl', 'package_handler')
      autoload :SubHandler,       __p('handlers', 'perl', 'sub_handler')
    end
    Processor.register_handler_namespace :perl, Perl
  end

  module Tags
    Library.define_tag "Method Scope", :scope
  end

  module Serializers
    autoload :PODSerializer, __p('serializers', 'pod_serializer')
  end

  module Formatters
    autoload :PODFormatter, __p('formatters', 'pod_formatter')
  end

  module Templates
    module Helpers
      module HtmlHelper
        html_helper = __p('templates', 'helpers', 'html_helper')
        define_method :html_syntax_highlight_perl do |source|
          require html_helper
          html_syntax_highlight_perl(source)
        end
      end

      autoload :PODHelper, __p('templates', 'helpers', 'pod_helper')
    end

    Engine.register_template_path __p('..', '..', 'templates')
  end
end

undef __p
