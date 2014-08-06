class ProcessPresenceWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { secondly(20) }

  sidekiq_options :retry => 5, queue: :default, unique: true

  sidekiq_retry_in do |count|
    15*60 + 5
  end

  def perform()
    return nil if User.where(process_state: :blocked).any?

    User.where(base_state: :pending).each do |user|
      Twc.init_user(user)
    end
  end

end