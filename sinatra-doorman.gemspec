# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sinatra-doorman}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Mendonca"]
  s.date = %q{2010-02-10}
  s.email = %q{joaosinho@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["MIT-LICENSE", "Rakefile", "README.rdoc", "views/signup.haml", "views/reset.haml", "views/forgot.haml", "views/login.haml", "lib/rack", "lib/rack/contrib", "lib/rack/contrib/cookies.rb", "lib/doorman.rb", "lib/doorman", "lib/doorman/messages.rb", "lib/doorman/user.rb", "lib/doorman/base.rb"]
  s.homepage = %q{http://github.com/johnmendonca/sinatra-doorman}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A user authentication middleware built with Sinatra and Warden}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, ["~> 1.0.a"])
      s.add_runtime_dependency(%q<warden>, ["~> 0.9.0"])
      s.add_runtime_dependency(%q<pony>, [">= 0"])
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.10.2"])
      s.add_runtime_dependency(%q<dm-validations>, ["~> 0.10.2"])
      s.add_runtime_dependency(%q<dm-timestamps>, ["~> 0.10.2"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
      s.add_development_dependency(%q<webrat>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
    else
      s.add_dependency(%q<sinatra>, ["~> 1.0.a"])
      s.add_dependency(%q<warden>, ["~> 0.9.0"])
      s.add_dependency(%q<pony>, [">= 0"])
      s.add_dependency(%q<dm-core>, ["~> 0.10.2"])
      s.add_dependency(%q<dm-validations>, ["~> 0.10.2"])
      s.add_dependency(%q<dm-timestamps>, ["~> 0.10.2"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<webrat>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
    end
  else
    s.add_dependency(%q<sinatra>, ["~> 1.0.a"])
    s.add_dependency(%q<warden>, ["~> 0.9.0"])
    s.add_dependency(%q<pony>, [">= 0"])
    s.add_dependency(%q<dm-core>, ["~> 0.10.2"])
    s.add_dependency(%q<dm-validations>, ["~> 0.10.2"])
    s.add_dependency(%q<dm-timestamps>, ["~> 0.10.2"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<webrat>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
  end
end
