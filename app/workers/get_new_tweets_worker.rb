class GetNewTweetsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :default, unique: true

  def perform(id)
    user = User.find(id)
    Twc.new(user).append_tweets
  end
end