require 'fileutils'

current_dir = Dir::pwd
source_out = current_dir + '/mydata/out/'
source_download = current_dir + '/mydata/download/'

if FileTest.exists? source_out
  puts "load_assets rm -rf /public/out"
  if FileTest.exists?(current_dir + '/public/out')
    FileUtils.rm_rf(current_dir + '/public/out')
  end

  puts "load_assets mv /mydata/out/ /public/"
  FileUtils.mv(source_out, current_dir + '/public/')
end

if FileTest.exists? source_download
  puts "load_assets rm -rf /public/download"
  if FileTest.exists?(current_dir + '/public/download')
    FileUtils.rm_rf(current_dir + '/public/download')
  end

  puts "load_assets mv /mydata/download/ /public/"
  FileUtils.mv(source_download, current_dir + '/public/')
end
