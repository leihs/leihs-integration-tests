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
    # expect(a_req_1.user_id).to be nil
    UUIDTools::UUID.parse(a_req_1.txid)
    assert_http_unique_id(a_req_1.http_uid)

    a_rep_1 = AuditedResponse.where(txid: a_req_1.txid).first
    expect(a_rep_1.status).to eq 302

    # first(".media-set").click
    # collection_id = extract_uuid(current_path)
    # find(id: "Weitere Aktionen_menu").click
    # click_on "Set löschen"
    # click_on "Löschen"

    # a_req_2 = AuditedRequest.order(:created_at).reverse.first
    # expect(a_req_2.path).to eq "/sets/#{collection_id}"
    # expect(a_req_2.to_hash[:method]).to eq 'DELETE'
    # expect(a_req_2.user_id).to eq user.id
    # UUIDTools::UUID.parse(a_req_2.txid)
    # assert_http_unique_id(a_req_2.http_uid)

    # person = Person.first
    # visit "/admin/people/#{person.id}/edit"
    # fill_in 'person[description]', with: 'test description'
    # click_on 'Save'

    # a_req_3 = AuditedRequest.order(:created_at).reverse.first
    # expect(a_req_3.path).to eq "/admin/people/#{person.id}"
    # expect(a_req_3.to_hash[:method]).to eq 'PATCH'
    # expect(a_req_3.user_id).to eq user.id
    # UUIDTools::UUID.parse(a_req_3.txid)
    # assert_http_unique_id(a_req_3.http_uid)

    # a_rep_3 = AuditedResponse.where(txid: a_req_3.txid).first
    # expect(a_rep_3.status).to eq 302

    # a_change_3 = AuditedChange.order(:created_at).reverse.first
    # expect(a_change_3.txid).to eq a_rep_3.txid
    # expect(a_change_3.tg_op).to eq 'UPDATE'
    # expect(a_change_3.table_name).to eq 'people'
    # expect(a_change_3.changed).to eq({"description"=>[nil, "test description"]})

    # visit '/my'
    # find(id: "#{user.first_name} #{user.last_name}_menu").click
    # click_on 'Abmelden'

    # a_req_4 = AuditedRequest.order(:created_at).reverse.first
    # expect(a_req_4.path).to eq "/auth/sign-out"
    # expect(a_req_4.to_hash[:method]).to eq 'POST'
    # expect(a_req_4.user_id).to eq user.id
    # UUIDTools::UUID.parse(a_req_4.txid)
    # assert_http_unique_id(a_req_4.http_uid)

    # a_rep_4 = AuditedResponse.where(txid: a_req_4.txid).first
    # expect(a_rep_4.status).to eq 302

    # expect(AuditedRequest.where(method: ['GET', 'get']).count).to eq 0
  end
end
