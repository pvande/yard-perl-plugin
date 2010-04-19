class YARD::Handlers::Perl::SubHandler < YARD::Handlers::Perl::Base
  handles Sub

  process do
    method = register MethodObject.new($__PACKAGE__ || :root, statement.name) do |m|
      m.source = statement.text
      m.visibility = statement.visibility
    end

    add_parameters(method.source, method)

    if method.has_tag?(:scope)
      case (scope = method.tag(:scope).text.downcase)
      when 'class', 'instance'
        method.scope = scope
      when 'dual'
        class_method = method.dup
        class_method.scope = :class
        register class_method
      else
        log.warn "Unrecognized @scope '#{scope}' for method #{statement.name}"
      end
    end
  end

  def add_parameters(code, method)
    params = []
    if code =~ /my\s+\((.*?)\)\s*=\s*@_\s*;/
      params = $1.split(/\s*(?:,|=>)\s*/)

      parse_method_scope(params.first, method)

      method.parameters = params.map { |p| [ p ] }
    end
  end

  private

  def parse_method_scope(parameter, method)
    return if method.has_tag?(:scope)

    scope = case (parameter)
    when '$self', '$instance'
      'instance'
    when '$class', '$package'
      'class'
    when '$receiver', '$invocant', '$class_or_self'
      'dual'
    else
      return
    end

    method.docstring.add_tag(YARD::Tags::Tag.new(:scope, scope))
  end
end
