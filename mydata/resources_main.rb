# 最新のリソースを取得して更新する
require_relative 'db_access.rb'
require_relative 'file_download.rb'
require_relative 'file_manager.rb'
require 'json'

db_access = DbAccess.new
ret = db_access.select 'sample_data', ['id', 'resource_path', 'resource_name']

resources_id_map = {}
ret.each do |row|
  id = row["id"].to_i
  resource_url = row["resource_path"] + row["resource_name"]
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

# unzip_map.each_pair do |path, unzip_info|
#   print path, ", zip_file_name[", unzip_info["zip_file_name"], "], file_name:[", unzip_info["file_name"], "]\n"
# end

json = unzip_map.to_json
File.open("sample_json.json", mode = "w") {|f|
  f.write(json)
}
