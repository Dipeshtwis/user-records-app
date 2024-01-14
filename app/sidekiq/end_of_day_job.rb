class EndOfDayJob
  include Sidekiq::Job

  def perform(*args)
    male_count, female_count = fetch_daily_record_from_redis
  end

  private

  def fetch_daily_record_from_redis
    redis = Redis.new(url: 'redis://localhost:6379/0')

    # Fetch male_count and female_count from Redis hash
    male_count = redis.hget('hourly_record', 'male_count').to_i
    female_count = redis.hget('hourly_record', 'female_count').to_i

    [male_count, female_count]
  end
end
