require 'sidekiq'

class Twc
  include Sidekiq::Extensions

  def initialize(user, options = {:count => 5, :include_rts => true})
    @user = user
    @options = options
  end

  def user
    @user
  end

  def self.client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key    = "5csiEnL8UO8F62fkkFHDhrBuh"
      config.consumer_secret = "sgtQsfvoedPbNohrpS3ZfClMIn1hXMMTClA6xGIBwJPCuRKMry"
      config.access_token  = "426347307-5HnHZ9kjVY0RajGqmk2Tki4ws0D3xGDd2eg23OSZ"
      config.access_token_secret = "rYG98DtuAFxgFF15A9YdOMXMgPS2A8WPw5CRd2sOdo2YC"
    end
  end

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key    = "5csiEnL8UO8F62fkkFHDhrBuh"
      config.consumer_secret = "sgtQsfvoedPbNohrpS3ZfClMIn1hXMMTClA6xGIBwJPCuRKMry"
      config.access_token  = "426347307-5HnHZ9kjVY0RajGqmk2Tki4ws0D3xGDd2eg23OSZ"
      config.access_token_secret = "rYG98DtuAFxgFF15A9YdOMXMgPS2A8WPw5CRd2sOdo2YC"
    end
  end

  def get_tweets(options = {})
    @tweets = client.user_timeline(@user.name, @options)
  rescue
    @user.block!
  end

  def count_tweets
    @existed_tweets = @user.tweets.where(id: @tweets.map(&:id)).map(&:id)
    @tweets = @tweets.to_a.delete_if{|i| @existed_tweets.include? i.id}
  end

  def append_tweets
    get_tweets(@options)
    count_tweets
    if @tweets.empty? and !@user.blocked?
      @user.over! if @user.tweets.any? and @options.keys.include?(:max_id)
    end
    Tweet.transaction do
      @user.tweets.create(@tweets.map{|i| [{id: i.id, full_text: i.full_text, url: i.url.to_s}]})
    end
  end

  def append_new_tweets
    get_last_tweets
    count_tweets
    return nil if new_tweets.empty?
    Tweet.transaction do
      @user.tweets.create(new_tweets.map{|i| [{id: i.id, full_text: i.full_text, url: i.url.to_s}]})
    end
  end

  def self.init_user(user)
    if client.user(user.name)
      user.exist!
    end
  rescue
    user.absence!
  end
end