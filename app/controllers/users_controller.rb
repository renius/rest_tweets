class UsersController < InheritedResources::Base
  actions :create
  respond_to :json, only: :create

  def create
    create! do |format|
      format.json
    end
  end

  def build_resource_params
    [params.fetch(:user, {}).permit(:name)]
  end
end
