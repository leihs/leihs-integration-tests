module InitialSteps

  step "there is an empty database" do
    database_cleaner
  end

  step "I go to :url" do |url|
    visit url
  end

  step "I am redirected to :url" do |url|
    wait_until(12) { page.current_path == url }
    expect(page.current_path).to eq url
  end

  step "I fill out the form with:" do |table|
    within('form:first-child') do
      fill_form_with_table(table)
    end
  end

  step "I click the button :btn" do |btn|
    click_button(btn)
  end

  step "I see the text:" do |txt|
    expect(page).to have_content(txt.strip())
  end


  def fill_form_with_table(table)
    table.hashes.each do |row|
      fill_in(row['field'], with: row['value'])
    end
  end
end

RSpec.configure { |c| c.include InitialSteps }
