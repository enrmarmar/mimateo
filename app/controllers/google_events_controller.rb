# encoding: UTF-8

class GoogleEventsController < ApplicationController

  def create
    @task = Task.find_by_id(params[:task_id])
    access_denied and return unless @current_user.owns_task?(@task) || @current_user.is_invited_to_task?(@task)
    unless @current_user.has_google_account?
      flash[:warning] = 'Esta función requiere una cuenta de Google'
      redirect_to task_path and return
    end
    if GoogleEvent.where(user_id: @current_user.id, task_id: @task.id).first
      flash[:warning] = "La tarea ya estaba sincronizada con el calendario de Google"
    elsif GoogleEvent.create!(task_id: @task.id, user_id: @current_user.id)
      flash[:notice] = 'La tarea está sincronizada con el calendario de Google'
    else
      flash[:warning] = 'Ha fallado la conexión con el calendario de Google'
    end
    redirect_to task_path @task
  end

  def delete
    @task = Task.find_by_id(params[:task_id])
    access_denied and return unless @current_user.owns_task?(@task) || @current_user.is_invited_to_task?(@task)
    unless @current_user.has_google_account?
      flash[:warning] = 'Esta función requiere una cuenta de Google'
      redirect_to task_path and return
    end
    GoogleEvent.where(user_id: @current_user.id, task_id: @task.id).destroy_all
    flash[:notice] = 'La tarea ya no está sincronizada con el calendario de Google'
    redirect_to task_path @task
  end
end