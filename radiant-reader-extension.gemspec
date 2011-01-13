# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{radiant-reader-extension}
  s.version = "1.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["spanner"]
  s.date = %q{2011-01-13}
  s.description = %q{Centralises reader/member/user registration and management tasks for the benefit of other extensions}
  s.email = %q{will@spanner.org}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".gitignore",
     "README.md",
     "Rakefile",
     "VERSION",
     "app/controllers/admin/messages_controller.rb",
     "app/controllers/admin/reader_configuration_controller.rb",
     "app/controllers/admin/readers_controller.rb",
     "app/controllers/messages_controller.rb",
     "app/controllers/password_resets_controller.rb",
     "app/controllers/reader_action_controller.rb",
     "app/controllers/reader_activations_controller.rb",
     "app/controllers/reader_sessions_controller.rb",
     "app/controllers/readers_controller.rb",
     "app/helpers/reader_helper.rb",
     "app/models/message.rb",
     "app/models/message_function.rb",
     "app/models/message_reader.rb",
     "app/models/reader.rb",
     "app/models/reader_notifier.rb",
     "app/models/reader_session.rb",
     "app/views/admin/messages/_form.html.haml",
     "app/views/admin/messages/_help.html.haml",
     "app/views/admin/messages/_list_function.haml",
     "app/views/admin/messages/_message_description.html.haml",
     "app/views/admin/messages/edit.html.haml",
     "app/views/admin/messages/index.haml",
     "app/views/admin/messages/new.html.haml",
     "app/views/admin/messages/preview.html.haml",
     "app/views/admin/messages/show.html.haml",
     "app/views/admin/reader_configuration/edit.html.haml",
     "app/views/admin/reader_configuration/show.html.haml",
     "app/views/admin/readers/_avatar.html.haml",
     "app/views/admin/readers/_form.html.haml",
     "app/views/admin/readers/_password_fields.html.haml",
     "app/views/admin/readers/edit.html.haml",
     "app/views/admin/readers/index.html.haml",
     "app/views/admin/readers/new.html.haml",
     "app/views/admin/readers/remove.html.haml",
     "app/views/admin/sites/_choose_reader_layout.html.haml",
     "app/views/messages/preview.html.haml",
     "app/views/messages/show.html.haml",
     "app/views/password_resets/create.html.haml",
     "app/views/password_resets/edit.html.haml",
     "app/views/password_resets/new.html.haml",
     "app/views/reader_activations/_activation_required.haml",
     "app/views/reader_activations/show.html.haml",
     "app/views/reader_notifier/message.html.haml",
     "app/views/reader_sessions/_login_form.html.haml",
     "app/views/reader_sessions/new.html.haml",
     "app/views/readers/_contributions.html.haml",
     "app/views/readers/_controls.html.haml",
     "app/views/readers/_extra_controls.html.haml",
     "app/views/readers/_flasher.html.haml",
     "app/views/readers/_form.html.haml",
     "app/views/readers/edit.html.haml",
     "app/views/readers/index.html.haml",
     "app/views/readers/login.html.haml",
     "app/views/readers/new.html.haml",
     "app/views/readers/permission_denied.html.haml",
     "app/views/readers/show.html.haml",
     "config/initializers/radiant_config.rb",
     "config/locales/en.yml",
     "config/routes.rb",
     "db/migrate/001_create_readers.rb",
     "db/migrate/002_extend_sites.rb",
     "db/migrate/003_reader_honorifics.rb",
     "db/migrate/004_user_readers.rb",
     "db/migrate/005_last_login.rb",
     "db/migrate/007_adapt_for_authlogic.rb",
     "db/migrate/20090921125653_reader_messages.rb",
     "db/migrate/20090924164413_functional_messages.rb",
     "db/migrate/20090925081225_standard_messages.rb",
     "db/migrate/20091006102438_message_visibility.rb",
     "db/migrate/20091010083503_registration_config.rb",
     "db/migrate/20091019124021_message_functions.rb",
     "db/migrate/20091020133533_forenames.rb",
     "db/migrate/20091020135152_contacts.rb",
     "db/migrate/20091111090819_ensure_functional_messages_visible.rb",
     "db/migrate/20091119092936_messages_have_layout.rb",
     "db/migrate/20100922152338_lock_versions.rb",
     "db/migrate/20101004074945_unlock_version.rb",
     "db/migrate/20101019094714_message_sent_date.rb",
     "lib/controller_extensions.rb",
     "lib/reader_admin_ui.rb",
     "lib/reader_site.rb",
     "lib/reader_tags.rb",
     "lib/rfc822.rb",
     "lib/tasks/reader_extension_tasks.rake",
     "public/images/admin/chk_off.png",
     "public/images/admin/chk_on.png",
     "public/images/admin/delta.png",
     "public/stylesheets/sass/_reader_constants.sass",
     "public/stylesheets/sass/admin/reader.sass",
     "public/stylesheets/sass/reader.sass",
     "radiant-reader-extension.gemspec",
     "reader_extension.rb",
     "spec/controllers/admin/messages_controller_spec.rb",
     "spec/controllers/admin/readers_controller_spec.rb",
     "spec/controllers/password_resets_controller_spec.rb",
     "spec/controllers/reader_activations_controller_spec.rb",
     "spec/controllers/readers_controller_spec.rb",
     "spec/datasets/messages_dataset.rb",
     "spec/datasets/reader_layouts_dataset.rb",
     "spec/datasets/reader_sites_dataset.rb",
     "spec/datasets/readers_dataset.rb",
     "spec/lib/reader_admin_ui_spec.rb",
     "spec/lib/reader_site_spec.rb",
     "spec/matchers/reader_login_system_matcher.rb",
     "spec/models/message_spec.rb",
     "spec/models/reader_notifier_spec.rb",
     "spec/models/reader_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/spanner/radiant-reader-extension}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{User-services extension for Radiant CMS}
  s.test_files = [
    "spec/controllers/admin/messages_controller_spec.rb",
     "spec/controllers/admin/readers_controller_spec.rb",
     "spec/controllers/password_resets_controller_spec.rb",
     "spec/controllers/reader_activations_controller_spec.rb",
     "spec/controllers/readers_controller_spec.rb",
     "spec/datasets/messages_dataset.rb",
     "spec/datasets/reader_layouts_dataset.rb",
     "spec/datasets/reader_sites_dataset.rb",
     "spec/datasets/readers_dataset.rb",
     "spec/lib/reader_admin_ui_spec.rb",
     "spec/lib/reader_site_spec.rb",
     "spec/matchers/reader_login_system_matcher.rb",
     "spec/models/message_spec.rb",
     "spec/models/reader_notifier_spec.rb",
     "spec/models/reader_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<radiant>, [">= 0.9.0"])
      s.add_runtime_dependency(%q<radiant-layouts-extension>, [">= 0"])
      s.add_runtime_dependency(%q<radiant-mailer_layouts-extension>, [">= 0"])
      s.add_runtime_dependency(%q<authlogic>, [">= 0"])
      s.add_runtime_dependency(%q<sanitize>, [">= 0"])
    else
      s.add_dependency(%q<radiant>, [">= 0.9.0"])
      s.add_dependency(%q<radiant-layouts-extension>, [">= 0"])
      s.add_dependency(%q<radiant-mailer_layouts-extension>, [">= 0"])
      s.add_dependency(%q<authlogic>, [">= 0"])
      s.add_dependency(%q<sanitize>, [">= 0"])
    end
  else
    s.add_dependency(%q<radiant>, [">= 0.9.0"])
    s.add_dependency(%q<radiant-layouts-extension>, [">= 0"])
    s.add_dependency(%q<radiant-mailer_layouts-extension>, [">= 0"])
    s.add_dependency(%q<authlogic>, [">= 0"])
    s.add_dependency(%q<sanitize>, [">= 0"])
  end
end

