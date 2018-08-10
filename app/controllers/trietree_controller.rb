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
    print "current page is ", params[:page], "\n"
    if params[:ajax_handler].blank?

      if $request_keyword == nil
        puts "keyword is nil"
      else
        puts "ajax keyword is nil"
        # print "keyword is ", $request_keyword, "\n"
        # puts @request_keyword
        # search_type = params[:search_type][:category]
        # rarity_list = params[:rarity] == nil ? [] : params[:rarity].keys.map {|rarity| rarity.to_i}
        # attribute_list = params[:attribute] == nil ? [] : params[:attribute].keys.map {|attribute| attribute.to_i}
        # ajax_action params[:page].to_i
      end
    else
      # if params[:ajax_handler] == 'key_request'
        page = params[:page] == nil ? 1 : params[:page].to_i
        if page == 1
          $request_keyword = params[:keyword]
          $search_type = params[:search_type][:category]
          $rarity_list = params[:rarity] == nil ? [] : params[:rarity].keys.map {|rarity| rarity.to_i}
          $attribute_list = params[:attribute] == nil ? [] : params[:attribute].keys.map {|attribute| attribute.to_i}
        end
        ajax_action page
      # end
    end
  end

  def ajax_action current_page
      @request_keyword = $request_keyword
      @enable_failure_search_word_length = $ahoCorasick.enable_failure_search_word_length

      @current_page = current_page
      @max_page = 1

      if $search_type != "all" && @request_keyword.length == 0
        puts "ajax action request_keyword is nil"
        @data = []
        @failure_data = []
      else
        print "ajax action request_keyword is ", @request_keyword, "\n"
        list = $ahoCorasick.GetNearStr @request_keyword, $search_type, $rarity_list, $attribute_list, @current_page
        @data = list[0]
        @failure_data = list[1]
        @max_page = list[2]
      end

      render
    end
end
