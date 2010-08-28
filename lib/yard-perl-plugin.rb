require File.dirname(__FILE__) + '/yard/parser/perl'
require File.dirname(__FILE__) + '/yard/handlers/perl/base'
require File.dirname(__FILE__) + '/yard/handlers/perl/package_handler'
require File.dirname(__FILE__) + '/yard/handlers/perl/base_class_handler'
require File.dirname(__FILE__) + '/yard/handlers/perl/sub_handler'
require File.dirname(__FILE__) + '/yard/serializers/pod_serializer'
require File.dirname(__FILE__) + '/yard/formatters/pod_formatter'
require File.dirname(__FILE__) + '/yard/templates/helpers/html_helper'
require File.dirname(__FILE__) + '/yard/templates/helpers/pod_helper'

module YARD
  module Handlers
    Processor.register_handler_namespace :perl, Perl
  end

  module Parser
    SourceParser.register_parser_type :perl, Perl::PerlParser, %w[ pm pl ]

    module Perl
      PerlSyntax = Textpow::SyntaxNode.load(File.join(File.dirname(__FILE__), '..', 'Perl.plist'))
    end
  end

  module Templates
    Engine.register_template_path File.join(File.dirname(__FILE__), '..', 'templates')
  end

  module Tags
    Library.define_tag "Method Scope", :scope
  end
end
