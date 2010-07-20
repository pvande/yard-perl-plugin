class YARD::Handlers::Perl::PackageHandler < YARD::Handlers::Perl::Base
  handles Package

  process do
    x = statement.namespace
    register ModuleObject.new(x.namespace, x.name) until P(x).parent.nil? || (x = P(x).parent).root?
    $__PACKAGE__ = register ClassObject.new(P(statement.namespace), statement.classname)
  end
end
