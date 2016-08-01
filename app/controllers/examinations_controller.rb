class ExaminationsController < ApplicationController
  load_and_authorize_resource

  def index
    @subject = Subject.all
    @examination = Examination.new
    @search = current_user.examinations.search params[:q]
    @examinations = @search.result.order(created_at: :desc)
      .page(params[:page]).per Settings.per_page
  end

  def show
    if @examination.start?
      @time_start = Time.now.to_i
      @examination.update_attributes  time_start: @time_start, status: :testing
    else
      @time_start = @examination.time_start
    end
  end

  def create
    @subject = Subject.find examination_params[:subject_id]
    @examination = current_user.examinations.build subject: @subject,
      status: :start
    if @examination.save
      flash[:success] =  t "controllers.exams_controller.create_success"
      redirect_to examinations_path
    else
      flash[:danger] = t "controllers.exams_controller.create_error"
      redirect_to :back
    end
  end

  def update
    @examination.time_end = Time.now.to_i
    if @examination.update_attributes examination_params
      flash.now[:success] = t "controllers.exams_controller.update.success"
      redirect_to examinations_path
    else
      flash.now[:danger] = t "controllers.exams_controller.update.failed"
      redirect_to :back
    end
  end

  private
  def examination_params
    params.require(:examination).permit :user_id, :subject_id, :status,
      results_attributes: [:id, :examination_id, :question_id, :answer_id]
  end
end
