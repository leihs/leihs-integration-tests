describe "initial setup", type: :feature, js: true do

  before :each do
    database_cleaner
  end

  example "create first admin" do
    visit '/'
    expect(page.current_path).to eq "/first_admin_user"

    within('form[action="/first_admin_user"]') do
      fill_in 'Last name', with: 'Admin'
      fill_in 'First name', with: 'Super'
      fill_in 'E-Mail', with: 'admin@leihs.example.com'
      fill_in 'Login', with: 'superadmin'
      fill_in 'Password *', with: 'secret'
      fill_in 'Password Confirmation *', with: 'secret'
    end

    click_button 'Save'

    expect(page.current_path).to eq "/"
    expect(page).to have_content \
      'First admin user has been created. Default database authentication system has been configured.'
  end

end
