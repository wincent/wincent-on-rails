# OVERALL GOAL

The overall goal for the application is to replace the disparate, disconnected stack of applications that I was previously using:

  Weblog:                 Movable Type (Perl)
  Wiki:                   MediaWiki (PHP)
  Forums:                 UBB.threads (PHP)
  Bug tracking:           Bugzilla (Perl)
  Mailing lists:          Mailman (Python)
  License code retrieval: Custom Perl
  Payment processing:     Custom Perl
  Contact form:           Custom PHP
  Static content:         Hand-coded PHP/HTML

with a single, unified application which handles all of those responsibilities. This not only provides a better user experience (no need to maintain separate accounts for the forums, bug tracker, mailing list etc), but also makes site-wide customization easier and replaces multiple dependency groups with a single dependency: Rails.

# DESIGN PRINCIPLES

Re-inventing the Movable Type, MediaWiki, UBB.threads and Bugzilla would be a gargantuan task even using a "rapid application development" framework like Rails; so the goal is _not_ to provide the same functionality.

Rather, the goal is to provide _only_ what is needed and nothing more. At each stage I must do "the simplest thing that could possibly work".

As an example, let's take user authentication and access control. The system does have a user authentication system but it is deliberately kept as simple as possible.

There is no need for POSIX-style users and groups; there are really only two groups: one admin (me) and all of my customers (the rest). As such the system assumes that the superuser can do everything and everybody else has limited privileges. For example, a user can see or edit his own bug report while other users can see it but not edit; there is no system for granting additional privileges.
