require "mysql2"
require 'json'

class DbAccess
  def initialize
    json_data = open('config/db.json') do |io|
      JSON.load(io)
    end

    @client = Mysql2::Client.new(
      :host     => json_data['host'],
      :username => json_data['username'],
      :password => json_data['password'],
      :database => json_data['database']
    )
  end

  def select table_name, column_name_list
    raise "column_name_list is must be ARRAY" unless column_name_list.kind_of?(Array)
    column_name_str = column_name_list.join(',')
    sql = %{ SELECT #{column_name_str} FROM #{table_name} }
    ret = @client.query(sql)
    return ret
  end

  def selectAll table_name
    sql = %{ SELECT * FROM #{table_name} }
    ret = @client.query(sql)
    return ret
  end
end

if $0 == __FILE__
  access = DbAccess.new
  ret = access.select 'sample_data', ['id', 'resource_path', 'resource_name']
  ret.each do |row|
    p row
  end
end
