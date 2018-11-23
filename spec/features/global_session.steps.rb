step "I am logged in :subapp" do |subapp|
  case subapp
  when "/admin/", "/my/user/me", "/procure"
    within ".navbar-leihs" do
      find(".fa-user-circle").click
      expect(current_scope).to have_content @user.email
    end
  when "/borrow", "/manage"
    within "nav.topbar" do
      expect(current_scope).to have_content @user.email
    end
  else
    raise
  end
end
