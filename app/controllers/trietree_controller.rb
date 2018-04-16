class TrietreeController < ApplicationController
  $request_count = 0

  def near
    ajax_action unless params[:ajax_handler].blank?
    puts "This is not Ajax Action"
  end

  # def neartext
  #   ajax_action unless params[:ajax_handler].blank?
  #   puts "This is not Ajax Action"
  # end

  def ajax_action
    $request_count += 1
    print 'REQUEST COUNT: ', $request_count, "\n"
    if params[:ajax_handler] == 'key_request'
      # Ajaxの処理
      # p params
      @data = ['megane', 'hoge']
      if @data.size > 0
        render
      else
        render json: 'no data'
      end
    end
  end
end
