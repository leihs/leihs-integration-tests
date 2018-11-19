step "I change the language to :lang" do |lang|
  find("a", text: lang).click
end

step "user's preferred language is :lang" do |lang|
  l = Language.find(name: lang)
  @user.update(language_id: l.id)
end

step "the language was changed to :lang in the current subapp" do |lang|
  find('strong', text: lang)
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
    binding.pry
  end
end
