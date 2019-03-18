step 'there are procurement settings' do
  FactoryBot.create(:procurement_settings)
end

step 'there is a budget period :budget_period in requesting phase' do |budget_period|
  @budget_period = FactoryBot.create(:procurement_budget_period,
                                     :requesting_phase,
                                     name: budget_period)
end

step 'there is a budget period :budget_period in inspection phase' do |budget_period|
  @budget_period = FactoryBot.create(:procurement_budget_period,
                                     :inspection_phase,
                                     name: budget_period)
end

step 'there is a budget period :budget_period in past phase' do |budget_period|
  @budget_period = FactoryBot.create(:procurement_budget_period,
                                     :past_phase,
                                     name: budget_period)
end

step 'there is category :c for main category :mc' do |cat, main_cat|
  mc = ProcurementMainCategory.find(name: main_cat)
  FactoryBot.create(:procurement_category,
                    name: cat,
                    main_category: mc)
end

step 'there is a main category :mc' do |mc|
  FactoryBot.create(:procurement_main_category, name: mc)
end

step 'there is a department :dep' do |dep|
  FactoryBot.create(:procurement_department, name: dep)
end

step 'there is an organization :org within :dep' do |org, dep|
  d = ProcurementOrganization.find(name: dep)
  FactoryBot.create(:procurement_organization,
                    name: org,
                    parent_id: d.id)
end

step 'there is a requester :name for :org within :dep' do |name, org, dep|
  fn, ln = name.split(' ')
  d = ProcurementOrganization.find(name: dep)
  o = ProcurementOrganization.find(name: org, parent_id: d.id)
  @requester = FactoryBot.create(:user, firstname: fn, lastname: ln)
  @requester_organization = FactoryBot.create(:procurement_requester,
                                              user: @requester,
                                              organization: o)
end

step 'there is a request with the following data:' do |table|
  attrs = {}
  procs = []

  table.hashes.each do |h|
    f = h['field']
    v = h['value']

    attrs.merge! \
      case f
      when 'Requester'
        fn, ln = h['value'].split(' ')
        { user: User.find(firstname: fn, lastname: ln) }
      when 'Organization'
        { organization: ProcurementOrganization.find(name: h['value']) }
      when 'Budgetperiode'
        bp = ProcurementBudgetPeriod.find(name: v)
        { budget_period: bp }
      when 'Kategorie'
        c = ProcurementCategory.find(name: v)
        { category: c }
      when 'Artikel oder Projekt'
        { article_name: v }
      when 'Artikelnr. oder Herstellernr.'
        { article_number: v }
      when 'Lieferant'
        { supplier_name: v }
      when 'Name des Empfängers'
        { receiver: v }
      when 'Stückpreis CHF'
        { price_cents: (v.to_i * 100) }
      when 'Menge beantragt'
        { requested_quantity: v.to_i }
      when 'Menge bewilligt'
        { approved_quantity: v.to_i }
      when 'Begründung'
        { motivation: v }
      when 'Priorität'
        p = case v
            when 'Hoch' then 'high'
            when 'Normal' then 'normal'
            else raise
            end
        { priority: p }
      when 'Priorität des Prüfers'
        p = case v
            when 'Hoch' then 'high'
            when 'Normal' then 'normal'
            when 'Niedrig' then 'low'
            when 'Zwingend' then 'mandatory'
            else raise
            end
        { inspector_priority: p }
      when 'Gebäude'
        @b = Building.find(name: v)
        { }
      when 'Raum'
        r = Room.find(name: v, building_id: @b.id)
        { room: r }
      when 'Ersatz / Neu'
        rpl = case v
              when 'Ersatz' then true
              when 'Neu' then false
              else raise
              end
        { replacement: rpl }
      when 'Anhänge'
        p = (
          lambda do |r|
            FactoryBot.create(:procurement_attachment,
                              filename: v,
                              request_id: r.id)
          end
        )
        procs.push(p)
        { }
      else
        raise 'Field not defined'
      end

  end

  @request = FactoryBot.create(:procurement_request, attrs)
  procs.each { |p| p.call(@request) }
end

step 'there is a request of requester with the following data:' do |table|
  ext = [
    ['Requester', @requester.name],
    ['Organization', @requester_organization.organization.name]
  ]

  table.raw.concat(ext) # mutable operation
  step 'there is a request with the following data:', table
end

step 'I log in as the requester' do
  @user ||= @requester
  step 'I log in as the user'
end

step 'I log in as the inspector' do
  @user ||= @inspector
  step 'I log in as the user'
end

step 'I log in as the viewer' do
  @user ||= @viewer
  step 'I log in as the user'
end

step 'I log in as the procurement admin' do
  @user ||= @procurement_admin
  step 'I log in as the user'
end

step 'I log in as the requester :name' do |name|
  fn, ln = name.split(' ')
  u = User.find(firstname: fn, lastname: ln)
  @user ||= @requester = u
  step 'I log in as the user'
end
