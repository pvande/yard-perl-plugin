class YARD::Handlers::Perl::PackageHandler < YARD::Handlers::Perl::Base
  handles Package

  process do
    $__PACKAGE__ = register ClassObject.new(P(statement.namespace), statement.classname)
  end
end
