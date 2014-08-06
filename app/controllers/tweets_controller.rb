class TweetsController < InheritedResources::Base
  actions :index
  respond_to :json, only: :index
  belongs_to :user
end
