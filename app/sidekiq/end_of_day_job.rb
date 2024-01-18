class EndOfDayJob
  include Sidekiq::Job

  def perform(*args)
    male_count, female_count = fetch_daily_record_from_redis

    store_daily_record_in_db(male_count, female_count)

    update_average_age_in_daily_record
  end

  private

  def fetch_daily_record_from_redis
    redis = Redis.new(url: 'redis://localhost:6379/0')

    # Fetch male_count and female_count from Redis hash
    male_count = redis.hget('hourly_record', 'male_count').to_i
    female_count = redis.hget('hourly_record', 'female_count').to_i

    [male_count, female_count]
  end

  def store_daily_record_in_db(male_count, female_count)
    DailyRecord.create(
      date: Date.current,
      male_count: male_count,
      female_count: female_count
    )
  end

  def update_average_age_in_daily_record
    latest_daily_record = DailyRecord.order(date: :desc).first

    return unless latest_daily_record

    male_avg_age = calculate_average_age('male')
    female_avg_age = calculate_average_age('female')

    # Update DailyRecord with the calculated average ages
    latest_daily_record.update(
      male_avg_age: male_avg_age,
      female_avg_age: female_avg_age
    )
  end

  def calculate_average_age(gender)
    users = User.where(gender: gender)

    total_count = users.count
    total_age = users.sum(:age)

    average_age = total_count.positive? ? total_age.to_f / total_count : 0.0

    average_age
  end
end
