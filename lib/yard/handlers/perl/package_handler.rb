class YARD::Handlers::Perl::PackageHandler < YARD::Handlers::Perl::Base
  handles Package

  process do
    ns = statement.namespace.split('::').reduce(:root) do |a,v|
      NamespaceObject.new(a, v)
    end
    $__PACKAGE__ = register ClassObject.new(ns, statement.classname)
  end
end
