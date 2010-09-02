OH SO BETA WARNING
==================

This is wildly speculative software.  It works in a few cases.  It breaks in
all the rest.  USE AT YOUR OWN RISK.  Not valid with any other offer.  Void
where prohibited.

Pwa?
====

Here's what I've been doing:

    $ cd perl-project
    $ yardoc -e ../yard-perl-plugin/lib/yard-perl-plugin.rb lib/**/*.pm

YARD then transforms my ragtag bunch of (regularly formatted) Perl modules
into fine, high-quality documentation.

At present, this module will:

 * Work with YARD 0.6 -- and likely beyond!
 * Parse most Perl!
   * Support for this is provided by Textpow, via the TextMate Perl.plist
   (slightly modified)
 * Parse a package declaration
 * Parse a named sub declaration
 * Parse documentation comments
 * Handle subroutine visibility
   * Subroutines declared before a 'use namespace::clean' are marked private
   * Subroutines named with a leading '_' are marked protected
 * Handle subroutine parameters
   * Parameters are inferred from the first few assignments of the subroutine
   * Assignments that `shift` off @_ will populate a single parameter
   * Assigning from @_ in list context will further populate parameters
 * Handle method scope
   * If the first parameter name is 'self' or 'instance', instance scope is
   assumed
   * If the first parameter name is 'class' or 'package', class scope is
   assumed
   * If the first parameter name is 'receiver', 'invocant', or
   'class\_or_self', it is assumed the method may be called as either a class
   or instance method
   * If the first parameter name cannot be recognized, instance scope is assumed
   * **It is recognized that this is sub-optimal; suggestions welcomed**
 * Support the @group tag
   * This tag applies to all method declarations following, until the next
   @group tag or a corollary @endgroup tag
   * Methods in a group are given their own heading in the documentation
     * This can be used to emulate, for example, a documented export list
 * Provide syntax highlighting for HTML output
   * Support for this is provided by Textpow, via the TextMate Perl.plist
   (slightly modified)
 * Provide a POD output formatter
   * Don't expect miracles yet, though.

This module *won't*:

 * Do much else
