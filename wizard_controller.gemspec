Gem::Specification.new do |s|
  s.name = %q{wizard_controller}
  s.version = "0.1.8"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Patrick Morgan", "Midwire"]
  s.date = %q{2010-02-02}
  s.description = %q{Wizard Controller is an inheritable class to ease the creation of Wizards}
  s.email = %q{patrick.morgan@masterwebdesign.net midwire@midwire.com}
  s.files = ["README", "README.rdoc" , "History.txt" , "lib/wizard_controller.rb" ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/codeprimate/wizard_controller}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{wizard_controller}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Wizard controller provides a base class (Inheriting from ActionController::Base) that provides a DSL for quickly making Wizards.}
end
