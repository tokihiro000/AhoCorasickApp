require 'zip'
require 'fileutils'

class FileManager
  def initialize
    current_dir = Dir::pwd
    @src_folder = current_dir + "/download/"
    @dest_folder = current_dir + "/out/"
    if FileTest.exists? (@dest_folder)
      FileUtils.rm_rf(@dest_folder)
    end
    Dir.mkdir(@dest_folder)
  end

  def unzip zip_file_name
    unzip_path_map = {}
    Zip::File.open(@src_folder + zip_file_name) do |zip|
      zip.each do |entry|
        entry_name_list = entry.name.split("/")
        entry_name_list.delete_at(0)
        file_name = entry_name_list.last
        entry_path = entry_name_list.join("/")
        dir = File.join(@dest_folder, File.dirname(entry_path))
        FileUtils.mkpath(dir)
        target_path = @dest_folder + entry_path
        zip.extract(entry, target_path) { true }
        file_type = File::ftype(target_path)
        if file_type == "file"
          unzip_path_map[entry_path] = {
            'z' => zip_file_name
          }
        end
      end
    end

    return unzip_path_map
  end
end
