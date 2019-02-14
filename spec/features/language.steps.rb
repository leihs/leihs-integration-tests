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
