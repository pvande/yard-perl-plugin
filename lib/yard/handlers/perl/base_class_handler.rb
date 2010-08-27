class YARD::Handlers::Perl::BaseClassHandler < YARD::Handlers::Perl::Base
  handles BaseClass

  process do
    $__PACKAGE__.superclass = statement.classname
  end
end
