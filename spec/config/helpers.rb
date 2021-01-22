# test helpers
def wait_until(wait_time = 10, sleep_secs: 0.2, &block)
  Timeout.timeout(wait_time) do
    until value = yield
      sleep(sleep_secs)
    end
    value
  end
rescue Timeout::Error => e
  raise Timeout::Error.new(block.source)
end

# non-test helper methods
def backdoor(cmd)
  `vagrant ssh -- #{Shellwords.escape(cmd)}`
end
