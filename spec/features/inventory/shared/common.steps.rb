step "I open the app menu" do
  find("nav button", text: "Inventory").click
end

step "I enter :term in the global search field and press enter" do |term|
  field = find("input[name='search_term']")
  field.set(term)
  field.send_keys :enter
end
