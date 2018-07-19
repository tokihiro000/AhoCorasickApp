require 'json'
require 'set'

$node_count = 0

class Edge
  attr_accessor :char, :before_node, :next_node

  def initialize char, before_node, next_node
    @char = char
    @before_node = before_node
    @next_node = next_node
  end

  def toHash
    data = {
      'char' => @char,
      'before_node' => @before_node.node_number,
      'next_node' => @next_node.node_number
    }

    return data
  end
end

class Node
  attr_accessor :word, :is_root, :node_number, :union_word_set, :value
  def initialize node_count, value = {}
    @node_number = node_count
    @value = []
    @edge_map = {}
    @word = ""
    @failure_node = nil
    @is_root = false
    @union_word_set = Set.new

    if !value.empty?
      @value << value
    end
  end

  def toHash
    tmp_hash = {}
    @edge_map.each do |key, value|
      tmp_hash[key] = value.toHash
    end

    data = {
      "id" => @node_number,
      "word" => @word,
      "edge" => tmp_hash,
      "is_root" => @is_root,
      "failure_node" => @failure_node ? @failure_node.node_number : 0
    }

    return data
  end

  def addEdge edge
    char = edge.char
    if @edge_map.has_key? char
      return
    end

    @edge_map[char] = edge
  end

  def getEdge char
    if @edge_map.has_key? char
      return @edge_map[char]
    end

    return nil;
  end

  def getEdges
    return @edge_map.values
  end

  def getSortEdges
    return @edge_map.sort{|a,b| a[0].downcase <=> b[0].downcase }.to_h.values
  end

  def LinkFailureNode node
    @failure_node = node
  end

  def failureNode
    return @failure_node
  end

  def printWord
    if @word != ""
      puts @word
    end

    if @edge_map.empty?
      return
    end

    @edge_map.each_value { |edge| edge.next_node.printWord if edge.next_node }
  end

  def printDebug
    print @node_number, ": "
    print "  [edge]:"
    getEdges.each do |edge|
      print edge.char , ", "
    end
    number = @failure_node ? @failure_node.node_number : 0
    print " failure: ", number
    puts ""

    if @edge_map.empty?
      return
    end

    @edge_map.each_value { |edge| edge.next_node.printDebug if edge.next_node }
  end
end

class AhoCorasick
  def initialize
    @root_node = Node.new $node_count
    $node_count += 1
    @root_node.is_root = true

    json_data = open('mydata/config/const.json') do |io|
      JSON.load(io)
    end
    @search_time_limit = json_data == nil ? 1.0 : json_data["SearchTimeLimit"]
    @search_word_count = json_data == nil ? 10 : json_data["SearchWordCount"]
  end

private
  def createTrie word, value = {}
    before_node = @root_node
    word.each_char { |character|
      # 前ノードが次の文字へのエッジを持っているか確認
      edge = before_node.getEdge(character)

      # 持っていればそのままそのノードへ、持っていなければノードとエッジを追加
      if edge != nil
        next_node = edge.next_node
      else
        next_node = Node.new $node_count
        $node_count += 1
        edge = Edge.new character, before_node, next_node
        before_node.addEdge edge
      end

      before_node = next_node
    }

    # 1ワード分終わったのでノードに対象ワードを設定する
    before_node.word = word
    before_node.value << value
  end

  def createFailure
    queue = []
    # ひとまずrootから最初にたどる場所はrootを保存
    @root_node.getEdges.each { |edge|
      edge.next_node.LinkFailureNode @root_node
      queue << edge.next_node
    }

    # ノードの浅い所から探索して失敗時のリンクを貼る
    while queue.length > 0
      node = queue.shift
      edge_list = node.getEdges

      # 葉ノードなら次へ
      next if edge_list.empty?

      edge_list.each do |edge|
        failure_node = node.failureNode
        next_node = edge.next_node
        character = edge.char

        edge2 = nil
        while edge2 == nil
          edge2 = failure_node.getEdge character
          # 探索ノードがルートまで至れば成功失敗関わらず探索終了
          break if failure_node.is_root
          # edge2がnilの場合さらに次の失敗時リンクをたどる
          failure_node = failure_node.failureNode
        end

        # 探索失敗ならルートへリンク、そうでなければ探索結果を保存
        if edge2 == nil
          next_node.LinkFailureNode @root_node
        else
          next_node.LinkFailureNode edge2.next_node
          next_node.union_word_set.add edge2.next_node.word
          edge2.next_node.union_word_set.each { |word| next_node.union_word_set.add word }
        end

        queue << next_node
      end
    end
  end

