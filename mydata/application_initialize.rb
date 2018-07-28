require 'json'
require 'csv'
require 'set'

class AhoCorasick
  attr_accessor :enable_failure_search_word_length

  def initialize
    @search_map = {}
    @search_key_list = []
    @search_time_limit = $const_info == nil ? 1.0 : $const_info["SearchTimeLimit"]
    @search_word_count = $const_info == nil ? 10 : $const_info["SearchWordCount"]
    @failure_word_count = $const_info == nil ? 10 : $const_info["FailureWordCount"]
    @enable_failure_search_word_length = $const_info == nil ? 5 : $const_info["EnableFailureSearchWordLength"]
  end

private
  def make
    @search_key_list = @search_map.keys.sort
  end

  def createIndex word, value
    if @search_map.has_key? word
    else
      @search_map[word] = []
    end

    @search_map[word] << value
  end

public
  def BuildFromCsv(file_name)
    json_data = open(file_name) do |io|
      JSON.load(io)
    end

    json_data.each do |resource_path, resource_info|
      resource_info["path"] = resource_path
      resource_name_list = resource_path.split("/")
      str = resource_name_list.last
      createIndex str, resource_info
    end

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
      createIndex str, resource_info
    end

    make
  end

  def GetNearStr target
    search_key_result = @search_key_list.grep(/^#{target}/)
    search_result_size = search_key_result.count
    if search_result_size > @search_word_count
      search_key_result = search_key_result[0, @search_word_count]
    end

    search_result_list = []
    search_key_result.each do |word|
      @search_map[word].each do |value|
        search_result_list << { 'word' => word, 'zip' => value['z'], 'path' => value['path'] }
      end
    end

    failure_result_list = []
    if target.length >= @enable_failure_search_word_length
      first_char = target[0]
      search_key_result = @search_key_list.grep(/.#{target}/)
      if search_result_size > @failure_word_count
        search_key_result = search_key_result[0, @failure_word_count]
      end

      search_key_result.each do |word|
        @search_map[word].each do |value|
          failure_result_list << { 'word' => word, 'zip' => value['z'], 'path' => value['path'] }
        end
      end
    end

    return [search_result_list, failure_result_list]
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
$ahoCorasick.BuildFromResourceJson 'mydata/sample_json.json'

# ahoCorasick.PrintTri
# ahoCorasick.Save
# now1 = Time.ne  w;
# p now1
# ahoCorasick.Load
# now2 = Time.new;
# p now2
p $ahoCorasick.GetNearStr "ui_"
# now3 = Time.new;
# p now3
# ahoCorasick.PrintTri

# STDIN.each_line do |line|
#   input_word = line.chomp
#   print "\nsearch word ---> [", input_word, "]\n"
#   p ahoCorasick.Search input_word
# end
