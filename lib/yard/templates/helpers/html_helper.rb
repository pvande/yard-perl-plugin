require 'textpow'

module YARD
  module Templates
    module Helpers
      module HtmlHelper
        class PerlProcessor < String
          def style(pos, str)
            self.insert(@start + pos, str)
            @start += str.length
          end

          def start_parsing(name); end
          def end_parsing(name); end

          def new_line(line)
            @start = self.length
            self << (@line = line)
          end
          
          def open_tag(name, pos)
            self.style pos, case name
            when /^entity/
              '<span class="val">'
            when /^comment/
              '<span class="comment">'
            when /^constant.other/
              '<span class="symbol">'
            when /^constant/
              '<span class="const">'
            when /^variable/
              '<span class="ivar">'
            when /^string.regexp/
              '<span class="regexp">'
            when /^string/
              '<span class="tstring">'
            when /^storage/, /^keyword/, /^support/
              '<span class="kw">'
            end || ''
          end
          def close_tag(name, pos)
            self.style pos, case name
            when /^entity/, /^comment/, /^constant/, /^variable/, /^string/,
                 /^storage/, /^keyword/, /^support/
              '</span>'
            end || ''
          end
        end

        def html_syntax_highlight_perl(source)
          syntax = YARD::Parser::Perl::PerlSyntax
          # syntax.parse(source, Textpow::DebugProcessor.new)
          return syntax.parse(source, PerlProcessor.new)
        end
      end
    end
  end
end
