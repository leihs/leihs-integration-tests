step 'I see the correct release version in the footer' do
  releases = YAML.load_file('../config/releases.yml')
  @version = \
    releases['releases']
    .first
    .slice('version_major', 'version_minor', 'version_patch')
    .values
    .map(&:to_s)
    .join('.')
  find("footer a[href='/release']", text: @version)
end

step 'I click on the release version link' do
  find("footer a[href='/release']", text: @version).click
end
