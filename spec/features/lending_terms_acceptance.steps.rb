step "the following settings are saved:" do |table|
  settings = Setting.first
  table.each do |key, val|
    expect(settings[key.to_sym].to_s).to eq val
  end
end