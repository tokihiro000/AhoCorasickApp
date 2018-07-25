# 最新のリソースを取得して更新する
require_relative 'db_access.rb'
require_relative 'file_download.rb'
require_relative 'file_manager.rb'
require 'json'
require 'fileutils'

db_access = DbAccess.new
ret = db_access.select 'data_update_manage', ['data_update_manage_id', 'url_path', 'file_name', 'deleted']

resources_id_map = {}
ret.each do |row|
  deleted_flag = row["deleted"].to_i
  next if deleted_flag == 1

  id = row["data_update_manage_id"].to_i
  resource_url = row["url_path"] + '/'+ row["file_name"]
  resources_id_map[id] = resource_url
end

# id 昇順にソート
resources_id_map = resources_id_map.sort

# downloadとunzip
unzip_map = {}
file_download = FileDownload.new
file_manager = FileManager.new
resources_id_map.each do |id, url|
  print id, ": ", url, "\n"
  file_name = file_download.download url
  unzip_map_tmp = file_manager.unzip file_name
  unzip_map_tmp.each_pair do |path, unzip_info|
    unzip_map[path] = unzip_info
  end
end

json = unzip_map.to_json
File.open("mydata/sample_json.json", mode = "w") {|f|
  f.write(json)
}

# 更新日時
if FileTest.exists? "update_time.txt"
  FileUtils.rm_rf("mydata/update_time.txt")
end
File.open("update_time.txt", mode = "w") {|f|
  now = Time.now
  f.write(now)
}
