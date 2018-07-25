class SearchController < ApplicationController
  def card
    ajax_action unless params[:ajax_handler].blank?
    puts "This is not Ajax Action"
  end

  def ajax_action
    if params[:ajax_handler] == 'key_request'
      keyword = params[:card_id]

      $request_keyword = keyword
      list = $ahoCorasick.GetNearStr keyword
      @data = list[0]
      @failure_data = list[1]
      if @data.size > 0
        render
      else
        render json: 'no data'
      end
    end
  end
end
