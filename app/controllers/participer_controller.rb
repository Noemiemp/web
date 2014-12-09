class ParticiperController < ApplicationController

  def index
    @user = User.new(:email => params[:email], :job_title => params[:metier])
    but_exactly_question = Question.new(:identifier => "specifically", :title => "Que faites-vous exactement ?")
    love_job_question = Question.new(:identifier => "love_job", :title => "Au fond, qu'est ce qui fait que vous aimez votre métier ?")
    @user.questions = [but_exactly_question, love_job_question]
  end

  def create
    @user = User.new(user_params)
    @user.password = Devise.friendly_token.first(8)
     if @user.save
       redirect_to :participer_merci_beaucoup
     else
       render 'participer/index'
     end
  end

  private
  def user_params
    params.require(:user).permit(:email, :job_title, :first_name, :keyword_list, :avatar, questions_attributes: [:identifier, :title, :answer])
  end

end
