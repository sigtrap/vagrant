$:.unshift File.expand_path("../lib", __FILE__)
require "vagrant/version"

Gem::Specification.new do |s|
  s.name          = "vagrant"
  s.version       = Vagrant::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Mitchell Hashimoto", "John Bender"]
  s.email         = ["mitchell.hashimoto@gmail.com", "john.m.bender@gmail.com"]
  s.homepage      = "https://www.vagrantup.com"
  s.license       = 'BUSL-1.1'
  s.summary       = "Build and distribute virtualized development environments."
  s.description   = "Vagrant is a tool for building and distributing virtualized development environments."

  s.required_ruby_version     = ">= 3.0", "< 3.5"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "base64", "~> 0.2.0"
  s.add_dependency "bcrypt_pbkdf", "~> 1.1"
  s.add_dependency "childprocess", "~> 5.1"
  s.add_dependency "csv", "~> 3.3"
  s.add_dependency "ed25519", "~> 1.3.0"
  s.add_dependency "erubi"
  s.add_dependency "hashicorp-checkpoint", "~> 0.1.5"
  s.add_dependency "i18n", "~> 1.12"
  s.add_dependency "listen", "~> 3.7"
  s.add_dependency "log4r", "~> 1.1.9", "< 1.1.11"
  s.add_dependency "logger", "~> 1.0"
  s.add_dependency "mime-types", "~> 3.3"
  s.add_dependency "net-ftp", "~> 0.2"
  s.add_dependency "net-ssh", "~> 7.0"
  s.add_dependency "net-sftp", "~> 4.0"
  s.add_dependency "net-scp", "~> 4.0"
  s.add_dependency "ostruct", "~> 0.6.0"
  s.add_dependency "rb-kqueue", "~> 0.2.0"
  s.add_dependency "rexml", "~> 3.2"
  s.add_dependency "rubyzip", "~> 2.3.2"
  s.add_dependency "vagrant_cloud", "~> 3.1.2"
  s.add_dependency "wdm", "~> 0.2.0"
  s.add_dependency "winrm", ">= 2.3.9", "< 3.0"
  s.add_dependency "winrm-elevated", ">= 1.2.3", "< 2.0"
  s.add_dependency "winrm-fs", ">= 1.3.5", "< 2.0"

  # Needed for go generate to use grpc_tools_ruby_protoc
  s.add_development_dependency "grpc-tools", "~> 1.41"

  # required to include https://github.com/ruby/ipaddr/issues/35
  s.add_dependency "ipaddr", ">= 1.2.4"

  # Constraint rake to properly handle deprecated method usage
  # from within rspec
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rake-compiler"
  s.add_development_dependency "rspec", "~> 3.11"
  s.add_development_dependency "rspec-its", "~> 1.3.0"
  s.add_development_dependency "fake_ftp", "~> 0.3.0"
  s.add_development_dependency "webrick", "~> 1.7"

  # The following block of code determines the files that should be included
  # in the gem. It does this by reading all the files in the directory where
  # this gemspec is, and parsing out the ignored files from the gitignore.
  # Note that the entire gitignore(5) syntax is not supported, specifically
  # the "!" syntax, but it should mostly work correctly.
  root_path      = File.dirname(__FILE__)
  all_files      = Dir.chdir(root_path) { Dir.glob("**/{*,.*}") }
  all_files.reject! { |file| [".", ".."].include?(File.basename(file)) }
  all_files.reject! { |file| file.start_with?("website/") }
  all_files.reject! { |file| file.start_with?("test/") }
  all_files.reject! { |file| file.start_with?("cmd/") }
  all_files.reject! { |file| file.start_with?("builtin/") }
  all_files.reject! { |file| file.start_with?("internal/") }
  all_files.reject! { |file| file.start_with?("vendor/") }

  gitignore_path = File.join(root_path, ".gitignore")
  gitignore      = File.readlines(gitignore_path)
  gitignore.map!    { |line| line.chomp.strip }
  gitignore.reject! { |line| line.empty? || line =~ /^(#|!)/ }

  gitmodules_path = File.join(root_path, ".gitmodules")
  gitmodules      = File.readlines(gitmodules_path)
  gitmodules.map!    { |line| line.chomp.strip }
  gitmodules.reject! { |line| line.empty? || line =~ /^(#|!)/ }

  unignored_files = all_files.reject do |file|
    # Ignore any directories, the gemspec only cares about files
    next true if File.directory?(file)

    # Ignore any paths that match anything in the gitignore. We do
    # two tests here:
    #
    #   - First, test to see if the entire path matches the gitignore.
    #   - Second, match if the basename does, this makes it so that things
    #     like '.DS_Store' will match sub-directories too (same behavior
    #     as git).
    #
    gitignore.any? do |ignore|
      File.fnmatch(ignore, file, File::FNM_PATHNAME) ||
        File.fnmatch(ignore, File.basename(file), File::FNM_PATHNAME)
    end

    gitmodules.any? do |ignore|
      File.fnmatch(ignore, file, File::FNM_PATHNAME) ||
        File.fnmatch(ignore, File.basename(file), File::FNM_PATHNAME)
    end
  end

  s.files         = unignored_files
  s.executables   = unignored_files.map { |f| f[/^bin\/(.*)/, 1] }.compact
  s.extensions    = ["ext/vagrant/vagrant_ssl/extconf.rb"]
  s.require_path  = 'lib'
end
