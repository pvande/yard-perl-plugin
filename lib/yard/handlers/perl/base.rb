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

        class NamespaceObject < NamespaceObject
          def inheritance_tree(include_mods = false)
            return [self]
          end
        end
      end
    end
  end
end