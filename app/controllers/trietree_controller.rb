class TrietreeController < ApplicationController
  $request_keyword =  ""

  def download
    path = params[:path]
    filename = params[:filename]
    filetype = params[:filetype]
    file_path = 'public' + path
    send_file(file_path, filename: filename)
  end

  def near
    ajax_action unless params[:ajax_handler].blank?
    puts "This is not Ajax Action"
  end

  def ajax_action
    if params[:ajax_handler] == 'key_request'
      keyword = params[:keyword]
      search_type = params[:search_type][:category]
      rarity_list = params[:rarity] == nil ? [] : params[:rarity].keys.map {|rarity| rarity.to_i}
      attribute_list = params[:attribute] == nil ? [] : params[:attribute].keys.map {|attribute| attribute.to_i}

      $request_keyword = keyword
      @request_keyword = keyword
      @enable_failure_search_word_length = $ahoCorasick.enable_failure_search_word_length

      if keyword.length == 0
        @data = []
        @failure_data = []
      else
        list = $ahoCorasick.GetNearStr keyword, search_type, rarity_list, attribute_list
        @data = list[0]
        @failure_data = list[1]
      end

      render
    end
  end
end
