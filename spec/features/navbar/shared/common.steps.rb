step "there is no section with subapps in the navbar " \
     "for the :subapp subapp" do |subapp|
  case subapp
  when "/borrow"
    expect(all(".topbar-navigation.float-right .topbar-item").count).to eq 1
    expect(find(".topbar-navigation.float-right .topbar-item"))
      .to have_content @user.short_name
  when "/procure", "/admin", "/my/auth-info"
    within ".navbar-leihs .navbar-collapse" do
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
  when "/admin", "/procure"
    within ".navbar-leihs .navbar-collapse" do
      find("svg[data-icon='chart-pie']").click
      within ".dropdown-menu" do
        expect_subsections(table)
      end
    end
  when "/borrow"
    sleep 0.5
    find(".ui-app-menu-link").click
    within first(".ui-topnav-dropdown") do
      expect_subsections(table)
    end
  when "/manage"
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

step "there is no app menu link in the borrow navbar" do
  sleep 0.5
  expect(page).not_to have_selector(".ui-app-menu-link")
end

def expect_user_sections(table)
  subsecs = table.raw.flatten
  expect(current_scope.text).to eq subsecs.join("\n")
end

def expect_user_sections_inventory(table)
  menu = page.find('[data-radix-menu-content][data-state="open"]', visible: :all)
  actual = menu.all("a, button", visible: :all).map do |el|
    el.text(:all).strip
  end.reject(&:empty?)

  expected = table.raw.flatten.map(&:strip)
  expect(actual).to eq(expected)
end

step "I see in the borrow subapp following entries in the user section:" do |table|
  subsecs = table.raw.flatten
  within "#user-menu" do
    expect(current_scope.text).to eq subsecs.join("\n")
  end
end

step "I see following entries in the user section for the :subapp :" \
  do |subapp, table|
  case subapp
  when /\/manage/
    within find(".topbar-item", text: "F. Bar") do
      expect_user_sections(table)
    end
  when /\/inventory/
    expect_user_sections_inventory(table)
  when "/admin/", "/my/auth-info", "/procure"
    within ".navbar-leihs" do
      within ".dropdown-menu" do
        expect_user_sections(table)
      end
    end
  else
    raise
  end
end

step "I open the subapps dropdown" do
  within ".navbar-leihs" do
    find("svg[data-icon='chart-pie']").click
  end
end

step "I open the user dropdown for the :subapp" do |subapp|
  case subapp
  when "/admin/"
    within ".navbar-leihs" do
      find("svg[data-icon='circle-user']").click
    end
  when "/inventory"
    within "nav.container" do
      find("button", text: /Foo Bar/).click
    end
  when "/my/auth-info", "/procure"
    within ".navbar-leihs" do
      find("svg[data-icon='user-circle']").click
    end
  when "/borrow"
    find(".ui-user-profile-button").click
  when /\/manage/
    # we need to move the pointer out and then in again to make this work
    # reliably (e.g. wenn called multipe times) ; do not remove the first hover
    # even if seems pointless
    within(first("a", text: "leihs")) { current_scope.hover }
    within find(".topbar-item", text: "F. Bar") do
      current_scope.hover
      find(".dropdown")
    end
  else
    raise
  end
end

step "firstname of the user is :name" do |name|
  User.where(id: @user.id).update(firstname: name)
end

step "lastname of the user is :name" do |name|
  User.where(id: @user.id).update(lastname: name)
end
