class YARD::Handlers::Perl::PackageHandler < YARD::Handlers::Perl::Base
  handles Package

  process do
    x = P(statement.namespace)
    register ModuleObject.new(x.namespace, x.name) while x.is_a?(Proxy) || (P(x).parent.nil? && (x = P(x).parent).root?)
    $__PACKAGE__ = register ClassObject.new(P(statement.namespace), statement.classname)
  end
end
