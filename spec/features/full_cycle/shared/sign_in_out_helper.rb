def sign_in_as user, pool=nil
  visit '/'
  fill_in 'user', with: user.email
  click_on 'Login'
  fill_in 'password', with: user.password
  click_on 'Continue'
  wait_until do
    ["/admin/", '/borrow',
     "/manage/#{pool.try(:id)}/inventory",
     "/manage/#{pool.try(:id)}/daily" ].include? current_path
  end
  case current_path
  when '/admin/'
    find('.fa-user-circle').click
    wait_until { page.has_content? user.lastname }
  when '/borrow'
    wait_until { page.has_content? user.lastname }
  when "/manage/#{pool.try(:id)}/inventory"
    wait_until { page.has_content? user.lastname }
  when "/manage/#{pool.try(:id)}/daily"
    wait_until { page.has_content? user.lastname }
  end
  visit '/'
end

def sign_out
  visit "/my/user/me"
  find(".fa-user-circle").click
  click_on "Logout"
  wait_until{ current_path == "/" }
end
