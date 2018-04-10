class HelloController < ApplicationController
  def index
    # ahoCorasick = AhoCorasick.new
    $ahoCorasick.PrintTri
  end
end
