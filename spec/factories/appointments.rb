FactoryBot.define do
  factory :appointment do
    appointment_date { Date.today }
    appointment_time {'12:00'}
    personal
  end
end