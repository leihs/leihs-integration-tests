step 'there is a budget period in requesting phase' do
  @budget_period = FactoryBot.create(:procurement_budget_period,
                                     :requesting_phase)
end

step 'there is category' do
  @category = FactoryBot.create(:procurement_category)
end

step 'there is category :category' do |category|
  @category = FactoryBot.create(:procurement_category,
                                name: category)
end

step 'there is a requester :name' do |name|
  fn, ln = name.split(' ')
  @requester = FactoryBot.create(:user,
                                 firstname: fn,
                                 lastname: ln)
  @requester_organization = \
    FactoryBot.create(:procurement_requester, user: @requester)
end

step 'there is a requester' do
  @requester = FactoryBot.create(:user)
  @requester_organization = \
    FactoryBot.create(:procurement_requester, user: @requester)
end

step 'within the line of the budget period I click on +' do
  within find('.card.mb-3', text: @budget_period.name) do
    find('.fa-plus-circle').click
  end
end

step 'within the line of the budget period :bp I click on +' do |bp|
  within find('.card.mb-3', text: bp) do
    find('.fa-plus-circle').click
  end
end

step 'I expand the line of the main category :main_cat' do |main_cat|
  find('li', text: main_cat).click
end

step 'I expand the line of the main category of the category :cat' do |cat|
  c = ProcurementCategory.find(name: cat)
  find('li', text: c.main_category.name).click
end

step "I don't see the main category of the category :cat" do |cat|
  c = ProcurementCategory.find(name: cat)
  expect(page).not_to have_content c.main_category.name
end

step 'I expand the line of the category :cat' do |cat|
  find('li', text: cat, match: :first).click
end

step 'I expand the request line' do
  find('li', text: @request.article_name, match: :first).click
end

step 'within the line of the category I click on +' do
  within find('.card.list-group-item', text: @category.name) do
    find('.fa-plus-circle').click
  end
end

step 'within the line of category :cat I click on +' do |cat|
  within find('.card.list-group-item', text: cat) do
    find('.fa-plus-circle').click
  end
end

step 'I enter the following data into the request form:' do |table|
  ctx = @request ? find("form[id='#{@request.id}']") : current_scope

  table.hashes.each do |h|
    f = h['field']
    v = h['value']

    within ctx.find('.form-group', text: f, match: :first) do
      case f
      when \
        'Artikel oder Projekt',
        'Artikelnr. oder Herstellernr.',
        'Lieferant',
        'Name des Empfängers',
        'Stückpreis CHF',
        'Menge beantragt',
        'Menge bewilligt',
        'Bestellmenge',
        'Innenauftrag'
        find('input').set v
      when 'Antragsteller'
        fn, ln = v.split(' ')
        @request_user = User.find(firstname: fn, lastname: ln)
        find('input').set v
        within '.ui-interactive-text-field-results' do
          find('div', text: v).click
        end
      when 'Begründung', 'Kommentar des Prüfers'
        find('textarea').set v
      when 'Priorität', 'Priorität des Prüfers', 'Gebäude', 'Raum'
        find('select option', text: /^#{v}$/).select_option
      when 'Abrechnungsart'
        find('label.btn', text: v).click
      when 'Ersatz / Neu'
        find('label', text: /^#{v}$/).click
      when 'Anhänge'
        if @request
          all('.input-file-upload-list .fa-trash-alt').each(&:click)
        end

        fp = File.absolute_path("spec/files/#{v}")
        find("input[type='file']", visible: false).attach_file(fp)
        # wait until the upload is finished
        find('.input-file-upload-list li', text: v).find('.fa-trash-alt')
      end
    end
  end
end

step 'I see a success message' do
  expect(page).to have_selector '.alert-success'
end

step 'the request form has the following data:' do |table|
  ctx = @request ? find("form[id='#{@request.id}']") : current_scope

  table.hashes.each do |h|
    f = h['field']
    v = h['value']

    within ctx.find('.form-group', text: f, match: :first) do
      case f
      when \
        'Artikel oder Projekt',
        'Artikelnr. oder Herstellernr.',
        'Lieferant',
        'Name des Empfängers',
        'Stückpreis CHF',
        'Menge bewilligt',
        'Bestellmenge',
        'Innenauftrag',
        'Antragsteller'
        expect(find('input').value).to eq v
      when 'Menge beantragt'
        # a different "Antragsteller"
        if @request_user and
            @request_user != @user and
            @budget_period.inspection_start_date > Date.today
          find('span', text: v)
        else
          expect(find('input').value).to eq v
        end
      when 'Begründung'
        # a different "Antragsteller"
        if @request_user and @request_user != @user and not @procurement_admin
          find('span', text: v)
        else
          expect(find('textarea').value).to eq v
        end
      when 'Kommentar des Prüfers'
        expect(find('textarea').value).to eq v
      when 'Priorität', 'Priorität des Prüfers', 'Gebäude', 'Raum'
        expect(
          find('select option', text: /^#{v}$/)
        ).to be_selected
      when 'Abrechnungsart'
        expect(
          find('label.btn', text: /^#{v}$/).find('input')
        ).to be_checked
      when 'Ersatz / Neu'
        expect(
          find('label', text: /^#{v}$/).find('input')
        ).to be_checked
      when 'Anhänge'
        expect(
          find('.input-file-upload-list li a', text: v)
        ).to be
      end
    end
  end
end

step 'I see a delete button' do
  within find("form[id='#{@request.id}']") do
    find('button', text: 'Löschen')
  end
end

step 'I click on the delete button and accept the alert' do
  accept_alert do
    within find("form[id='#{@request.id}']") do
      find('button', text: 'Löschen').click
    end
  end
end

step 'I uncheck filter option :label' do |label|
  find('label', text: label).click
end

step 'the category :cat for budget period :bp is expanded' do |cat, bp|
  find('.card', text: 'Budget Period BP')
    .find('.list-group-item', match: :first, text: 'Category C')
    .find('.fa-caret-down')
end

step "I don't see the request" do
  expect(page).not_to have_content @request.article_name
end

step 'the request was deleted in the database' do
  expect { @request.reload }.to raise_error Sequel::NoExistingObject
end
