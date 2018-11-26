step "there is no section with subapps in the navbar " \
     "for the :subapp subapp" do |subapp|
  case subapp
  when "/borrow"
    expect(all(".topbar-navigation.float-right .topbar-item").count).to eq 1
    expect(find(".topbar-navigation.float-right .topbar-item"))
      .to have_content @user.email
  when "/procure", "/admin"
    within ".navbar-leihs" do
      expect(current_scope).not_to have_selector "svg[data-icon='chart-pie']"
    end
  end
end
