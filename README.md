This is the source code for the Rails app that used to power [wincent.com](https://wincent.com). It is provided mostly as an historical artifact. This shows a multi-featured Rails app that lived from Rails version 1.2.4 all the way through to 4.2.2, over a span of 8 years.

The app started in 2007, and was actively developed for a few years to include a user registration system, blog functionality, a wiki, forums, issue tracking, Git repo history browsing, pervasive commenting, tags, full-text search, Atom feeds, link shortener, a Twitter clone, a "gists" feature, CMS functionality for product pages, and many other small features. All of this was custom coded in Ruby; even the full-text search was built by hand in Ruby on top of MySQL.

After a few years of part time development, things mostly went into maintenance mode and few new features were added (in fact, some were removed to ease the burden of updating to new versions of Rails). Towards the end of its life, its last upgrade was to Rails 4.2.2, and huge swathes of functionality were ripped out and replaced with static pages so that I could mirror them and migrate to [another solution](https://github.com/wincent/masochist).

# Finding your way around

All of this history is in the repo, warts and all. I'm sure if you dig through the tree or the history you won't have to look too far before you find something embarrassing.

`git log | grep -ci fuck` reports six lines containing the f-word, out of over 52,000 total lines in commit messages. This is surprisingly low given the number of Gem updates I had to battle through, and is only so low because I knew from the beginning that I wanted to eventually open the source, and was on mostly good behavior. Nevertheless, developing this app was never my full-time job, so there are a few cut corners here and there.

One of the reasons I never got around to open sourcing was that I wanted to do a sweep over the app and audit for credential leaks. There are some "sensitive" items in here that I didn't necessarily want to publicize, like internal path structures, user names and host names and such (for example, consider [the `script/deploy` script](https://github.com/wincent/wincent-on-rails/blob/master/script/deploy)), but the machines involved have been decommissioned now, so I feel ok about just dumping the entire source and all the history.

The repo is huge: over 4,300 commits and a bunch of stuff committed under `vendor` and `node_modules` because I wanted to have resilient deploys with no external dependencies beyond the repo itself.

[The code as of commit 6d84f8a](https://github.com/wincent/wincent-on-rails/tree/6d84f8a0de2017d8d0a1674f04c58fa9299ddf0c) (July 2015) is representative of what the app looked like in its last days before I got serious about gutting functionality and replacing dynamic features with static mirrors. If you look at the [current HEAD](https://github.com/wincent/wincent-on-rails/tree/master) you'll find a much reduced subset of the app.

Tags in the repo correspond to deployments to production.

There is an "assets" submodule in here that I won't be publishing. It contains bunch of images used by product pages and isn't really relevant to the code.

# Design notes

Here are some notes I made for myself early on to serve as a guide for the project.

## Overall goal

The overall goal for this application was to replace the disparate, disconnected stack of applications that I was previously using:

- Blog: Movable Type (Perl)
- Wiki: MediaWiki (PHP)
- Forums: UBB.threads (PHP)
- Bug tracking: Bugzilla (Perl)
- Mailing lists: Mailman (Python)
- License code retrieval: Custom Perl
- Payment processing: Custom Perl
- Contact form: Custom PHP
- Static content: Hand-coded PHP/HTML

with a single, unified application which handles all of those responsibilities. This not only provides a better user experience (no need to maintain separate accounts for the forums, bug tracker, mailing list etc), but also makes site-wide customization easier and replaces multiple dependency groups with a single dependency: Rails.

## Design principles

Re-inventing the Movable Type, MediaWiki, UBB.threads and Bugzilla would be a gargantuan task even using a "rapid application development" framework like Rails; so the goal is _not_ to provide the same functionality.

Rather, the goal is to provide _only_ what is needed and nothing more. At each stage I must do "the simplest thing that could possibly work".

As an example, let's take user authentication and access control. The system does have a user authentication system but it is deliberately kept as simple as possible.

There is no need for POSIX-style users and groups; there are really only two groups: one admin (me) and all of my customers (the rest). As such the system assumes that the superuser can do everything and everybody else has limited privileges. For example, a user can see or edit his own bug report while other users can see it but not edit; there is no system for granting additional privileges.

# Conclusion

I hope this proves interesting to somebody out there (I won't say I hope it proves useful because the value of technology decays so quickly). Enjoy!
