# Reader

Readers are logged-in members or visitors to whom you or your extensions can grant privileges. They don't see the admin interface: this is a way to control access to pages and extended functionality on the public site, not in radiant proper. 

With this extension you get a simple but complete machinery of registration, login and user-management (by the admin and by the users themselves). It includes input validation, email address confirmation, password reset and some useful registers behind the scenes that record last login and visit. A trick email address field (so-called inverse captcha) should prevent spam signups, and a bit of glue code means that your existing user accounts become reader accounts when they need to.

This isn't much use by itself but it provides a common core for more interesting added functionality: see spanner's [forum extension](http://github.com/spanner/radiant-forum-extension) for discussions and page/blog comments, [reader groups](http://github.com/spanner/radiant-reader_group-extension) for proper page-access control and downloads extension for secure (nginx-based) access-controlled file downloads. More will follow.

## Status

Should be ready for use. Tests are very thorough (a lot of our code relies on this extension) and as I write there are no known issues.


## Installation

	git submodule add git://github.com/spanner/radiant-reader-extension.git vendor/extensions/reader
	cd vendor/extensions/reader
		git submodule init
		git submodule update
	cd ../..
  	rake radiant:extensions:reader:migrate
  	rake radiant:extensions:reader:update

It's a bit of a mess I agree. That's mostly because I've written it to work with Ray, but Ray is in a rather in-between state at the moment. In future this ought to be all you need:

	rake ray:extension:install name="multi-site" hub="spanner"
	rake rake ray:extension:install name="reader"
    
The update task will install a /stylesheets/admin/reader.css that you can ignore and a /stylesheets/reader.css that you should call from your reader layout (see below) and then improve upon.

## Configuration

Reader adds a few administrative columns to the site table: 

* reader_layout determines the layout used to present reader pages and defaults to 'Main' or the first layout it finds in that site.
* `email_from_name` and `email_from_address` determine from whom and where the administrative email sent to readers appear to come. They default to the name and email address of the owner of the site.

There are corresponding Radiant::Config entries for single-site installations.

## Layouts

We use the share_layouts extension to wrap the layout of your public site around the pages produced by the reader extension. The details of the layout are up to you: as long as it calls `<r:content />` at some point, it'll work. The reader pages also define title and breadcrumbs parts that may be useful. 

The site edit form is extended to include a drop-down with which to choose the reader layout.

## Using readers in other extensions

...is the whole point. The reader admin pages are properly registered with the AdminUI as collections of parts, so you can override them in the same way as the other admin pages.

Marking a reader as untrusted does nothing much here apart from making them go red, but we assume that in other extensions that will have some limiting effect.

I have half a dozen other extensions to publish over the next week or two. By the time I've finished doing that I should have a pretty good idea of what else to write here...

## See also

* [multi_site](http://github.com/spanner/radiant-multi-site-extension)
* [scoped-admin](http://github.com/spanner/radiant-scoped-admin-extension)
* [reader_group](http://github.com/spanner/radiant-reader_group-extension)
* [forum](http://github.com/spanner/radiant-forum-extension)

## Bugs and comments

In [lighthouse](http://spanner.lighthouseapp.com/projects/26912-radiant-extensions), please, or for little things an email or github message is fine.

## Author and copyright

Copyright spanner ltd 2007-9.
Released under the same terms as Rails and/or Radiant.
Contact will at spanner.org

