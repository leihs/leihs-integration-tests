step 'I see the correct release version in the footer' do
  release_file_path = File.join('../LEIHS-VERSION')
  content = File.read(release_file_path)
  version = content.split("\n").first
  gh_url = 'https://github.com/leihs/leihs'
  find("footer a[href='#{gh_url}']", text: version)
end
