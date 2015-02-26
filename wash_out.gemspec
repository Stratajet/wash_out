# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "wash_out"
  s.version = "0.9.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Boris Staal", "Peter Zotov"]
  s.date = "2015-02-26"
  s.description = "Dead simple Rails 3 SOAP server library"
  s.email = "boris@roundlake.ru"
  s.files = [".gitignore", ".rspec", ".travis.yml", "Appraisals", "CHANGELOG.md", "Gemfile", "Guardfile", "LICENSE", "README.md", "Rakefile", "app/helpers/wash_out_helper.rb", "app/views/wash_out/document/error.builder", "app/views/wash_out/document/response.builder", "app/views/wash_out/document/wsdl.builder", "app/views/wash_out/rpc/error.builder", "app/views/wash_out/rpc/response.builder", "app/views/wash_out/rpc/wsdl.builder", "init.rb", "lib/wash_out.rb", "lib/wash_out/configurable.rb", "lib/wash_out/dispatcher.rb", "lib/wash_out/engine.rb", "lib/wash_out/middleware.rb", "lib/wash_out/model.rb", "lib/wash_out/param.rb", "lib/wash_out/router.rb", "lib/wash_out/soap.rb", "lib/wash_out/soap_config.rb", "lib/wash_out/type.rb", "lib/wash_out/version.rb", "lib/wash_out/wsse.rb", "spec/dummy/Rakefile", "spec/dummy/app/controllers/application_controller.rb", "spec/dummy/app/helpers/application_helper.rb", "spec/dummy/app/views/layouts/application.html.erb", "spec/dummy/config.ru", "spec/dummy/config/application.rb", "spec/dummy/config/boot.rb", "spec/dummy/config/environment.rb", "spec/dummy/config/environments/development.rb", "spec/dummy/config/environments/test.rb", "spec/dummy/config/initializers/backtrace_silencers.rb", "spec/dummy/config/initializers/inflections.rb", "spec/dummy/config/initializers/mime_types.rb", "spec/dummy/config/initializers/secret_token.rb", "spec/dummy/config/initializers/session_store.rb", "spec/dummy/config/locales/en.yml", "spec/dummy/config/routes.rb", "spec/dummy/public/404.html", "spec/dummy/public/422.html", "spec/dummy/public/500.html", "spec/dummy/public/favicon.ico", "spec/dummy/public/stylesheets/.gitkeep", "spec/dummy/script/rails", "spec/lib/wash_out/dispatcher_spec.rb", "spec/lib/wash_out/middleware_spec.rb", "spec/lib/wash_out/param_spec.rb", "spec/lib/wash_out/router_spec.rb", "spec/lib/wash_out/type_spec.rb", "spec/lib/wash_out_spec.rb", "spec/spec_helper.rb", "wash_out.gemspec"]
  s.homepage = "http://github.com/inossidabile/wash_out/"
  s.post_install_message = "    Please replace `include WashOut::SOAP` with `soap_service`\n    in your controllers if you are upgrading from a version before 0.8.5.\n"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Dead simple Rails 3 SOAP server library"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nori>, [">= 2.0.0"])
    else
      s.add_dependency(%q<nori>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<nori>, [">= 2.0.0"])
  end
end
