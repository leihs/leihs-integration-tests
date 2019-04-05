step "I am logged in for the subapp :subapp" do |subapp|
  case subapp
  when "/admin/", "/my", "/procure"
    within ".navbar-leihs" do
      find(".fa-user-circle").click
      expect(current_scope).to have_content @user.short_name
    end
  when "/borrow", "/manage"
    within "nav.topbar" do
      expect(current_scope).to have_content @user.short_name
    end
  else
    raise
  end
end

step "I am logged out from :subpath" do |subpath|
  case subpath
  when "/admin/", "/my", "/borrow", "/manage"
    visit subpath
    within ".navbar-leihs" do
      within "form[action='/sign-in']" do
        find("input[name='user']")
      end
    end
    if ["/borrow", "/manage"].include? subpath
      expect(current_path).to eq "/"
    end
  when "/procure"
    visit subpath
    expect(page).to have_content "NOT_AUTHENTICATED"
  else
    raise
  end
end

step "I log out from :subpath" do |subpath|
  case subpath
  when "/admin/", "/my", "/procure"
    within ".navbar-leihs" do
      find(".fa-user-circle").click
      click_on "Logout"
    end
  when"/borrow", "/manage"
    within "nav.topbar" do
      find(".topbar-item", text: @user.short_name).hover
      click_on "Logout"
    end
  else
    raise
  end
end
