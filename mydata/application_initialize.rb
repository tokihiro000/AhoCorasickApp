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
  attr_accessor :word, :is_root, :node_number, :union_word_set
  def initialize node_count
    @node_number = node_count
    @edge_map = {}
    @word = ""
    @failure_node = nil
    @is_root = false
    @union_word_set = Set.new
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
    puts "initialize"
    @root_node = Node.new $node_count
    $node_count += 1
    @root_node.is_root = true
  end

private
  def createTrie word
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
$ahoCorasick.BuildFromFile 'mydata/number.txt'
# ahoCorasick.PrintTri
# ahoCorasick.Save
# now1 = Time.ne  w;
# p now1
# ahoCorasick.Load
# now2 = Time.new;
# p now2
p $ahoCorasick.Search "100010"
# now3 = Time.new;
# p now3
# ahoCorasick.PrintTri

# STDIN.each_line do |line|
#   input_word = line.chomp
#   print "\nsearch word ---> [", input_word, "]\n"
#   p ahoCorasick.Search input_word
# end
