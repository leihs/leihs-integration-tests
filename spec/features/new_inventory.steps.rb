step 'I see the /inventory main page' do
  find("#app > main > div > h1", text: "Welcome")
end

step 'I see the inventory list page' do
  find("a[href='/inventory']", text: "Inventarliste")
end
