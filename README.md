OH SO BETA WARNING
==================

This is wildly speculative software.  It works in a case or two.  It breaks in
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

 * Parse a package declaration
   * Provided it's the first thing on a line
 * Parse a named sub declaration
   * Provided it's the first thing on a line
   * Provided the closing brace of a multi-line sub is at the same indentation level as the declaration
 * Parse documentation comments
   * Provided the comment block is contiguous
   * Provided the comment block has no whitespace separation from the documented code
 * Handle subroutine visibility
   * Subroutines declared before a 'use namespace::clean' are marked private
   * Subroutines named with a leading '_' are marked protected
 * Provide a POD output formatter
   * Don't expect miracles yet, though.

This module *won't*:

 * Do much else