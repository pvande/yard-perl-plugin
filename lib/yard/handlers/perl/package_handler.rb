class YARD::Handlers::Perl::PackageHandler < YARD::Handlers::Perl::Base
  handles Package

  process do
    return $__PACKAGE__ = YARD::Registry.root if statement.classname == 'main'

    docstring = statement.comments
    x = P(statement.namespace)

    statement.comments = ''
    pieces = statement.namespace.split('::')
    pieces = pieces.inject([]) { |acc, e| acc << [acc.last, e].join('::') }
    pieces = pieces.map { |e| P(e) }.select { |e| e.is_a?(Proxy) }
    pieces.each { |e| register ModuleObject.new(e.namespace, e.name) }
    statement.comments = docstring

    $__PACKAGE__ = register ClassObject.new(P(statement.namespace), statement.classname) do |c|
      c.superclass  = P(statement.superclass) if statement.superclass
      c.source_type = :perl
      def c.relative_path(obj)
        if self.namespace.path == obj.path
          return obj.path
        else
          super(obj)
        end
      end
    end
  end
end
