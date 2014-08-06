class ProcessTweetsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { secondly(20) }

  sidekiq_options retry: false, queue: :single, unique: true

  def perform
    blocks = User.where(process_state: :blocked)
    block = blocks.maximum(:blocked_at) || Time.now < Time.now - 15.minutes

    if blocks.any? && blocks.maximum(:blocked_at) < Time.now - 15.minutes
      blocks.update_all(process_state: :waiting)
    end

    return true if User.where(process_state: :blocked).any?
    User.where(base_state: :existed, process_state: :waiting).each do |user|
      GetNewTweetsWorker.perform_async(user.id)
    end

    User.where(base_state: :existed, process_state: :waiting).each do |user|
      GetOldTweetsWorker.perform_async(user.id) if user.tweets.any?
    end
  end
end