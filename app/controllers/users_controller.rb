class UsersController < ApplicationController
  def index
    @users = User.all

    search_term = params[:search]
    @users = @users.where("name->>'first' ILIKE ?", "%#{search_term}%") if search_term.present?
  end

  def destroy
    @user = User.find(params[:id])
    gender = @user.gender

    # Update the corresponding count in DailyRecord based on the user's gender
    DailyRecord.increment_counter("#{gender}_count", Date.today)

    @user.destroy

    redirect_to users_path, notice: 'User was successfully deleted.'
  end
end
