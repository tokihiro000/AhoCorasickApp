require 'open-uri'

class FileDownload
  def initialize
    current_dir = Dir::pwd
    @download_folder = current_dir + "mydata/download/"
    if FileTest.exists? (@download_folder)
      FileUtils.rm_rf(@download_folder)
    end
    Dir.mkdir(@download_folder)
  end

  def download url
    s = url.split("/")
    file_name = s.last
    file_path = @download_folder + file_name
    open(url) do |file|
      open(file_path, "w+b") do |out|
        out.write(file.read)
      end
    end

    return file_name
  end
end
