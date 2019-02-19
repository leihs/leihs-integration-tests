step 'the saved language in my user profile is :lang' do |lang|
  l = Language.find(name: lang)
  expect(@user.reload.language_id).to eq l.id
end

step 'the used language is the default language' do
  within '.ui-lang-selection' do
    current_scope.click
    current_scope.find('.ui-selected-lang',
                       text: Language.find(default: true).name)
    current_scope.click
  end
end

step 'the used language is :lang' do |lang|
  within '.ui-lang-selection' do
    current_scope.click
    current_scope.find('.ui-selected-lang', text: lang)
    current_scope.click
  end
end

step 'the default language is :lang' do |lang|
  Language.find(name: lang).update(default: true)
end

step 'I switch the language to :lang' do |lang|
  within '.ui-lang-selection' do
    current_scope.click
    current_scope.find('.dropdown-item', text: lang).click
  end
end

step "I change the language to :lang in :subapp" do |lang, subapp|
  case subapp
  when '/admin/', '/procure', '/my'
    within '.navbar-leihs' do
      find('.fa-globe').click
      find('button', text: lang).click
    end
  when '/manage', '/borrow'
    find("a", text: lang).click
  else
    raise
  end
end

step "the language was changed to :lang in :subapp" do |lang, subapp|
  case subapp
  when '/admin/', '/procure', '/my'
    find('.fa-globe').click
    find('.navbar-leihs .dropdown-menu')
      .find('button b', text: lang)
  when '/manage', '/borrow'
    find('footer strong', text: lang)
  else
    raise
  end
end

step "the language was changed to :lang everywhere" do |lang|
  subapp_paths = [
    '/admin/',
    '/borrow',
    '/procure',
    '/manage',
    '/my'
  ]
  subapp_paths.each do |sap|
    visit sap
    case sap
    when '/admin/', '/procure', '/my'
      find('.fa-globe').click
      find('.navbar-leihs .dropdown-menu')
        .find('button b', text: lang)
    when '/manage', '/borrow'
      find('footer strong', text: lang)
    else
      raise
    end
  end
end

step "the current language is :lang" do |lang|
  visit "/my/user/me"
  find('.fa-globe').click
  find('.navbar-leihs .dropdown-menu')
    .find('button b', text: lang)
end
