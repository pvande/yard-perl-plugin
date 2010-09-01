module YARD
  module Parser
    module Perl
      class Code
        attr_accessor :content, :line, :filename, :group

        def initialize(args)
          @content  = args[:content]
          @line     = args[:lnum]
          @filename = args[:filename]

          @comments = ''
          @name     = ''
        end

        def comments_range
          (@line - @comments.split.length)...@line
        end

        def inspect
          "<#{self.class} #{@name} #{@filename}:#{@line}>"
        end

        def show
          "sub #{@name} in #{@filename}:#{@line}"
        end
      end

      class Comment < Code
        def to_s
          str = @content.gsub(/^\s*#/, '')
          str.gsub!(/^ /, '') while str.any? { |line| line =~ /^ / } && str.all? { |line| line =~ /^ |^$/ }
          str
        end
      end

      class Package < Code
        attr_accessor :comments, :name, :superclass

        def namespace
          "::#{@name}".split("::")[0...-1].join("::")
        end

        def classname
          "::#{@name}".split("::")[-1]
        end
      end

      class Sub < Code
        attr_accessor :comments, :name, :body
        attr_writer   :visibility

        def visibility
          @visibility ||= @name.start_with?('_') ? :protected : :public
        end

        def parameters
          return @parameters if @parameters

          @parameters = [].tap do |params|
            @body.strip.take_while do |line|
              if line.strip    =~ /my\s+\((.*?)\)\s*=\s*@_\s*;/
                params.push *$1.split(/\s*(?:,|=>)\s*/)
              elsif line.strip =~ /my\s+(.*?)\s*=\s*shift(\(@_\))?\s*;/
                params << $1
              else
                false
              end
            end
          end
        end
      end

      class PerlParser < YARD::Parser::Base
        def initialize(source, filename)
          @source = source
          @filename = filename
        end

        def parse
          PerlSyntax.parse(@source, @processor = Processor.new(@filename))

          group   = nil
          watches = {
            # Watch for contiguous comment blocks
            'meta.comment.block' => proc { |s, e| s << Comment.new(e) },

            # Watch for 'package' declarations
            'meta.class' => proc do |s, e|
              pkg = Package.new(e)
              pkg.comments = s.pop.to_s if s.last.is_a? Comment
              index = s.length

              # Watch for the package name
              watches['entity.name.type.class'] = proc do |_, e|
                pkg.name = e[:content]
                watches.delete('entity.name.type.class')
              end

              # Watch the upcoming 'use' statements
              watches['meta.import.package'] = proc do |_, e|
                case e[:content]
                when /^bas(e|i[sc])|parent$/
                  # First argument will be the superclass name
                  watches['meta.import.arguments'] = proc do |_, e|
                    pkg.superclass = e[:content][/(\w|:)+/]
                    watches.delete('meta.import.arguments')
                  end
                when 'namespace::clean'
                  # Privatize every sub already declared in this package
                  s[index..-1].select { |e| e.is_a?(Sub) }.each do |sub|
                    sub.visibility = :private
                  end
                end
              end

              s << pkg
            end,

            # Watch for individual comment lines
            'meta.comment.full-line' => proc do |s, e|
              case e[:content]
                # Group detection
                when /#\s*@group\s+(.*)/ then group = $1
                when /#\s*@endgroup/     then group = nil
              end
            end,

            # Watch for named function declarations
            'meta.function.named' => proc do |s, e|
              sub = Sub.new(e)
              sub.comments = s.pop.to_s if s.last.is_a? Comment
              sub.group    = group      unless group.nil?

              # Watch for the function name
              watches['entity.name.function'] = proc do |_, e|
                sub.name = e[:content]
                watches.delete('entity.name.function')
              end

              # Watch for the function body
              watches['meta.scope.function'] = proc do |_, e|
                sub.body = e[:content]
                watches.delete('meta.scope.function')
              end

              s << sub
            end
          }

          @processor.map do |x|
            x[:filename] = @filename
            x[:content]  = x[:content][x[:range]]
          end

          @stack = @processor.inject([]) do |stack, elem|
            watches.each_pair do |key, val|
              val[stack, elem] if elem[:scope] == key
            end
            stack
          end
        end

        def enumerator
          @stack
        end
      end

      class Processor
        class Scope
          def initialize(name)
            @scope = name.split('.')
          end

          def ==(obj)
            obj.split('.').each_with_index do |element, index|
              element == @scope[index] or return false
            end
            return true
          end
        end

        def initialize(filename)
          @file = filename
          @line = ''
          @lnum = 0

          @cache = []
          @stash = []
        end

        def start_parsing(name); end
        def end_parsing(name);   end

        def new_line(line)
          @line = line
          @lnum += 1
          @stash.each { |x| x[:content] << @line }
        end

        def open_tag(name, pos)
          obj = {
            :scope_name => name,
            :scope => Scope.new(name),
            :lnum => @lnum,
            :range => (pos..-1),
            :content => @line.dup
          }
          @cache << (obj)
          @stash.unshift(obj)
        end

        def close_tag(name, pos)
          @stash.each do |x|
            x[:range] = x[:range].begin...(x[:content].length - @line.length + pos)
          end
          @stash.delete_at(@stash.index { |e| e[:scope_name] == name })
        end

        include Enumerable
        def each(*args, &blk)
          @cache.each(*args, &blk)
        end
      end
    end
  end
end