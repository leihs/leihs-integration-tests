# test helpers
def wait_until(wait_time = 10, &block)
  Timeout.timeout(wait_time) do
    until value = yield
      sleep(0.2)
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
