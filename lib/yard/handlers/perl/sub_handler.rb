class YARD::Handlers::Perl::SubHandler < YARD::Handlers::Perl::Base
  handles Sub

  process do
    method = register MethodObject.new($__PACKAGE__ || :root, statement.name) do |m|
      m.source = statement.content
      m.source_type = :perl
      m.visibility = statement.visibility
      m.parameters = statement.parameters

      m.scope = case statement.parameters.first
        when /self|instance/                   then :instance
        when /class|package/                   then :class
        when /receiver|invocant|class_or_self/ then :dual
        else                                        :instance  # Not really...
      end unless statement.parameters.empty?

      m.scope = m.tag(:scope).text.downcase.to_sym if m.has_tag?(:scope)

      if m.scope == :dual
        m.scope = :instance
        register m.dup.tap { |m| m.scope = :class }
      end
    end
  end
end
