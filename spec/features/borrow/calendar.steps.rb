require 'timecop'

step 'THE TIME IS FIXED TO :timestamp' do |timestamp|
  Timecop.freeze(Time.parse(timestamp))
  puts 'FAKE TIME set to: ' + timestamp
end

step 'there is some model with some reservations' do
  @model =
    FactoryBot.create(
      :leihs_model,
      id: '4a2db46e-7333-4238-b724-2dada5ddb75b',
      product: 'AVCHD-Kamera Sony HXR-NX5E',
      manufacturer: 'Sony',
      description:
        'Semi-Professionelle Video-Kamera für schnelle und effiziente Aufnahmen / geeignet für Interviews, Theater und Musik Aufnahmen / einfachere Slow-Motion Aufnahmen (50 Bilder/Sek.) / geeignet für Benutzer mit mittleren bis guten Kenntnissen'
    )
  @items =
    10.times.map do |n|
      FactoryBot.create(
        :item,
        leihs_model: @model,
        owner: @pool,
        responsible: @pool,
        is_borrowable: n < 5 ? true : false
      )
    end

  # other users have running reservations for this model:
  now = DateTime.now
  @reservations =
    [
      { quantity: 2, start_date: now - 14.days, end_date: now + 14.days },
      { quantity: 1, start_date: now - 5.days, end_date: now + 2.days },
      { quantity: 2, start_date: now - 4.days, end_date: now + 3.days },
      { quantity: 2, start_date: now + 7.days, end_date: now + 9.days }
    ].map do |attrs|
      FactoryBot.create(
        :reservation,
        leihs_model: @model,
        inventory_pool: @pool,
        quantity: 1,
        status: 'approved',
        **attrs
      )
    end
end

step 'I look at the calendar in legacy UI' do
  visit "/borrow/models/#{@model.id}"
  click_button 'Add to order'
  wait_until do
    has_selector?('#booking-calendar') &&
      has_no_selector?('#booking-calendar .loading-bg')
  end
end

step 'I fetch the ModelCalendarData from the API' do
  # NOTE: this could be added to query, to get the error descriptions.
  #       maybe the errors should be proper types tho
  # startDateRestrictions: __type(name: "startDateRestrictionEnum") {
  #   enumValues {
  #     name
  #     description
  #   }
  # }
  # endDateRestrictions: __type(name: "endDateRestrictionEnum") {
  #   enumValues {
  #     name
  #     description
  #   }
  # }
  q = <<-GRAPHQL
        query ModelCalendarData($models: [UUID!]!, $pools: [UUID!]!, $startDate: Date!, $endDate: Date!) {
          models(ids: $models) {
            edges {
              node {
                id
                name
                availability(startDate: $startDate, endDate: $endDate, inventoryPoolIds: $pools) {
                  inventoryPool { id name }
                  dates {
                    date
                    quantity
                    startDateRestriction
                    endDateRestriction
                  }
                }
              }
            }
          }
        }
      GRAPHQL
  variables = {
    models: @model.id,
    pools: @pool.id,
    startDate: (DateTime.now).to_date,
    endDate: (DateTime.now.beginning_of_month + 2.months).to_date
  }
  @model_calendar_data = do_graphql_query(q, variables)
end

step 'I save this data as an artefact' do
  write_graphql_result_to_artefact(@model_calendar_data)
end

## shared steps candidates

step 'the user is customer of the pool :name' do |name|
  @pool =
    InventoryPool.find(name: name) ||
      FactoryBot.create(:inventory_pool, name: name)
  FactoryBot.create(
    :access_right,
    user_id: @user.id, role: :customer, inventory_pool: @pool
  )
end

## helpers

def do_graphql_query(query_string, variables = {}, log = true)
  params = { query: query_string, variables: variables }
  if log
    puts ['[GRAPHQL] QUERY:', query_string, ' ']
    puts ['[GRAPHQL] VARIABLES:', JSON.pretty_generate(variables), ' ']
  end
  visit '/'
  fetch_js = <<-JAVASCRIPT
    window.GRAPHQL_RESULT = null
    fetch('/app/borrow/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(#{params.to_json}),
      credentials: 'same-origin'
    })
      .then(res => res.json())
      .then(res => { window.GRAPHQL_RESULT = res })
  JAVASCRIPT

  execute_script(fetch_js)
  result = wait_until { evaluate_script 'window.GRAPHQL_RESULT' }
  puts ['[GRAPHQL] RESULT:', JSON.pretty_generate(result), ' '] if log
  result
end
