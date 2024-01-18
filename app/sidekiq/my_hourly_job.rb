class MyHourlyJob
  include Sidekiq::Job

  def perform(*args)
    begin
      user_records = fetch_random_user_records

      user_records.each do |user_record|
        update_or_create_user(user_record)
      end

      store_counts_in_redis(user_records)
    rescue StandardError => e
      puts "Error in perform: #{e.message}"
    end
  end

  private

  def fetch_random_user_records
    response = RestClient.get('https://randomuser.me/api/?results=20')
    if response.code == 200
      records = JSON.parse(response.body)['results']
      return records
    else
      raise StandardError, "API request failed with status: #{response.code}"
    end
  rescue RestClient::ExceptionWithResponse => e
    raise StandardError, "RestClient error: #{e.response}"
  end

  def update_or_create_user(user_record)
    user = User.find_or_initialize_by(uuid: user_record['login']['uuid'])
    user.gender = user_record['gender']
    user.name = user_record['name']
    user.location = user_record['location']
    user.age = user_record['dob']['age']
    user.save
  end

  def store_counts_in_redis(user_records)
    redis = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')
    male_count = user_records.count { |user| user['gender'] == 'male' }
    female_count = user_records.count { |user| user['gender'] == 'female' }

    redis.hmset('hourly_record', 'male_count', male_count, 'female_count', female_count)
  end
end
