# Reader

This is a framework that takes care of all the dull bits of registering, activating, reminding, logging in and editing preferences for your site visitors. 

It uses authlogic to handle sessions and provides complete interfaces both for the administrator and the visitor. The admin interface is simple and fits in with radiant. The visitor interface is more friendly (and incidentally includes a trick email field - so-called inverse captcha - that should prevent spam signups).

The visitors are referred to as 'readers' here. Readers never see the admin interface, but your site authors and admins are automatically given reader status.

## Status

Compatible with radiant 1, which is nearly out. You can use radiant edge to try this out. Expect a few point releases as radiant 1 is finalised.

Multi-site compatibility is currently missing but will follow as soon as I can add a better scoping engine to radiant core.

## Note on internationalisation and customisation

The locale strings here are generally defined in a functional rather than grammatical way. That is, they have labels like `activation_required_explanation` rather than being assembled out of lexical units. This is partly for flexibility of translation, but also because it gives you an easy way to change the text on functional pages like reader-preferences and registration forms.

## Requirements

Versions 3.x of reader are designed to work with radiant 1 and will not work with older versions. There's a '0.9.1' tag in the repository for the last release that will.

Since you now have to install reader as a gem, all of its gem-based dependencies will be taken care of for you, but you may need some system libraries. We use Sanitize to whitelist html input. Sanitize uses Nogogiri to parse html, and Nokogiri needs `libxml2` and `libxslt` to do that. If you've installed imagemagick to work with radiant assets, it's very likely that you have those libraries already. If not, you will need to install them before you can install the reader gem.

## Installation

Install the gem:

	sudo gem install radiant-reader-extension

add it to your application's Gemfile:

	gem 'authlogic', "~> 2.1.6"
	gem radiant-reader-extension, '~>3.1.0'

and then you can bring over assets and create data tables:

	rake radiant:extensions:reader:update
	rake radiant:extensions:reader:migrate

## Configuration

All the main configuration settings can now be managed through the `settings > readers` configuration pane. They have sensible defaults but you will need to choose a layout for reader-administration views and supply the name and email address that messages should appear to come from.

## Readers

This is primarily a framework and its main purpose is to take care of the dull minutiae of account-management. The basic reader framework provides for:

* registration with honeypot spam trap
* activation by email confirmation
* logging in and out
* password reminders
* edit account preferences
* edit profile
* dashboard view on login
* configurable members directory with csv and vcard export
* administrative email messages for welcome, invitation, etc
* ad-hoc email messages to some or all readers
* group-membership
* group-based access control
* group-based messaging
* configurable directory service

## Reader groups

The extension also includes a group-based access control mechanism. You can organise your readers into groups (either by invitation or by public subscription) and any resource (eg a page) associated with one or more groups is visible only to their members. Anyone else attempting to access the page will be prompted to log in (or register, if registration is permitted).

You can use the group mechanism in a simple way just to create self-selected interest groups, or you can disable public registration and use the full group-hierarchical functionality to provide a very secure system of controlled access to selected resources. 

The group-scoping mechanism is easily extended to other classes:

	class Widget < ActiveRecord::Base
	  has_groups
	  ...
	end

So the forum extension, for example, includes the ability to make a forum visible only to members of selected groups.

For more reader-facing usefulness please see our [forum extension](http://github.com/spanner/radiant-forum-extension) for discussions and page/blog comments and [downloads extension](http://github.com/spanner/radiant-downloads-extension) for secure access-controlled file downloads. We also have extensions for public submission of calendar events and assets, which will emerge here soon.

## Layouts

We use the `layouts` extension to wrap the appearance of your public site around the views produced by the reader extension. You can select a layout with the dropdown list on the reader configuration page.

The laying-out is achieved by defining lots of fake page parts in the reader views. All your layout has to do is include those page parts with the usual `<r:content />` calls.

* `<r:content />` on its own will hold the main page content: login form, activation form, dashboard or whatever.
* `<r:title />` is always the page title
* `<r:content part="introduction" />` will provide a separate opening paragraph for layouts that require it
* `<r:content part="sidebar" />` will (sometimes) provide relevant marginal content
* `<r:content part="breadhead" />` is a more minimal breadcrumb trail that omits the present page and is suitable for use above the page title
* `<r:content part="controls" />` will show a standard 'hello [name]' block with login and logout and so on, but only on an uncached page. If the page is cached it will render an empty div with class 'remote_controls' that you can populate with javascipt. An ajax call to `/reader_session/show` will return the same controls block.
* `<r:content part="signals" />` will render any confirmation or error flashes. Not suitable for cached pages.
* `<r:content part="person" />` will render a gravatar and link for the current reader

You don't really need anything but the main title and content tags:

	<h1><r:title /></h1>
	<r:content />

will do just fine to start with.

## CSS and Javascript

Some standard formatting and interaction is included for you to build upon.

`/javascripts/reader.js` includes some rather basic jquery code to handle retrieving remote content (such as the control block mentioned above), fading out flashes and errors and adding a bit of responsiveness to the reader-facing forms.

`/stylesheets/sass/reader.sass` includes the default formatting of reader-facing forms and lists. It could probably stand to be reorganised a bit but you should find it a useful starting point and I recommend that you override it selectively rather than replacing it completely. There are two ways to do that:

* @import 'reader.sass' at the top of your (SASS-based) stylesheet within radiant
* link to /stylesheets/reader.css in the old-fashioned way and then bring in your own stylesheets afterwards.

Or you can replace the whole lot with your own recipe, of course.

## ReaderPages

You can also provide a more customised directory service by creating a ReaderPage and populating it with the many `r:readers` and `r:reader` tags that are defined here.

## Directory Visibility

There are four levels of directory visibility, and the behaviour of your site is set by the `reader.directory_visibility` configuration entry:

* *none* is the default. No reader details are shown to anybody.
* *public* means that anyone can see the directory. Individual readers can still opt out, but this is intended for public directory services with the expectation that people want to be shown.
* *private* means that only logged in readers can see the directory. Useful for closed groups and works well as an internal directory for an organisation or team.
* *grouped* means that only logged in people can see the directory and that they can only see those people with whom they share a group. Useful for more complex authorization requirements but also for sites that have a privileged core group and unprivileged guests.

## Using readers in other extensions

All the reader pages (both public and administrative) are sharded in the AdminUI. The public-facing administration and directory pages are all in `admin.accounts`, since the admin-facing views are already in `admin.readers`.

Most of your reader-facing controllers will want to inherit from `ReaderActionController`.

Marking a reader as untrusted does nothing here apart from making them go red, but in the forum it prevents participation and we assume that in other extensions it will have a similar limiting effect.

## Bugs and comments

[Github issues](http://github.com/spanner/radiant-reader-extension/issues), please, or for little things an email or github message is fine.

## Author and copyright

* Copyright spanner ltd 2007-11.
* Released under the same terms as Rails and/or Radiant.
* Contact will at spanner.org
