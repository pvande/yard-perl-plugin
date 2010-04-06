module YARD
  module Handlers
    module Perl
      class Base < Handlers::Base
        class << self
          include Parser::Perl

          def handles?(node)
            handlers.any? do |a_handler|
              node.class == a_handler
            end
          end
        end

        include Parser::Perl
      end
    end
  end
end