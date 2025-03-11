step 'I see the correct release version in the footer' do
  gh_url = 'https://github.com/leihs/leihs'
  find("footer a[href='#{gh_url}']", text: 'x.y.z-beta')
end
