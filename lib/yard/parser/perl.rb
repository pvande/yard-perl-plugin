module YARD
  module Parser
    module Perl

      class Line
        attr_reader :file, :text, :line, :group

        def initialize(file, text, line, group)
          @file  = file
          @text  = text
          @line  = line
          @group = group
        end

        def ==(other)
          self.class == other.class &&
          @file == other.file &&
          @text == other.text &&
          @line == other.line
        end

        def show
          "\t#{@text}: #{@text.split[0]}"
        end
      end

      class Comment < Line
        def read
          @text.gsub(/^\s*#[ \t]?/, '')
        end
      end

      class Package < Line
        attr_accessor :comments

        def initialize(*args)
          super *args
          @comments = ''
        end

        def comments_range
          (@line - @comments.split.length)...@line
        end

        def namespace
          @text[/package (.*)::[^:]*;/, 1] || :root
        end

        def classname
          @text[/package .*?([^:]*);/, 1]
        end
      end

      class BaseClass < Line
        def classname
          @text[/'(.*)'\s*;/,           1] ||
          @text[/"(.*)"\s*;/,           1] ||
          @text[/q[qw]?\[(.*)\]\s*;/,   1] ||
          @text[/q[qw]?\((.*)\)\s*;/,   1] ||
          @text[/q[qw]?\{(.*)\}\s*;/,   1] ||
          @text[/q[qw]?<(.*)>\s*;/,     1] ||
          @text[/q[qw]?(.)(.*)\1'\s*;/, 2]
        end
      end

      class Sub < Line
        attr_accessor :comments
        attr_accessor :visibility

        def initialize(*args)
          super *args
          @comments = ''
        end

        def visibility
          @visibility ||= name.start_with?('_') ? :protected : :public
        end

        def comments_range
          (@line - @comments.split.length)...@line
        end

        def name
          @text[/sub ([\w_]+)/, 1]
        end
      end

      class PerlParser < YARD::Parser::Base
        def initialize(source, filename)
          @source = source
          @filename = filename
        end

        def parse
          group = nil
          line  = 0
          @stack = @source.lines.collect do |src|
            case src
            when /^\s*use namespace::clean;/
              :private
            when /^# @group\s+(.+)\s*$/
              group = $1
            when /^# @endgroup\s*$/
              group = nil
            when /^\s*#/
              Comment.new(@filename, src, line += 1, group)
            when /^\s*package/
              Package.new(@filename, src, line += 1, group)
            when /^\s*sub/
              Sub.new(@filename, src, line += 1, group)
            when /^\s*(?:use\s+(?:bas(e|i[sc])|parent)|(?:our\s+)?@ISA\s*=|extends)/
              BaseClass.new(@filename, src, line += 1, group)
            else
              Line.new(@filename, src, line += 1, group)
            end
          end

          reduce_stack

          self
        end

        def enumerator
          @stack
        end

        private

        def prepare_method(element)
          if @method
            @method = false if element.text =~ /^#{@method}\}\s*$/
          else
            @method = $1 || '' unless element.text =~ /^(\s*)sub.*\}\s*$/
          end
        end

        def reduce_stack
          @method = false

          @stack = @stack.reduce([]) do |stack, element|
            if stack.empty?
              prepare_method(element) if element.is_a? Sub
            elsif @method
              prepare_method(element)
              stack.last.text << element.text
              next stack
            else
              last = stack.last

              case element
              when :private
                stack.select { |e| e.is_a? Sub }.each { |e| e.visibility = :private }
              when Package
                element.comments = last.read if last.is_a? Comment
              when Sub
                element.comments = last.read if last.is_a? Comment
                prepare_method(element)
              when Comment
                if last.is_a? Comment
                  last.text << element.text
                else
                  stack << element
                end
                next stack
              end
            end

            stack << element
          end

          warn 'Whoops! Misparsed something...' if @method
        end
      end
    end
  end
end