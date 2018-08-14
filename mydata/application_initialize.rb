require 'json'
require 'csv'
require 'set'
require 'nkf'
require 'fileutils'

class AhoCorasick
  attr_accessor :enable_failure_search_word_length, :rarity_set, :attribute_set

  def initialize
    @search_map = {}
    @crown_name_map = {}
    @rarity_set = Set.new
    @attribute_set = Set.new
    @search_key_list = []
    @crown_key_list = []
    @search_time_limit = $const_info == nil ? 1.0 : $const_info["SearchTimeLimit"]
    @search_word_count = $const_info == nil ? 10 : $const_info["SearchWordCount"]
    @enable_failure_search_word_length = $const_info == nil ? 5 : $const_info["EnableFailureSearchWordLength"]
  end

private
  def make
    @search_key_list = @search_map.keys.sort
    @crown_key_list = @crown_name_map.keys.sort
  end

  def createIndex map, word, value
    if map.has_key? word
    else
      map[word] = []
    end

    map[word] << value
  end

public
  def getAttributeStr attribute
    attribute_str = 'Unknown'
    case attribute
    when 1 then
      attribute_str = '虎'
    when 2 then
      attribute_str = '龍'
    when 3 then
      attribute_str = '鳳'
    end

    return attribute_str
  end

  def getRarityStr rarity
    rarity_str = 'Unknown'
    case rarity
    when 1 then
      rarity_str = 'ノーマル'
    when 2 then
      rarity_str = 'ハイノーマル'
    when 3 then
      rarity_str = 'レア'
    when 4 then
      rarity_str = 'ハイレア'
    when 5 then
      rarity_str = 'Sレア'
    when 6 then
      rarity_str = 'SSレア'
    when 7 then
      rarity_str = 'レジェンド'
    when 8 then
      rarity_str = 'Sレジェンド'
    end
    return rarity_str
  end

  def BuildFromCsv(file_name)
    movie_image_map = {}
    image_path = '/card/large/' + file_name
    File.open("./mydata/csv/movie_card_list.txt", mode = "r"){|f|
      f.each_line{|line|
        card_id = line.chomp!
        image_path = "/card/movie/" + card_id + ".jpg"
        movie_image_map[card_id] = image_path
      }
    }

    csv_data = CSV.read(file_name, headers: true)
    csv_data.each do |data|
      name = data["name"]
      if name == nil
        next
      end

      # 空白は検索の邪魔なので削除
      name = name.gsub(" ", "")
      # 半角カナは恐ろしいほど検索しにくいので全角に(UTF-8前提のコード)
      name = NKF.nkf("-Xw", name)
      # 冠名があれば抜き出して別保存
      crown = "no name"
      card_name = name
      name.gsub(/【(.*?)】(.+)/) { |match|
        crown = $1
      }
      name.gsub(/\[(.*?)\](.+)/) { |match|
        crown = $1
      }

      # 画像パス。存在チェックもやります(´・ω・)
      card_id = data["card_id"]
      file_name = card_id + '.jpg'
      image_path = '/card/large/' + file_name
      if !FileTest.exists? ('public' + image_path)
        next
      end
      image_path_small = '/card/small/' + file_name
      if !FileTest.exists? ('public' + image_path_small)
        next
      end

      if crown != "no name"
        createIndex @crown_name_map, crown, card_name
      end

      # レアリティ
      rarity = data["rarity"] == nil ? 0 : data["rarity"].to_i
      @rarity_set.add rarity

      # 属性
      attribute = data["attribute"] == nil ? 0 : data["attribute"].to_i
      @attribute_set.add attribute

      movie_flg = false
      if movie_image_map.has_key? card_id
        image_path_small = movie_image_map[card_id]
        movie_flg = true
      end

      value = {
        'path' => image_path,
        'small_path' => image_path_small,
        'file_name' => file_name,
        'crown' => crown,
        'rarity' => rarity,
        'attribute' => attribute,
        'text' => data["card_text"],
        'movie_flg' => movie_flg
      }
      createIndex @search_map, card_name, value
    end

    @rarity_set.delete 0
    @attribute_set.delete 0
    make
  end

  def BuildFromResourceJson(file_name)
    json_data = open(file_name) do |io|
      JSON.load(io)
    end

    json_data.each do |resource_path, resource_info|
      resource_info["path"] = resource_path
      resource_name_list = resource_path.split("/")
      str = resource_name_list.last
      createIndex @search_map, str, resource_info
    end

    make
  end

  def GetNearStr target, search_type, rarity_list, attribute_list, target_page
    if target != nil && target.length != 0
      target = target.gsub(/\[/, "\\\[")
      target = target.gsub(/\]/, "\\\]")
    end

    search_key_result = []
    if search_type == "all"
      search_key_result = @search_key_list
    elsif search_type == "card_name"
      search_key_result = @search_key_list.grep(/#{target}/)
    else
      crown_name_result = @crown_key_list.grep(/#{target}/)
      crown_name_result.each do |crown|
        @crown_name_map[crown].each do |search_key|
          search_key_result << search_key
        end
      end
    end

    word_list = []
    search_key_result.each do |word|
      @search_map[word].each do |value|
        rarity = value['rarity']
        if (!rarity_list.empty?) && (!rarity_list.include? rarity)
          next
        end

        attribute = value['attribute']
        if (!attribute_list.empty?) && (!attribute_list.include? attribute)
          next
        end

        word_list << word
      end
    end


    list_size = word_list.count
    max_page =  (list_size / @search_word_count) + 1
    if list_size > @search_word_count
      index = ((target_page - 1) * @search_word_count) + 1
      count = [list_size - index, @search_word_count].min
      word_list = word_list[index, count]
    end

    count = 0
    search_result_list_1 = []
    search_result_list_2 = []
    search_result_list_3 = []
    word_list.each do |word|
      store_list = search_result_list_1
      case_value = count % 3
      case case_value
      when 0 then
      when 1 then
        store_list = search_result_list_2
      when 2 then
        store_list = search_result_list_3
      else
        # どの値にも一致しない場合に行う処理
        store_list = search_result_list_1
      end

      count += 1
      @search_map[word].each do |value|
        rarity = value['rarity']
        if (!rarity_list.empty?) && (!rarity_list.include? rarity)
          next
        end

        attribute = value['attribute']
        if (!attribute_list.empty?) && (!attribute_list.include? attribute)
          next
        end

        store_list << {
          'word' => word,
          'file_name' => value['file_name'],
          'crown' => value['crown'],
          'path' => value['path'],
          'small_path' => value['small_path'],
          'rarity' => rarity,
          'attribute' => attribute,
          'text' => value['text'],
          'movie_flg' => value['movie_flg']
        }
      end
    end

    return [search_result_list_1, search_result_list_2, search_result_list_3, max_page]
  end
end

$update_time = "未確認"
File.open('mydata/update_time.txt') do |file|
  file.each_line do |str|
    str.chomp!
    $update_time = str
  end
end

$env_info = open('mydata/config/env.json') do |io|
  JSON.load(io)
end

$const_info = open('mydata/config/const.json') do |io|
  JSON.load(io)
end


$ahoCorasick = AhoCorasick.new
# $ahoCorasick.Build 'ab', 'bc', 'bab', 'd', 'abcde'
# $ahoCorasick.BuildFromFile 'mydata/input.txt'
# $ahoCorasick.BuildFromResourceJson 'mydata/sample_json.json'
$ahoCorasick.BuildFromCsv 'mydata/csv/Card_master.csv'

# ahoCorasick.PrintTri
# ahoCorasick.Save
# now1 = Time.ne  w;
# p now1
# ahoCorasick.Load
# now2 = Time.new;
# p now2
# p $ahoCorasick.GetNearStr "ui_"
# now3 = Time.new;
# p now3
# ahoCorasick.PrintTri

# STDIN.each_line do |line|
#   input_word = line.chomp
#   print "\nsearch word ---> [", input_word, "]\n"
#   p ahoCorasick.Search input_word
# end
