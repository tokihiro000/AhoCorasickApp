class TrietreeController < ApplicationController
  def near
    ajax_action unless params[:ajax_handler].blank?
    puts "This is not Ajax Action"
  end

  # def neartext
  #   ajax_action unless params[:ajax_handler].blank?
  #   puts "This is not Ajax Action"
  # end

  def ajax_action
    if params[:ajax_handler] == 'key_request'
      # Ajaxの処理
      puts "ajax_action"
      @data = ['megane', 'hoge']
      if @data.size > 0
        render
      else
        render json: 'no data'
      end
    end
  end
end
