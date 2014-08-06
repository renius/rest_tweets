class User < ActiveRecord::Base
  has_many :tweets, dependent: :destroy
  validates_presence_of :name

  state_machine :base_state, initial: :pending do
    event :exist do
      transition [:pending, :absent] => :existed
    end

    event :absence do
      transition [:pending, :existed] => :absent
    end

    event :pend do
      transition absent: :pending
    end
  end

  state_machine :process_state, initial: :waiting do
    event :block do
      transition waiting: :blocked
    end

    event :unblock do
      transition blocked: :waiting
    end

    event :over do
      transition waiting: :processed
    end
  end

  def update_tweets(user)
    @client = Twc.get_tweets(user)
  end

  def init_user
    Twc.delay.init_user(self)
  end
end