class UsersController < ApplicationController
  def index
    @users = User.all

    search_term = params[:search]
    @users = @users.where("name->>'first' ILIKE ?", "%#{search_term}%") if search_term.present?
  end

  def destroy
    @user = User.find(params[:id])
    gender = @user.gender

    # Find or initialize the DailyRecord for the current date
    daily_record = DailyRecord.find_or_initialize_by(date: Date.today)

    # Decrement the corresponding count in DailyRecord based on the user's gender
    daily_record.update("#{gender}_count": daily_record["#{gender}_count"].to_i - 1) if daily_record.persisted?
    daily_record.save

    @user.destroy

    redirect_to users_path, notice: 'User was successfully deleted.'
  end
end
