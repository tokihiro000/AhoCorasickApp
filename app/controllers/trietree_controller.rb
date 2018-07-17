class TrietreeController < ApplicationController
  $request_keyword =  ""

  def download
    path = params[:path]
    filename = params[:filename]
    filetype = params[:filetype]
    file_path = filetype == 'zip' ? 'public/download/' + path : 'public/out/' + path
    send_file(file_path, filename: filename)
  end

  def near
    ajax_action unless params[:ajax_handler].blank?
    puts "This is not Ajax Action"
  end

  def ajax_action
    if params[:ajax_handler] == 'key_request'
      keyword = params[:keyword]

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