public
  def Build(*target_word_list)
    target_word_list.each do |word|
      createTrie word
    end

    createFailure
  end

  def BuildFromFile(file_name)
    count = 0
    File.open(file_name) do |file|
      file.each_line do |str|
        count += 1
        if count % 100000 == 0
          print "now_count: ", count, "\n"
        end
        str.chomp!
        createTrie str
      end
    end
    createFailure
  end

  def BuildFromJson(file_name)
    json_data = open(file_name) do |io|
      JSON.load(io)
    end

    count = 0
    json_data.each do |resource_path, resource_info|
      count += 1
      if count % 100000 == 0
        print "now_count: ", count, "\n"
      end

      resource_info["path"] = resource_path
      resource_name_list = resource_path.split("/")
      str = resource_name_list.last
      createTrie str, resource_info
    end

    createFailure
  end

  def PrintTri
    @root_node.printWord
  end

  def PrintDebug
    @root_node.printDebug
  end

  def Save
    hash = {}
    hash[@root_node.node_number] = @root_node.toHash

    queue = @root_node.getEdges
    while queue.length > 0
      edge = queue.shift
      node = edge.next_node
      hash[node.node_number] = node.toHash
      node.getEdges.each { |next_edge| queue << next_edge }
    end

    # str = JSON.pretty_generate(hash)
    open('./text.json', 'w') do |io|
      JSON.dump(hash, io)
    end
  end

  def Load
    json_data = open('./text.json') do |io|
      JSON.load(io)
    end

    tmp_node_map = {}
    json_data["0"]["edge"].each { |char, value|
      next_node_number = value["next_node"]
      next_node = Node.new next_node_number
      tmp_node_map[next_node_number] = next_node

      edge = Edge.new char, @root_node, next_node
      @root_node.addEdge edge
    }
    @root_node.LinkFailureNode nil

    json_data.delete("0")

    json_data.each { |node_number, value|
      node = nil
      if tmp_node_map.has_key? node_number
        node = tmp_node_map[node_number]
      else
        node = Node.new node_number
        tmp_node_map[node_number] = node
      end

      value["edge"].each { |char, edge_value|
        next_node_number = edge_value["next_node"]
        next_node = Node.new next_node_number
        tmp_node_map[next_node_number] = next_node
        edge = Edge.new char, node, next_node
        node.addEdge edge
      }
    }

    json_data.each do |node_number, value|
      target_node = tmp_node_map[node_number]
      failure_node_number = value["failure_node"]
      target_node.word = value["word"] if value["word"].length != 0

      if failure_node_number == 0
        target_node.LinkFailureNode @root_node
      else
        target_node.LinkFailureNode tmp_node_map[failure_node_number]
        target_node.union_word_set.add tmp_node_map[failure_node_number].word
        tmp_node_map[failure_node_number].union_word_set.each { |word|
          target_node.union_word_set.add word
        }
      end
    end
  end

  def GetNearStr target
    search_node = @root_node

    index = 0
    length = target.length
    while index < length
      char = target[index]
      edge = search_node.getEdge char

      if edge == nil
        break
      else
        search_node = edge.next_node
        index += 1
      end
    end

    result_set = Set.new
    failure_set = Set.new
    word = search_node.word
    if word.length != 0
      search_node.value.each do |value|
        result_set.add ({ 'word' => word, 'zip' => value['z'], 'path' => value['path'] })
      end
    end

    failure_edge_list = []
    if search_node.failureNode != nil
      failure_set.add search_node.failureNode.word if search_node.failureNode.word.length != 0
      failure_edge_list = failure_edge_list | search_node.failureNode.getSortEdges
    end

    start_time = Time.now
    word_count = 0
    next_edge_list = search_node.getSortEdges
    while next_edge_list.count != 0
      edge = next_edge_list.shift
      next_node = edge.next_node
      failure_node = next_node.failureNode
      failure_set.add failure_node.word if failure_node.word.length != 0

      seartch_time = Time.now - start_time
      if seartch_time > @search_time_limit
        puts "検索時間タイムアウト"
        break
      end

      # 10個以上単語があるなら下のエッジ優先にする
      tmp_next_edge_list = next_node.getSortEdges
      tmp_edge_count = tmp_next_edge_list.count
      if tmp_edge_count >= @search_word_count
        next_edge_list = tmp_next_edge_list
      else
        tmp_next_edge_list.each do |edge|
          next_edge_list.unshift edge
        end
      end

      edge_count = next_edge_list.count
      index_max = edge_count >= @search_word_count ? @search_word_count : edge_count
      next_edge_list = next_edge_list[0, index_max]
      word = next_node.word
      next if word.length == 0

      word_count += 1
      next_node.value.each do |value|
        result_set.add ({ 'word' => word, 'zip' => value['z'], 'path' => value['path'] })
      end
      break if word_count == @search_word_count
    end

    failure_count = failure_set.size
    if failure_count < 5
      failure_edge_list.each do |failure_edge|
        next_node = failure_edge.next_node
        word = next_node.word
        next if word.length == 0
        failure_count += 1
        failure_set.add word
        break if failure_count == 5
      end
    end

    return [result_set.to_a, failure_set.to_a]
  end

  def Search target
    result_set = Set.new
    search_node = @root_node

    t1 = Time.new
    index = 0
    length = target.length
    while index < length
      char = target[index]
      while true do
        edge = search_node.getEdge char

        # 探索終了
        if search_node.node_number == 0 && edge == nil
          index += 1
          break
        end

        # エッジがないなら探索失敗 -> 失敗時リンクを辿る
        if edge == nil
          search_node = search_node.failureNode
          # result_set.add search_node.word
        else
        # エッジがあるなら探索成功 -> 次のノードへ
          search_node = edge.next_node
          result_set.add search_node.word
          search_node.union_word_set.each { |word| result_set.add word }
          index += 1
          break
        end
      end
    end

    t2 = Time.new
    print "検索時間: ", (t2.usec - t1.usec), "マイクロ秒\n"
    return result_set
  end
end

$ahoCorasick = AhoCorasick.new
# $ahoCorasick.Build 'ab', 'bc', 'bab', 'd', 'abcde'
# $ahoCorasick.BuildFromFile 'mydata/input.txt'
$ahoCorasick.BuildFromJson 'mydata/sample_json.json'

# ahoCorasick.PrintTri
# ahoCorasick.Save
# now1 = Time.ne  w;
# p now1
# ahoCorasick.Load
# now2 = Time.new;
# p now2
p $ahoCorasick.GetNearStr "za"
# now3 = Time.new;
# p now3
# ahoCorasick.PrintTri

# STDIN.each_line do |line|
#   input_word = line.chomp
#   print "\nsearch word ---> [", input_word, "]\n"
#   p ahoCorasick.Search input_word
# end
