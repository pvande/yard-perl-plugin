require 'rdoc/markup/formatter'

module YARD
  module Formatters
    class PODFormatter < RDoc::Markup::Formatter
      def initialize(path, context)
        super()

        @from_path = path
        @context = context
        @seen = {}

        @markup.add_special(/[A-Z]</, :POD_COMMAND)
        @markup.add_special(/((link:|https?:|mailto:|ftp:|www\.)\S+\w)/, :HYPERLINK)
        @markup.add_special(/(((\{.*?\})|\b\S+?)\[\S+?\.\S+?\])/, :TIDYLINK)

        init_tags
      end

      def start_accepting
        @res = ""
      end

      def init_tags
        add_tag :BOLD, 'B<<< ', ' >>>'
        add_tag :EM,   'I<<< ', ' >>>'
        add_tag :TT,   'C<<< ', ' >>>'
      end

      def handle_special_POD_COMMAND(tag)
        text = tag.text
        text[1..-1] = "Z<>"
        text
      end

      def handle_special_HYPERLINK(link)
        "L<#{link.text}>"
      end

      def handle_special_TIDYLINK(special)
        text = special.text

        return text unless text =~ /\{(.*?)\}\[(.*?)\]/ or text =~ /(\S+)\[(.*?)\]/

        label = $1
        url   = $2
        return "L<<< #{label} | #{url} >>>"
      end

      def accept_paragraph(p)
        @res << wrap(convert_flow(@am.flow(p.text)))
      end

      def accept_blank_line(line)
        @res << "\n"
      end

      def accept_heading(head)
        @res << '=head' << head.level.to_s << ' '
        @res << head.text << "\n"
      end

      def accept_verbatim(txt)
        @res << txt.text << "\n"
      end

      def end_accepting
        @res.gsub(/&([^;]+);/, 'E<\1>')
      end

      private

      def wrap(txt, line_len = 76)
        RDoc::Markup::ToHtml.new.wrap(txt, line_len)
      end
    end
  end
end