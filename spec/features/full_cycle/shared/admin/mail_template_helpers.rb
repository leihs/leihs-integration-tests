def adjust_mail_template_subject(name, locale, subject, pool = nil)
  visit "/admin/"

  if pool
    click_on "Inventory Pools"
    click_on pool.name
    within ".inventory-pool" do
      click_on "Mail Templates"
    end
  else
    click_on "Mail Templates"
  end

  select name, from: "name"
  select locale, from: "language_locale"
  click_on name
  click_on "Edit"
  fill_in "subject", with: subject
  click_on "Save"
end

def check_pool_template_subject(name, locale, subject, pool)
  visit "/admin/"
  click_on "Inventory Pools"
  click_on pool.name
  within ".inventory-pool" do
    click_on "Mail Templates"
  end
  select name, from: "name"
  select locale, from: "language_locale"
  click_on name
  expect(find("td.subject").text).to eq(subject)
end
