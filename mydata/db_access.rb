require "mysql2"
require 'json'

class DbAccess
  def initialize
    environment_data = open('mydata/config/env.json') do |io|
      JSON.load(io)
    end

    json_data = open('mydata/config/db.json') do |io|
      JSON.load(io)
    end

    env = environment_data['env']
    @client = Mysql2::Client.new(
      :host     => json_data[env]['host'],
      :username => json_data[env]['username'],
      :password => json_data[env]['password'],
      :database => json_data[env]['database']
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
  ret = access.select 'data_update_manage', ['data_update_manage_id', 'url_path', 'file_name', 'deleted']
  ret.each do |row|
    p row
  end
end
