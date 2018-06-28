class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def index
    users_unsorted = User.all
    @users = users_unsorted.sort {|x,y| y.total_team_members <=> x.total_team_members }
  end

  def edit
    @user = User.find(current_user.id)
  end

  def create
    @user = User.new(user_params)
    if @user.valid?
      @user.save
      redirect_to user_path(@user)
    else
      @error_messages = @user.errors.messages
      render :'new.html'
    end
  end

  def update
    @user = current_user
    if params[:user][:nation_name]
      @user.update(nation_name: params[:user][:nation_name].capitalize)
      redirect_to matches_path(id: @user.id, message: "Your nation name was successfully changed.")
    elsif params[:user][:password] && @user.authenticate(params[:user][:current_password])
      @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
      redirect_to matches_path(id: @user.id, message: "Your changes were successfully saved.")
    elsif params[:user][:password] && !@user.authenticate(params[:current_password])
      @message = "That password was incorrect. Please try again."
      render :'edit.html'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private
  def user_params
    params[:user][:user_name].nil? ? (params[:user][:user_name] = User.find(params[:id]).user_name) : nil
    params[:user][:nation_name].capitalize!
    params.require(:user).permit(:user_name, :nation_name, :password, :password_confirmation)
  end
end
