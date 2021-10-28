step "I open the main menu" do
  wait_until do
    find("nav .ui-menu-icon").click
    @menu = all("#menu", wait: false).first
  end
end
