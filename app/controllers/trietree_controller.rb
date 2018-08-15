class TrietreeController < ApplicationController
  protect_from_forgery except: :near

  def download
    path = params[:path]
    filename = params[:filename]
    filetype = params[:filetype]
    file_path = 'public' + path
    send_file(file_path, filename: filename)
  end

  def near
    p params
    # print "current page is ", params[:page], "\n"
    if params[:ajax_handler].blank?
    else
      # if params[:ajax_handler] == 'key_request'
        page = params[:page] == nil ? 1 : params[:page].to_i
        # ?keyword=rebekka
        @request_keyword = params[:keyword]
        # ?search_type[category]=all
        @search_type = params[:search_type][:category]
        # ?rarity[3]=true&rarity[4]=true
        @rarity_list = params[:rarity] == nil ? [] : params[:rarity].keys.map {|rarity| rarity.to_i}
        @attribute_list = params[:attribute] == nil ? [] : params[:attribute].keys.map {|attribute| attribute.to_i}
        ajax_action page
      # end
    end
  end

  def ajax_action current_page
      @enable_failure_search_word_length = $ahoCorasick.enable_failure_search_word_length

      @current_page = current_page
      @data = []
      @failure_data = []
      @data3 = []
      @max_page = 1

      if @search_type == "all" || (@request_keyword != nil && @request_keyword.length != 0)
        # print "ajax action request_keyword is ", @request_keyword, "\n"
        list = $ahoCorasick.GetNearStr @request_keyword, @search_type, @rarity_list, @attribute_list, @current_page
        @data = list[0]
        @failure_data = list[1]
        @data3 = list[2]
        @max_page = list[3]
      else
        # puts "ajax action request_keyword is nil(´・ω・)"
      end

      render
    end
end
