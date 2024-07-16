require 'spec_helper'

feature 'Audits' do
  def assert_http_unique_id(str)
    expect(str).to match(/^[a-zA-Z0-9\-\_]{24,}$/)
  end

  before(:each) do
    FactoryBot.create(:user, is_admin: true, admin_protected: true,
                      is_system_admin: true, system_admin_protected: true)
  end

  scenario 'work' do
    user = FactoryBot.create(:user)
    pool = FactoryBot.create(:inventory_pool)
    FactoryBot.create(:access_right,
                      user: user, inventory_pool: pool,
                      role: :inventory_manager)

    visit '/sign-in'
    fill_in 'user', with: user.email
    click_on 'Weiter'
    fill_in 'password', with: 'password'
    click_on 'Weiter'

    a_req_1 = AuditedRequest.order(:created_at).reverse.first
    expect(a_req_1.path).to eq '/sign-in'
    expect(a_req_1.to_hash[:method]).to eq 'POST'
    expect(a_req_1.user_id).to eq user.id
    UUIDTools::UUID.parse(a_req_1.txid)
    assert_http_unique_id(a_req_1.http_uid)

    a_rep_1 = AuditedResponse.where(txid: a_req_1.txid).first
    expect(a_rep_1.status).to eq 302

    visit "/manage/#{pool.id}/models/new"
    find("#product input").set 'Test Model'
    click_on 'Modell speichern'
    expect(find(id: 'flash')).to have_content 'Modell gespeichert'

    a_req_2 = AuditedRequest.order(:created_at).reverse.first
    expect(a_req_2.path).to eq "/manage/#{pool.id}/models"
    expect(a_req_2.to_hash[:method]).to eq 'POST'
    expect(a_req_2.user_id).to eq user.id
    UUIDTools::UUID.parse(a_req_2.txid)
    assert_http_unique_id(a_req_2.http_uid)

    a_rep_2 = AuditedResponse.where(txid: a_req_2.txid).first
    expect(a_rep_2.status).to eq 200

    a_change_2 = AuditedChange.order(:created_at).reverse.first
    expect(a_change_2.txid).to eq a_rep_2.txid
    expect(a_change_2.tg_op).to eq 'INSERT'
    expect(a_change_2.table_name).to eq 'models'
    expect(a_change_2.changed['product']).to eq([nil, 'Test Model'])

    find("span", text: "#{user.firstname.first}. #{user.lastname}").hover
    click_on 'Logout'

    a_req_3 = AuditedRequest.order(:created_at).reverse.first
    expect(a_req_3.path).to eq "/sign-out"
    expect(a_req_3.to_hash[:method]).to eq 'POST'
    expect(a_req_3.user_id).to eq user.id
    UUIDTools::UUID.parse(a_req_3.txid)
    assert_http_unique_id(a_req_3.http_uid)

    a_rep_3 = AuditedResponse.where(txid: a_req_3.txid).first
    expect(a_rep_3.status).to eq 302

    expect(AuditedRequest.where(method: ['GET', 'get']).count).to eq 0
  end
end
