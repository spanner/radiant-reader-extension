# Reader

This is a framework that takes care of all the dull bits of registering, activating, reminding, logging in and editing preferences for your site visitors. 

It uses authlogic to handle sessions and provides complete interfaces both for the administrator and the visitor. The admin interface is basic and fits in with radiant. The visitor interface is more friendly (and incidentally includes a trick email field - so-called inverse captcha - that should prevent spam signups).

The visitors are referred to as 'readers' here. Readers never see the admin interface, but your site authors and admins are automatically given reader status.

The purpose of this extension is to provide a common core that supports other visitor-facing machinery. See for example our [forum extension](http://github.com/spanner/radiant-forum-extension) for discussions and page/blog comments, [reader groups](http://github.com/spanner/radiant-reader_group-extension) for proper page-access control and [downloads extension](http://github.com/spanner/radiant-downloads-extension) for secure access-controlled file downloads. More will follow and I hope other people will make use of this too.

## Latest

Just updated for radiant 0.8 and moved across to authlogic. I've also added more tests and improved the activation process so that inactive visitors can be reminded of the activation requirement even if they log in and out.

You will need to migrate to get the authlogic changes but after that it should handle password upgrades transparently.

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

Sorry: it's a bit of a faff to get the submodules in.

The update task will install a /stylesheets/admin/reader.css that you can leave alone and a /stylesheets/reader.css that you should call from your reader layout (see below) and then improve upon. There is also a very thin /javascripts/reader.js: all it does is fade notifications.

## Configuration

Under multisite Reader adds a few administrative columns to the site table: 

* reader_layout determines the layout used to present reader pages and defaults to 'Main' or the first layout it finds in that site.
* `mail_from_name` and `mail_from_address` determine from whom and where the administrative email sent to readers appear to come. They default to the name and email address of the owner of the site.

There are corresponding Radiant::Config entries for single-site installations:

	site.title
	site.url
	site.default_mail_from_name
	site.default_mail_from_address
	
These are mostly used in email, but they are required.

## Layouts

We use the share_layouts extension to wrap the layout of your public site around the pages produced by the reader extension. The details of the layout are up to you: as long as it calls `<r:content />` at some point, it'll work. Ideally it will call `<r:content part="title" />` too. There is also a breadcrumbs part if that's required. In many cases you can just use your existing site layout and the various forms and pages will drop into its usual compartments.

## Using readers in other extensions

...is the idea. The reader admin pages are properly registered with the AdminUI as collections of parts, so you can override them in the same way as the other admin pages.

Marking a reader as untrusted does nothing much here apart from making them go red, but we assume that in other extensions that will have some limiting effect.

## See also

* [reader_group](http://github.com/spanner/radiant-reader_group-extension)
* [forum](http://github.com/spanner/radiant-forum-extension)
* [downloads](http://github.com/spanner/radiant-downloads-extension)

## Bugs and comments

In [lighthouse](http://spanner.lighthouseapp.com/projects/26912-radiant-extensions), please, or for little things an email or github message is fine.

## Author and copyright

Copyright spanner ltd 2007-9.
Released under the same terms as Rails and/or Radiant.
Contact will at spanner.org

