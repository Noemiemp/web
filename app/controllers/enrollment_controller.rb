class EnrollmentController < ApplicationController

  def index
    @user = User.new
    render layout: 'home'
  end

  def create
    email = params['user']['email']
    EnrollmentMailer.enroll_email(email).deliver_now
    redirect_to enrollment_thanks_path
  end

  def thanks
    render layout: 'home'
  end
end
