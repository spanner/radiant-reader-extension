# Reader

This is a framework that takes care of all the dull bits of registering, activating, reminding, logging in and editing preferences for your site visitors. 

It uses authlogic to handle sessions and provides complete interfaces both for the administrator and the visitor. The admin interface is basic and fits in with radiant. The visitor interface is more friendly (and incidentally includes a trick email field - so-called inverse captcha - that should prevent spam signups).

The visitors are referred to as 'readers' here. Readers never see the admin interface, but your site authors and admins are automatically given reader status.

The purpose of this extension is to provide a common core that supports other visitor-facing machinery. See for example our [forum extension](http://github.com/spanner/radiant-forum-extension) for discussions and page/blog comments, [reader groups](http://github.com/spanner/radiant-reader_group-extension) for proper page-access control and [downloads extension](http://github.com/spanner/radiant-downloads-extension) for secure access-controlled file downloads. More will follow and I hope other people will make use of this too.

## Latest

* Other extensions can extend the reader registration/preferences form with `ReaderController.add_form_partial('this/_partial')`

* Lots of little bugfixes thanks to radixhound

* By default we don't cache reader-facing pages.

* SQLite compatibility fixes thanks to [elivz](http://github.com/elivz)

* Brought into line with the latest version of our [multi_site](http://github.com/spanner/radiant-multi_site-extension): should now work seamlessly with or without sites. Also now makes use of the [submenu](https://github.com/spanner/radiant-submenu-extension/tree) and I've tweaked the routing so as to allow other extensions to work within the /admin/readers/ space.

## Status

Recently updated for radiant 0.8.1, which allowed us to remove the submodules and declare them as gem dependencies instead.

Tests are reasonably thorough. A lot of our code relies on this extension.

## Requirements

Radiant 0.8.1 (we need the new config machinery), [share_layouts](http://github.com/spanner/radiant-share-layouts-extension) (currently you need our version, which works with mailers too) and the [submenu](https://github.com/spanner/radiant-submenu-extension/tree) extension for the admin interface.

You also need four gems: authlogic, gravtastic, will_paginate and sanitize. They're declared in the extension so you should be able just to run

	sudo rake gems:install

Sanitize uses nokogiri, which needs libxml2 and libxslt: you may need to go off and install those first. It is very likely that you will also need to put

	gem 'authlogic'

in your environment.rb: it has to load before anything else calls `require ApplicationController`, and most radiant extensions will do that.

## Installation

	git submodule add git://github.com/spanner/radiant-reader-extension.git vendor/extensions/reader
	rake radiant:extensions:reader:migrate
	rake radiant:extensions:reader:update

The update task will install a /stylesheets/admin/reader.css that you can leave alone and a /stylesheets/reader.css that you should call from your reader layout (see below) and will want to improve upon. There is also a very thin /javascripts/reader.js: all it does is fade notifications. The forum extension has a lot more javascripts for you to deplore.

## Configuration

If you want to allow public registration, set `reader.allow_registration?` to true in your configuration. If it is false, then reader accounts can only be created by the administrator.

Under multi_site Reader adds a `reader_layout` column to the site table and a layout-chooser to the site-edit view. In a single-site installation you will also need these configuration entries:

* reader.layout (should be the name of a radiant layout)
* site.name
* site.url

The latter two are used in email notifications.

## Layouts

We use the share_layouts extension to wrap the layout of your public site around the pages produced by the reader extension. You can designate any layout as the 'reader layout': in a single-site installation put the name of the layout in a `reader.layout` config entry. In a multi-site installation you'll find a 'reader layout' dropdown on the 'edit site' page. Choose the one you want to use for each site.

The layout of the layout is up to you: from our point of view all it has to do is call `<r:content />` at some point. Ideally it will call `<r:content part="pagetitle" />` too. There is also a `breadcrumbs` part if that's required. In many cases you can just use your existing site layout and the various forms and pages will drop into its usual compartments.

## Using readers in other extensions

The reader admin pages are properly registered with the AdminUI as collections of parts, so you can override them in the same way as the other admin pages.

Most of your reader-facing controllers will want to inherit from `ReaderActionController`.

Marking a reader as untrusted does nothing here apart from making them go red, but we assume that in other extensions it will have some limiting effect.

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

