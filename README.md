# Reader

This is a framework that takes care of all the dull bits of registering, activating, reminding, logging in and editing preferences for your site visitors. 

It uses authlogic to handle sessions and provides complete interfaces both for the administrator and the visitor. The admin interface is very basic and fits in with radiant. The visitor interface is more friendly (and incidentally includes a trick email field - so-called inverse captcha - that should prevent spam signups).

The visitors are referred to as 'readers' here. Readers never see the admin interface, but your site authors and admins are automatically given reader status.

The purpose of this extension is to provide a common core that supports other visitor-facing machinery. See for example our [forum extension](http://github.com/spanner/radiant-forum-extension) for discussions and page/blog comments and [downloads extension](http://github.com/spanner/radiant-downloads-extension) for secure access-controlled file downloads. More will follow and I hope other people will make use of this framework.

## Latest

This version requires edge radiant, or radiant 1 when it becomes available. We are using a lot of the new configuration and sheets code.

New ReaderPages provide flexible directory services with configurable access control. The old controller and page parts mechanism is going to be phased out gradually both here and in the forum in favour of more orthodox radiant page-types. We will always need to use the layout-wrapper approach for login and registration forms, though.

Right now we are **not compatible with multi_site or the sites extension**: that's mostly because neither is radiant edge: it will all be sorted out in time for the release of v1, which isn't far away.

Also:

* public interface internationalized;
* Uses the new configuration interface;
* Messaging much simplified and now intended to be purely administrative.
* ajaxable status panel returned by `reader_session_url` (ie. you just have to call /reader_session.js over xmlhttp to get a sensible welcome and control block)

## Status

Compatible with radiant 1, which isn't out yet. You can use radiant edge to try this out. Expect small changes in support of the new forum and group releases. Multi-site compatibility will follow soon.

## Note on internationalisation and customisation

The locale strings here are generally defined in a functional rather than grammatical way. That is, they have labels like `activation_required_explanation` rather than being assembled out of lexical units. This is partly because for flexibility of translation, but also because it gives you an easy way to change the text on functional pages like reader-preferences and registration forms.

## Requirements

Radiant 0.9.2 (or currently, edge). The [layouts](http://github.com/squaretalent/radiant-layouts-extension) and [mailer_layouts](http://github.com/spanner/radiant-mailer_layouts-extension) extensions.

You also need three gems (in addition to those that radiant requires): authlogic, gravtastic and sanitize. They're declared in the extension so you should be able just to run

	sudo rake gems:install

Sanitize uses nokogiri, which needs libxml2 and libxslt: you may need to go off and install those first. You will also need to put

	gem 'authlogic'

in your environment.rb before you can migrate anything. Authlogic has to load before _anything_ else requires `ApplicationController`.

## Installation

As a gem:

	gem install 'radiant_reader_extension'
	
or for more control:

	git submodule add git://github.com/spanner/radiant-reader-extension.git vendor/extensions/reader

and then:

	rake radiant:extensions:reader:migrate
	rake radiant:extensions:reader:update

## Configuration

All the main configuration settings can now be managed through the 'readers' configuration pane.

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

