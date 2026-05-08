step "I see the correct release version in the footer" do
  gh_url = "https://github.com/leihs/leihs/releases/tag/x.y.z"
  find("footer a[href='#{gh_url}']", text: "x.y.z")
end
