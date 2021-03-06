class Question < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  belongs_to :user
  has_many :question_comments

  before_save :strip_injection_from_answer

  def published_questions
    question_comments.select(&:published)
  end

  def discret_company_size
    return 2 if answer == 'Entre 11 et 250 personnes' || answer == 'Entre 251 et 5000 personnes'
    return 3 if answer == 'Plus de 5000 personnes'
    1
  end

  MY_WORK_QUESTIONS_IDENTIFIERS =
    %w( how_many_people_in_company solo_vs_team who_do_you_work_with
        foreign_language_mandatory inside_or_outside_work self_time_management
        always_on_the_road manual_or_intellectual ).freeze

  NOT_INTERVIEW_QUESTIONS = MY_WORK_QUESTIONS_IDENTIFIERS + %w( love_job how_fun_was_this_form actually_something_to_add typical_workday qualification_required )

  scope :published, -> { where(questions: { published: true }) }
  scope :first_interview_canonicals, -> {
    where(step: 'first_interview')
      .where(user: nil)
      .order(position: :asc)
  }

  def interview?
    !NOT_INTERVIEW_QUESTIONS.include?(identifier)
  end

  # TODO:
  # pour eviter le n+1 sur la gallerie
  # essayer un includes(:questions).merge(where(questions: {identifier: 'job_title'}))
  # peut etre en 2 temps: 1 recherche des users, 2 récupérations de leurs questions
  def strip_injection_from_answer
    self.answer = sanitize(answer, tags: %w( b i br ul li ))
  end
end
