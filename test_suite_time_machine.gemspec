require_relative "lib/test_suite_time_machine/version"

Gem::Specification.new do |spec|
  spec.name = "test_suite_time_machine"
  spec.version = TestSuiteTimeMachine::VERSION
  spec.authors = ["Elliot Crosby-McCullough"]
  spec.email = ["elliot.cm@gmail.com"]

  spec.summary = "A small utility to help manage the current date and time in your test suite."
  spec.description = "Built atop Timecop, this gem provides a more intuitive interface for managing the current date and time across the test suite."
  spec.homepage = "https://github.com/SmartCasual/test_suite_time_machine"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ spec/ .git .github Gemfile])
    end
  end
  spec.require_paths = ["lib"]
end
