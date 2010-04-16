require 'rdoc/markup/formatter'

module YARD
  module Formatters
    class PODFormatter < RDoc::Markup::Formatter
      # Regular expression to match class references
      #
      # 1) There can be a '\' in front of text to suppress any cross-references
      # 2) There can be a 'main::' or just '::' in front of class names to
      #    reference from the top-level namespace.
      # 3) The method can be followed by parenthesis
      CLASS_REGEXP_STR = '\\\\?((?:(?:main)?\:{2})?[A-Z]\w*(?:\:\:\w+)*)'

      # Regular expression to match method references.
      #
      # See CLASS_REGEXP_STR
      METHOD_REGEXP_STR = '(\w+)(?:\([\w.+*/=<>-\\\\$@%]*\))?'

      # A::B::C->meth or A::B::C#meth or A::B::C.meth
      PACKAGE_METHOD_REGEXP_STR = CLASS_REGEXP_STR + '(?:->|\.|\#)' + METHOD_REGEXP_STR

      # Regular expressions matching text that should potentially have
      # cross-reference links generated are passed to add_special.  Note that
      # these expressions are meant to pick up text for which cross-references
      # have been suppressed, since the suppression characters are removed by the
      # code that is triggered.
      CROSSREF_REGEXP = /(
                            #{PACKAGE_METHOD_REGEXP_STR}

                            # Stand-alone method (proceeded by a #)
                            | \\?\##{METHOD_REGEXP_STR}

                            # A::B::C
                            # The stuff after CLASS_REGEXP_STR is a
                            # nasty hack.  CLASS_REGEXP_STR unfortunately matches
                            # words like dog and cat (these are legal "class"
                            # names in Fortran 95).  When a word is flagged as a
                            # potential cross-reference, limitations in the markup
                            # engine suppress other processing, such as typesetting.
                            # This is particularly noticeable for contractions.
                            # In order that words like "can't" not
                            # be flagged as potential cross-references, only
                            # flag potential class cross-references if the character
                            # after the cross-referece is a space or sentence
                            # punctuation.
                            | #{CLASS_REGEXP_STR}(?=[\s\)\.\?\!\,\;]|\z)

                            # Things that look like filenames
                            # The key thing is that there must be at least
                            # one special character (period, slash, or
                            # underscore).
                            | (?:\.\.\/)*[-\/\w]+[_\/\.][-\w\/\.]+[\w]

                            # Things that have markup suppressed
                            | \\[^\s]
                            )/x

      def initialize(path, context)
        super()

        @from_path = path
        @context = context
        @seen = {}

        @markup.add_special(/[A-Z]</, :POD_COMMAND)
        @markup.add_special(/((link:|https?:|mailto:|ftp:|www\.)\S+\w)/, :HYPERLINK)
        @markup.add_special(CROSSREF_REGEXP, :CROSSREF)
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

      # We're invoked when any text matches the CROSSREF pattern (defined in
      # MarkUp).  If we find the corresponding reference, generate a hyperlink.
      # If the name we're looking for contains no punctuation, we look for it up
      # the module/class chain.  For example, HyperlinkHtml is found, even without
      # the Generator:: prefix, because we look for it in module Generator first.
      def handle_special_CROSSREF(special)
        name = special.text
        # This ensures that words entirely consisting of lowercase letters will
        # not have cross-references generated (to suppress lots of erroneous
        # cross-references to "new" in text, for instance)
        return name if name =~ /\A[a-z]*\z/

        return @seen[name] if @seen.include? name

        if name[0, 1] == '#' then
          lookup = name = name[1..-1]
        else
          lookup = name
        end

        # Find class, module, or method in class or module.
        #
        # Do not, however, use an if/elsif/else chain to do so.  Instead, test
        # each possible pattern until one matches.  The reason for this is that a
        # string like "YAML.txt" could be the txt() class method of class YAML (in
        # which case it would match the first pattern, which splits the string
        # into container and method components and looks up both) or a filename
        # (in which case it would match the last pattern, which just checks
        # whether the string as a whole is a known symbol).
        if lookup =~ /#{PACKAGE_METHOD_REGEXP_STR}/ then
          container = P(@context, $1)
          ref = P(container, "##{$2}")
        end

        ref = P(@context, lookup) unless ref

        out = if lookup == '\\' then
                lookup
              elsif lookup =~ /^\\/ then
                $'
              elsif ref and ref.class != CodeObjects::Proxy then
                if ref.class == CodeObjects::MethodObject then
                  "L<#{name}|#{ref.namespace}/#{ref.name}>"
                else
                  "L<#{name}|#{ref.path}>"
                end
              else
                name
              end

        @seen[name] = out

        out
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