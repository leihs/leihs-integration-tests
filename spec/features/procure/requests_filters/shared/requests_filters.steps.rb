step 'I see following budget periods:' do |table|
  within 'main' do
    table.raw.flatten.each do |bp|
      expect(current_scope).to have_content bp
    end
  end
end

step 'I expand all categories' do
  within 'main' do
    2.times { all('.fa-caret-right').each(&:click) }
  end
end

step 'I see requests for the following articles:' do |table|
  within 'main' do
    table.rows.each do |article, state|
      find('li.ui-subcat-items', text: /#{article}.*#{state}/m)
    end
  end
end

step 'I check/uncheck all items for :prop filter' do |prop|
  within '.form-compact' do
    within find('.form-group', text: prop) do
      find('button', match: :first).click
      find('label.dropdown-item', text: 'Alle auswählen').click
      find('button', match: :first).click
    end
  end
end

step 'I check/uncheck :opt for :prop filter' do |opt, prop|
  within '.form-compact' do
    within find('.form-group', text: prop) do
      if prop == 'Status Antrag'
        find('.custom-checkbox label', text: /^#{opt}$/).click
      else
        find('button', match: :first).click
        find('label.dropdown-item', text: /^#{opt}$/).click
        find('button', match: :first).click
      end
    end
  end
end

step 'I search for :txt' do |txt|
  within '.form-compact' do
    find("input[name='search']").set txt
  end
end

step ':prop filter name is :name' do |prop, name|
  within '.form-compact' do
    within find('.form-group', text: /^#{prop}$/) do
      expect(find('button').text).to eq name
    end
  end
end

step 'there is a(n) :role for categories:' do |role, table|
  @user = FactoryBot.create(:user)
  table.raw.each do |cat|
    c = ProcurementCategory.find(name: cat)
    FactoryBot.create("procurement_#{role}",
                      user: @user,
                      category: c)
  end
end
