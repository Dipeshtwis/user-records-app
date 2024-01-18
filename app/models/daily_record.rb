class DailyRecord < ApplicationRecord
  before_save :calculate_average_age, if: -> { saved_change_to_male_count? || saved_change_to_female_count? }

  private

  def calculate_average_age
    start_date = self.created_at.to_date
    end_date = start_date.end_of_day

    total_male_count = User.where(gender: 'male', created_at: start_date.beginning_of_day..end_date).count
    total_female_count = User.where(gender: 'female', created_at: start_date.beginning_of_day..end_date).count
    total_male_age = User.where(gender: 'male', created_at: start_date.beginning_of_day..end_date).sum(:age)
    total_female_age = User.where(gender: 'female', created_at: start_date.beginning_of_day..end_date).sum(:age)

    self.male_avg_age = total_male_age.to_f / total_male_count if total_male_count.positive?
    self.female_avg_age = total_female_age.to_f / total_female_count if total_female_count.positive?
  end
end
