# Reader

This is a framework that handles all the dull bits of registering, activating, reminding, logging in and self-editing aspects of site membership. It uses authlogic to handle sessions and provides complete interfaces both for the administrator and the visitor. The admin interface is basic and fits in with radiant. The visitor interface is more friendly (and incidentally includes a trick email field - so-called inverse captcha - that should prevent spam signups).

The visitors are referred to as 'readers' here. Readers never see the admin interface, but your site authors and admins are automatically given reader status.

The purpose of this extension is to provide a common core that supports other visitor-facing machinery. See for example our [forum extension](http://github.com/spanner/radiant-forum-extension) for discussions and page/blog comments, [reader groups](http://github.com/spanner/radiant-reader_group-extension) for proper page-access control and [downloads extension](http://github.com/spanner/radiant-downloads-extension) for secure access-controlled file downloads. More will follow and I hope other people will make use of this too.

## Latest

Just updated for radiant 0.8 and moved across to authlogic. I've also added more tests and improved the activation process so that inactive visitors can be reminded of the activation requirement even if they log in and out.

## Status

Should be ready for use. Tests are very thorough (a lot of our code relies on this extension) but the latest updates were quite sweeping so issues are possible.

## Installation

	git submodule add git://github.com/spanner/radiant-reader-extension.git vendor/extensions/reader
	cd vendor/extensions/reader
		git submodule init
		git submodule update
	cd ../..
  	rake radiant:extensions:reader:migrate
  	rake radiant:extensions:reader:update

It's a bit lengthy but that's mostly because I've written it to work with Ray, but Ray is in a rather in-between state at the moment. In future this might be all you need:

	rake rake ray:extension:install name="reader"
    
The update task will install a /stylesheets/admin/reader.css that you can ignore and a /stylesheets/reader.css that you should call from your reader layout (see below) and then improve upon. There is also a very thing /javascripts/reader.js: all it does is fade notifications.

## Configuration

Under multisite Reader adds a few administrative columns to the site table: 

* reader_layout determines the layout used to present reader pages and defaults to 'Main' or the first layout it finds in that site.
* `email_from_name` and `email_from_address` determine from whom and where the administrative email sent to readers appear to come. They default to the name and email address of the owner of the site.

There are corresponding Radiant::Config entries for single-site installations.

## Layouts

We use the share_layouts extension to wrap the layout of your public site around the pages produced by the reader extension. The details of the layout are up to you: as long as it calls `<r:content />` at some point, it'll work. The reader pages also define title and breadcrumbs parts that may be useful.

The site edit form is extended to include a drop-down with which to choose the reader layout.

## Using readers in other extensions

...is the idea. The reader admin pages are properly registered with the AdminUI as collections of parts, so you can override them in the same way as the other admin pages.

Marking a reader as untrusted does nothing much here apart from making them go red, but we assume that in other extensions that will have some limiting effect.

## See also

* [reader_group](http://github.com/spanner/radiant-reader_group-extension)
* [forum](http://github.com/spanner/radiant-forum-extension)

## Bugs and comments

In [lighthouse](http://spanner.lighthouseapp.com/projects/26912-radiant-extensions), please, or for little things an email or github message is fine.

## Author and copyright

Copyright spanner ltd 2007-9.
Released under the same terms as Rails and/or Radiant.
Contact will at spanner.org

