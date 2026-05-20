step "I am logged in for the subapp :subapp" do |subapp|
  case subapp
  when "/admin/"
    within ".navbar-leihs" do
      find(".fa-circle-user").click
      expect(current_scope).to have_content @user.short_name
    end
  when %r{^/my.*}, "/procure"
    within ".navbar-leihs" do
      find(".fa-circle-user").click
      expect(current_scope).to have_content @user.short_name
    end
  when "/manage"
    within "nav.topbar" do
      expect(current_scope).to have_content @user.short_name
    end
  when "/borrow"
    visit("#{subapp}/current-user")
    expect(page).to have_content @user.email
  when "/lending"
    expect(page).to have_content @user.login
  else
    raise
  end
end

step "I am logged out from :subpath" do |subpath|
  case subpath
  when "/admin/", %r{^/my.*}, "/manage"
    visit subpath
    within ".navbar-leihs" do
      within "form[action='/sign-in']" do
        find("input[name='user']")
      end
    end
    if ["/manage"].include? subpath
      expect(current_path).to eq "/"
    end
  when "/borrow"
    visit subpath
    find("#inputEmail")
  when "/procure"
    visit subpath
    expect(current_path).to eq "/sign-in"
    expect(page).to have_content "Log into leihs"
  when "/lending"
    visit subpath
    expect(current_path).to eq "/lending/sign-in"
  else
    raise
  end
end

step "I log out from :subpath" do |subpath|
  case subpath
  when "/admin/"
    within ".navbar-leihs" do
      find(".fa-circle-user").click
      click_on "Logout"
    end
  when %r{^/my.*}, "/procure"
    within ".navbar-leihs" do
      find(".fa-circle-user").click
      click_on "Logout"
    end
  when "/manage"
    within "nav.topbar" do
      find(".topbar-item", text: @user.short_name).hover
      click_on "Logout"
    end
  when "/borrow"
    find("nav .ui-user-profile-button").click
    click_on "Logout"
  when "/lending"
    click_button "Sign out"
  else
    raise
  end
end
