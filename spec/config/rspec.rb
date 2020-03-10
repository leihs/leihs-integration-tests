RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4.
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  # This option will default to `:apply_to_host_groups` in RSpec 4
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.disable_monkey_patching!
  config.expose_dsl_globally = true

  config.warnings = false # sequel is just too noisy

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  config.before :each do
    srand 1
  end



  # Turnip:
  config.raise_error_for_unimplemented_steps = true # TODO: fix

  config.before(type: :feature) do

    feature_file_absolute = absolute_feature_file()
    require_feature_steps feature_file_absolute
    require_shared_files feature_file_absolute

    Capybara.current_driver = :firefox
    begin
      page.driver.browser.manage.window.resize_to(*BROWSER_WINDOW_SIZE)
    rescue => e
      fail e
      page.driver.browser.manage.window.maximize
    end
  end

  config.before(pending: true) do |example|
    example.pending
  end

  config.after(type: :feature) do |example|
    if ENV['CIDER_CI_TRIAL_ID'].present?
      unless example.exception.nil?
        take_screenshot('tmp/error-screenshots')
      end
    end
    page.driver.quit
    Capybara.current_driver = Capybara.default_driver
  end

  #
  config.after(:each) do |example|
    # auto-pry after failures, except in CI!
    unless (ENV['CIDER_CI_TRIAL_ID'].present? or ENV['NOPRY_ON_EXCEPTION'].present?)
      unless example.exception.nil?
        puts decorate_exception(example.exception)
        binding.pry if example.exception
      end
    end
  end
end


def absolute_feature_file
    spec_file_argument = ARGV.first.split(':').first

    feature_file_absolute =
      if Pathname.new(spec_file_argument).absolute?
        Pathname.new(spec_file_argument)
      else
        Pathname.pwd.join(spec_file_argument)
      end

    unless feature_file_absolute.absolute? and feature_file_absolute.exist?
      raise <<~ERR.strip
        feature_file_absolute #{feature_file_absolute} must exist and be absolute
        check arguments and #{__FILE__} code
      ERR
    end

    feature_file_absolute
end

def require_feature_steps feature_file_absolute
  feature_steps_file = feature_file_absolute.sub_ext(".steps.rb")
  require(feature_steps_file) if feature_steps_file.exist?
end


def require_shared_files(feature_file_absolute)
  features_dir = Pathname.pwd.join("spec", "features")
  relative_dirs_to_feature_file = feature_file_absolute.relative_path_from(features_dir)
  ([features_dir] + relative_dirs_to_feature_file.to_s.split(File::Separator)).reduce do |current_dir, sub|
    current_dir.join("shared").glob('**/*.rb').each do |ruby_file|
      require(ruby_file)
    end
    current_dir.join(sub)
  end
end


def decorate_exception(ex)
  div = Array.new(80, '-').join
  msg = case true
  when ex.is_a?(Turnip::Pending)
    "MISSING STEP! try this:\n\n"\
    "step \"#{ex.message}\" do\n  binding.pry\nend"
  else
    "GOT ERROR: #{ex.class}: #{ex.message}"
  end
  "\n\n#{div}\n\n#{msg}\n\n#{div}\n\n"
end
