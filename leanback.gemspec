# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "leanback"
  s.version = "0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Obi Akubue"]
  s.date = "2013-11-16"
  s.description = "lightweight Ruby interface to CouchDB"
  s.email = "obioraakubue@yahoo.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Changelog.rdoc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "documentation/static/2011/11/20/i-moved-leanback-documentation/index.html",
    "documentation/static/2011/11/20/index.html",
    "documentation/static/2011/11/index.html",
    "documentation/static/2011/index.html",
    "documentation/static/2013/06/02/index.html",
    "documentation/static/2013/06/02/released-leanback-v0-3-4/index.html",
    "documentation/static/2013/06/09/index.html",
    "documentation/static/2013/06/09/released-leanback-v0-4-0/index.html",
    "documentation/static/2013/06/index.html",
    "documentation/static/2013/index.html",
    "documentation/static/author/admin/index.html",
    "documentation/static/basic-couchdb-operations/index.html",
    "documentation/static/category/uncategorized/index.html",
    "documentation/static/couchdb-configuration/index.html",
    "documentation/static/couchdb-security/index.html",
    "documentation/static/count-by-multiple-documents/index.html",
    "documentation/static/count-documents-by-key/index.html",
    "documentation/static/css/2c-l-fixed.css",
    "documentation/static/css/2c-l-fixed.dev.css",
    "documentation/static/css/2c-r-fixed.css",
    "documentation/static/css/2c-r-fixed.dev.css",
    "documentation/static/css/3c-c-fixed.css",
    "documentation/static/css/3c-c-fixed.dev.css",
    "documentation/static/css/3c-l-fixed.css",
    "documentation/static/css/3c-l-fixed.dev.css",
    "documentation/static/css/3c-r-fixed.css",
    "documentation/static/css/3c-r-fixed.dev.css",
    "documentation/static/css/holy-grail-fluid.css",
    "documentation/static/css/plugins.css",
    "documentation/static/css/print.css",
    "documentation/static/css/screen.css",
    "documentation/static/design-documents-and-permanent-views/index.html",
    "documentation/static/error-handling/index.html",
    "documentation/static/find-document-by-multiple-keys/index.html",
    "documentation/static/find-documents-by-key/index.html",
    "documentation/static/index.html",
    "documentation/static/leanback/index.html",
    "documentation/static/leanback/installation/index.html",
    "documentation/static/setting-the-bind_address-port/index.html",
    "documentation/static/style.css",
    "leanback.gemspec",
    "lib/leanback.rb",
    "spec/admin_party/database_spec.rb",
    "spec/no_admin_party/cloudant_spec.rb",
    "spec/no_admin_party/database_spec.rb",
    "spec/no_admin_party/non_admin_user_spec.rb",
    "spec/spec_base.rb",
    "test/helper.rb",
    "test/main.rb",
    "test/my_view.json",
    "test/my_views.json",
    "test/start.json",
    "test/test_leanback.rb",
    "test/view_age.json"
  ]
  s.homepage = "http://github.com/obi-a/leanback"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "lightweight Ruby interface to CouchDB"
  s.test_files = [
    "spec/admin_party/database_spec.rb",
    "spec/no_admin_party/cloudant_spec.rb",
    "spec/no_admin_party/database_spec.rb",
    "spec/no_admin_party/non_admin_user_spec.rb",
    "spec/spec_base.rb",
    "test/helper.rb",
    "test/main.rb",
    "test/test_leanback.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<yajl-ruby>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<yajl-ruby>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<yajl-ruby>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

