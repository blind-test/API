class UserController < ApplicationController
  getter user = User.new

  before_action do
    only [:show, :update, :destroy] { set_user }
  end

  def index
    pp "hello"
    users = User.all
    respond_with do
      json users.to_json
    end
  end

  def show
    respond_with do
      json @user.to_json
    end
  end

  def create
    factory = Auth::UserFactory.new
    m_user = factory.build(user_params.validate!)

    if m_user.just?
      user = m_user.value!
      result = user.save ? user.to_json : {error: "NOPE"}.to_json
    else
      result = {error: "NOPE"}.to_json
    end

    respond_with do
      json result
    end
  end

  def update
    user.set_attributes user_params.validate!
    result = user.save ? user.to_json : {error: "NOPE"}.to_json
    respond_with do
      json result
    end
  end

  def destroy
    user.destroy
    respond_with do
      json "[]"
    end
  end

  private def user_params
    params.validation do
      required :password { |p| p.size >= 8 }
      required :password_confirmation
      required :email
      required :nickname
    end
  end

  private def set_user
    @user = User.find! params[:id]
  end
end