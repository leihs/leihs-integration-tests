step "the saved language in my user profile is :lang" do |lang|
  l = Language.find(name: lang)
  expect(@user.reload.language_locale).to eq l.locale
end

step "the saved language in my user profile is the default language" do
  dl = Language.find(default: true)
  expect(@user.reload.language_locale).to eq dl.id
end

step "the used language is the default language" do
  within ".ui-lang-selection" do
    current_scope.click
    current_scope.find(".ui-selected-lang",
      text: Language.find(default: true).name)
    current_scope.click
  end
end

step "the used language is :lang" do |lang|
  within ".ui-lang-selection" do
    current_scope.click
    current_scope.find(".ui-selected-lang", text: lang)
    current_scope.click
  end
end

step "the default language is :lang" do |lang|
  Language.find(name: lang).update(default: true)
end

step "the language :lang is deactivated" do |lang|
  Language.find(name: lang).update(active: false)
end

step "the language :lang is activated" do |lang|
  Language.find(name: lang).update(active: true)
end

step "I switch the language to :lang" do |lang|
  within ".ui-lang-selection" do
    current_scope.click
    current_scope.find(".dropdown-item", text: lang).click
  end
end

# call from within a `.navbar-leihs` scope
def open_navbar_languages_menu
  find(".fa-globe").click
  # the bootstrap dropdown toggle is occasionally flaky right after a
  # cross-app session/language switch; retry the click once if the menu
  # didn't actually open in time
  begin
    find(".dropdown-menu", wait: 2)
  rescue Capybara::ElementNotFound
    find(".fa-globe").click
    find(".dropdown-menu", wait: 2)
  end
end

def open_radix_languages_menu(lang)
  within "nav.container" do
    find("button", text: @user.name).click
  end

  page.find('[data-radix-menu-content][data-state="open"]', visible: :all)
  find("button[data-test-id=language-menu]").click
  find("button[data-test-id=language-btn-selected]")
end

step "I change the language to :lang in :subapp" do |lang, subapp|
  case subapp
  when "/admin/", "/procure", "/my/auth-info"
    within ".navbar-leihs" do
      open_navbar_languages_menu
      find("button", text: lang).click
    end
  when "/inventory", "/lending"
    open_radix_languages_menu(lang)
    find("button[data-test-id=language-btn]", text: lang).click
  when "/borrow/"
    find("nav .ui-user-profile-button").click
    select(lang, from: "language-select")
  when "/manage"
    find("a", text: lang).click
  else
    raise
  end
end

step "the language was changed to :lang in :subapp" do |lang, subapp|
  case subapp
  when "/admin/", "/procure", "/my/auth-info"
    within(".navbar-leihs") { open_navbar_languages_menu }
      .find("button b", text: lang)
  when "/inventory", "/lending"
    activated_lang = open_radix_languages_menu(lang)
    expect(activated_lang.text).to eq lang
  when "/borrow/"
    expect(page).to have_select("language-select", selected: lang)
  when "/manage"
    find("footer strong", text: lang)
  else
    raise
  end
end

step "the language was changed to :lang everywhere" do |lang|
  subapp_paths = [
    "/admin/",
    "/borrow/",
    "/procure",
    "/inventory",
    "/lending",
    "/manage",
    "/my/auth-info"
  ]
  subapp_paths.each do |sap|
    visit sap
    case sap
    when "/admin/", "/procure", "/my/auth-info"
      within(".navbar-leihs") { open_navbar_languages_menu }
        .find("button b", text: lang)
    when "/inventory", "/lending"
      activated = open_radix_languages_menu(lang)
      expect(activated.text).to eq lang
    when "/borrow/"
      find("nav .ui-user-profile-button").click
      expect(page).to have_select("language-select", selected: lang)
    when "/manage"
      find("footer strong", text: lang)
    else
      raise
    end
  end
end

step "the current language is :lang" do |lang|
  visit "/my/auth-info"
  within(".navbar-leihs") { open_navbar_languages_menu }
    .find("button b", text: lang)
end
