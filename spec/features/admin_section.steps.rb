step 'I log in as the initial admin' do
  step "I log in with the email '#{@initial_admin.email}'"
end

step 'I log in as the leihs admin' do
  step "I log in with the email '#{@leihs_admin.email}'"
end

step 'I see the admin menu' do
  find('.admin nav .leihs-nav-right')
end

step 'I click on :label within the admin menu' do |label|
  within '.admin nav .leihs-nav-right' do
    find('a', text: /#{label}/i).click
  end
end

step 'I see the content of the :section page' do |section|
  find('h1', text: section)
end

step 'I see the content of the :section page in the old admin' do |section|
  within 'body' do
    if section == 'Audits'
      current_scope.has_selector? 'form'
    else
      current_scope.has_content? section
    end
  end
end

step 'there is an error message' do
  page.has_content?(/error/i)
end
