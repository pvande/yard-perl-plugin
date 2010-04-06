require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')
require 'yard/parser/perl'

Perl = YARD::Parser::Perl

def package(str, lineno = 1)
  Perl::Package.new('(string)', str, lineno)
end

def comment(str, lineno = 1)
  Perl::Comment.new('(string)', str, lineno)
end

def method(str, lineno = 1)
  Perl::Sub.new('(string)', str, lineno)
end

def line(str, lineno = 1)
  Perl::Line.new('(string)', str, lineno)
end

describe Perl, 'parsing' do
  after { Perl.parse(@code).enumerator.should == @result }
  describe 'package definitions' do
    it '(simple)' do
      @code = 'package Foo;'
      @result = [ package('package Foo;') ]
    end

    it '(namespaced)' do
      @code = 'package Bar::Baz::Foo;'
      @result = [ package('package Bar::Baz::Foo;') ]
    end

    it '(leading whitespace)' do
      @code = '  package Foo;'
      @result = [ package('  package Foo;') ]
    end
  end

  describe 'comments' do
    it '(simple)' do
      @code = '# this is a comment'
      @result = [ comment('# this is a comment') ]
    end

    it '(leading whitespace)' do
      @code = '  # this is a comment'
      @result = [ comment('  # this is a comment') ]
    end
  end

  describe 'blank lines' do
    it '(simple)' do
      @code = "\n"
      @result = [ line("\n") ]
    end

    it '(only whitespace)' do
      @code = '    '
      @result = [ line('    ') ]
    end
  end

  describe 'method definitions' do
    describe 'of one line' do
      it '(simple)' do
        @code = 'sub foo { "string" }'
        @result = [ method('sub foo { "string" }') ]
      end

      it '(with prototype)' do
        @code = 'sub foo($$@) { "string" }'
        @result = [ method('sub foo($$@) { "string" }') ]
      end

      it '(with attribute)' do
        @code = 'sub foo:lvalue { "string" }'
        @result = [ method('sub foo:lvalue { "string" }') ]
      end

      it '(with leading whitespace)' do
        @code = '    sub foo { "string" }'
        @result = [ method('    sub foo { "string" }') ]
      end
    end

    describe 'of more than one line' do
      it '(simple)' do
        @code = "sub foo\n{\n}"
        @result = [ method("sub foo\n{\n}") ]
      end

      it '(same line opening brace)' do
        @code = "sub foo {\n}"
        @result = [ method("sub foo {\n}") ]
      end
    end
  end
end
