step 'the :prop filter is checked' do |prop|
  within '.form-compact' do
    within find('.form-group .custom-checkbox', text: prop) do
      expect(find('input', match: :first)).to be_checked
    end
  end
end

step ':prop filter has following checkboxes:' do |prop, table|
  within '.form-compact' do
    within find('.form-group', text: prop) do
      table.raw.flatten.each do |el|
        find('label', text: el, match: :first)
      end
    end
  end
end

step 'I check/uncheck :prop filter' do |prop|
  within '.form-compact' do
    find('.form-group .custom-checkbox', text: prop).click
  end
end

step 'within all budget periods I see the following (main )categories:' do |table|
  within 'main' do
    all('.card.mb-3').each do |bp|
      table.raw.flatten.each do |el|
        expect(bp).to have_content el
      end
    end
  end
end
