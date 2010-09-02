class YARD::Handlers::Perl::SubHandler < YARD::Handlers::Perl::Base
  handles Sub

  process do
    method = register MethodObject.new($__PACKAGE__ || :root, statement.name) do |m|
      m.source = statement.content
      m.source_type = :perl
      m.visibility = statement.visibility
      m.parameters = statement.parameters
      m.docstring  = statement.comments

      m.scope = case statement.parameters.first
        when /self|instance/                   then :instance
        when /class|package/                   then :class
        when /receiver|invocant|class_or_self/ then :dual
        else                                        :instance  # Not really...
      end unless statement.parameters.empty?

      m.scope = m.tag(:scope).text.downcase.to_sym if m.has_tag?(:scope)
      m.scope = :dual                              if m.has_tag?(:alias)

      aliases = m.namespace.aliases
      aliases[m] = P(m.namespace, m.tag(:alias).name).name if m.has_tag?(:alias)

      if m.scope == :dual
        m.scope = :instance
        cm = register m.dup.tap { |cm| cm.scope = :class }
        aliases[cm] = aliases[m] if m.has_tag?(:alias)
      end
    end
  end
end
