require 'open-uri'

class FileDownload
  def initialize
    @download_folder = "download/"
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
