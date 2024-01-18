class UsersController < ApplicationController
  def index
    @users = User.all

    search_term = params[:search]
    @users = @users.where("name->>'first' ILIKE ?", "%#{search_term}%") if search_term.present?
  end

  def destroy
    @user = User.find(params[:id])
    gender = @user.gender
    user_creation_day = @user.created_at.to_date

    @user.destroy

    # Find or initialize the DailyRecord for the date when user created
    daily_record = DailyRecord.find_or_initialize_by(date: user_creation_day)

    daily_record.update("#{gender}_count": daily_record["#{gender}_count"].to_i - 1) if daily_record.persisted?
    daily_record.save

    redirect_to users_path, notice: 'User was successfully deleted.'
  end
end
