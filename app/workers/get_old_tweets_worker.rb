class GetOldTweetsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :default, unique: true

  def perform(id)
    user = User.find(id)
    unless user.tweets.empty?
      Twc.new(user, {:count => 5, :include_rts => true, max_id: user.tweets.minimum(:id)}).append_tweets
    end
  end
end