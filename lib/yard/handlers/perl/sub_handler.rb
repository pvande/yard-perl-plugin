class YARD::Handlers::Perl::SubHandler < YARD::Handlers::Perl::Base
  handles Sub

  process do
    register MethodObject.new($__PACKAGE__ || :root, statement.name) do |m|
      m.source = statement.text
      m.visibility = statement.visibility
    end
  end
end
