step "there is no section with subapps in the navbar " \
     "for the :subapp subapp" do |subapp|
  case subapp
  when "/borrow"
    expect(all(".topbar-navigation.float-right .topbar-item").count).to eq 1
    expect(find(".topbar-navigation.float-right .topbar-item"))
      .to have_content @user.short_name
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
  when "/admin", "/procure"
    within ".navbar-leihs" do
      find("svg[data-icon='chart-pie']").click
      within ".dropdown-menu" do
        expect_subsections(table)
      end
    end
  when "/borrow", "/manage"
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

def expect_user_sections(table)
  subsecs = table.raw.flatten
  expect(current_scope.text).to eq subsecs.join("\n")
end

step "I see following entries in the user section for the :subapp :" \
  do |subapp, table|
  case subapp
  when "/borrow", /\/manage/
    within find(".topbar-item", text: "F. Bar") do
      expect_user_sections(table)
    end
  when "/admin/", "/my/user/me", "/procure"
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
  when "/admin/", "/my/user/me", "/procure"
    within ".navbar-leihs" do
      find("svg[data-icon='user-circle']").click
    end
  when "/borrow", /\/manage/
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
