class TrietreeController < ApplicationController
  $request_keyword =  ""

  def near
    ajax_action unless params[:ajax_handler].blank?
    puts "This is not Ajax Action"
  end

  def ajax_action
    if params[:ajax_handler] == 'key_request'
      keyword = params[:keyword]

      $request_keyword = keyword
      @data = $ahoCorasick.GetNearStr keyword
      if @data.size > 0
        render
      else
        render json: 'no data'
      end
    end
  end
end
