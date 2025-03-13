class ProcurementBudgetPeriod < Sequel::Model
end

FactoryBot.define do
  factory :procurement_budget_period do
  end

  trait :inspection_phase do
    name { "BP in inspection phase" }
    inspection_start_date { Date.yesterday }
    end_date { Date.today + 1.months }
  end

  trait :requesting_phase do
    name { "BP in requesting phase" }
    inspection_start_date { Date.today + 2.month }
    end_date { Date.today + 3.months }
  end

  trait :past_phase do
    name { "BP in past phase" }
    inspection_start_date { Date.today - 3.months }
    end_date { Date.yesterday }
  end
end
