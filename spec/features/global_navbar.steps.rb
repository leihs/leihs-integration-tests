step "there is no section with subapps in the navbar " \
     "for the :subapp subapp" do |subapp|
  case subapp
  when "/borrow"
    expect(all(".topbar-navigation.float-right .topbar-item").count).to eq 1
    expect(find(".topbar-navigation.float-right .topbar-item"))
      .to have_content @user.email
  when "/procure", "/admin", "/my"
    within ".navbar-leihs" do
      expect(current_scope).not_to have_selector "svg[data-icon='chart-pie']"
    end
  else
    raise
  end
end

def expect_subsections(table)
  subsecs = table.raw.flatten
  subsecs.each do |subsec|
    find("a", text: subsec)
  end
  expect(all("a").count).to eq subsecs.count
end

step "there is a section in the navbar for :subapp with following subapps:" \
  do |subapp, table|
  case subapp
  when "/admin"
    within ".navbar-leihs" do
      find("svg[data-icon='chart-pie']").click
      within ".dropdown-menu" do
        expect_subsections(table)
      end
    end
  when "/borrow"
    within "nav.topbar .topbar-navigation.float-right" do
      first(".topbar-item").hover
      within find(".dropdown-holder", match: :first) do
        expect_subsections(table)
      end
    end
  else
    raise
  end
end
