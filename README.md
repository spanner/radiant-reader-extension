# Reader

This is a framework that takes care of all the dull bits of registering, activating, reminding, logging in and editing preferences for your site visitors. 

It uses authlogic to handle sessions and provides complete interfaces both for the administrator and the visitor. The admin interface is simple and fits in with radiant. The visitor interface is more friendly (and incidentally includes a trick email field - so-called inverse captcha - that should prevent spam signups).

The visitors are referred to as 'readers' here. Readers never see the admin interface, but your site authors and admins are automatically given reader status.

## Status

Compatible with radiant 1, which isn't out yet. You can use radiant edge to try this out. Expect small changes in support of the new forum and group releases. Multi-site compatibility will follow soon.

## Note on internationalisation and customisation

The locale strings here are generally defined in a functional rather than grammatical way. That is, they have labels like `activation_required_explanation` rather than being assembled out of lexical units. This is partly because for flexibility of translation, but also because it gives you an easy way to change the text on functional pages like reader-preferences and registration forms.

## Requirements

* Radiant 1.0.0 (or currently, edge)
* [layouts](http://github.com/squaretalent/radiant-layouts-extension) extension
* [mailer_layouts](http://github.com/spanner/radiant-mailer_layouts-extension) extension

You also need some gems (in addition to those that radiant requires): 

* authlogic
* sanitize
* snail
* vcard
* fastercsv

If you're installing the radiant-reader-extension gem they will have been installed too. If you're installing it into vendor/extensins you will need to run:

	sudo rake gems:install

Sanitize uses nokogiri, which needs libxml2 and libxslt: you will need to make sure those are installed before you can install this gem.

## Installation

As a gem:

	gem install 'radiant_reader_extension'
	
or for more control:

	git submodule add git://github.com/spanner/radiant-reader-extension.git vendor/extensions/reader
	
Before you can migrate the extension you need to add this line to environment.rb above all the other config.gem declarations:

	config.gem 'authlogic', :version => "~> 2.1.6"
  
Authlogic has to load before _anything_ else requires `ApplicationController`. With that you can:

	rake radiant:extensions:update_all
	rake radiant:extensions:reader:migrate
	rake radiant:extensions:reader:update

## Configuration

All the main configuration settings can now be managed through the `settings > readers` configuration pane. THey have sensible defaults but you will need to choose a layout for reader-administration views and supply the name and email address that messages should appear to come from.

## Usage

This is primarily a framework and its main purpose is to take care of the tedious minutiae of account-management. The basic reader framework provides for:

* registration
* honeypot spam trap
* activation by email confirmation
* logging in and out
* password reminders
* edit account preferences
* edit profile
* dashboard view on login
* configurable members directory with csv and vcard export
* administrative email messages for welcome, invitation, etc
* ad-hoc email messages to some or all readers

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

We use the `layouts` extension to wrap the appearance of your public site around the views produced by the reader extension. You can configure this with the dropdown list on the reader configuration page.

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
* link to /stylesheets/reader.css in the old-fashioned way and then bring in your own stylesheets any way you like.

Or you can replace all this with your own, of course.

## ReaderPages

You can also provide a more customised directory service by creating a ReaderPage and populating it with the many `r:readers` and `r:reader` tags that are defined here.

## Directory Visibility

There are four levels of directory visibility, and the behaviour of your site is set by the `reader.directory_visibility` configuration entry:

* *none* is the default. No reader details are shown to anybody.
* *public* means that anyone can see the directory. Individual readers can still opt out, but this is intended for public directory services with the expectation that people want to be shown.
* *private* means that only logged in readers can see the directory. Useful for closed groups and works well as an internal directory for an organisation or team.
* *grouped* means that only logged in people can see the directory and that they can only see the people with whom they share a group. Useful for more complex authorization requirements but also for sites that have a privileged core group and unprivileged guests.

## Using readers in other extensions

All the reader pages (both public and administrative) are sharded in the AdminUI. The public-facing administration and directory pages are all in `admin.accounts`, since the admin-facing views are already in `admin.readers`.

Most of your reader-facing controllers will want to inherit from `ReaderActionController`.

Marking a reader as untrusted does nothing here apart from making them go red, but we assume that in other extensions it will have some limiting effect.

## Latest changes

This version requires edge radiant, or radiant 1 when it becomes available.

New ReaderPages provide flexible directory services with configurable access control. The old controller and page parts mechanism is likely to be phased out gradually both here and in the forum in favour of more orthodox radiant page-types. We will always need to use the layout-wrapper approach for login and registration forms, though.

Right now we are **not compatible with multi_site or the sites extension**: that's mostly because neither is radiant edge: it will all be sorted out in time for the release of v1, which isn't far away.

Also:

* groups hierarchical
* public interface internationalized;
* Uses the new configuration interface;
* Messaging much simplified and now intended to be purely administrative.
* ajaxable status panel returned by `reader_session_url` (ie. you just have to call /reader_session.js over xmlhttp to get a sensible welcome and control block)

## See also

* [reader_group](http://github.com/spanner/radiant-reader_group-extension)
* [downloads](http://github.com/spanner/radiant-downloads-extension)
* [forum](http://github.com/spanner/radiant-forum-extension)
* [group_forum](http://github.com/spanner/radiant-group_forum-extension)

## Bugs and comments

[Github issues](http://github.com/spanner/radiant-reader-extension/issues), please, or for little things an email or github message is fine.

## Author and copyright

* Copyright spanner ltd 2007-9.
* Released under the same terms as Rails and/or Radiant.
* Contact will at spanner.org
