class YARD::Handlers::Perl::SubHandler < YARD::Handlers::Perl::Base
  handles Sub

  process do
    method = register MethodObject.new($__PACKAGE__ || :root, statement.name) do |m|
      m.source = statement.text
      m.visibility = statement.visibility
    end

    if method.has_tag?(:scope)
      case (scope = method.tag(:scope).text.downcase)
      when 'class', 'instance'
        method.scope = scope
      when 'self'
        method.scope = :instance
      when 'dual', 'receiver', 'invocant', 'class_or_self'
        class_method = method.dup
        class_method.scope = :class
        register class_method
      else
        log.warn "Unrecognized @scope '#{scope}' for method #{statement.name}"
      end
    end
  end
end
