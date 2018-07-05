require 'fileutils'

current_dir = Dir::pwd
FileUtils.cp_r(current_dir + '/mydata/download/', current_dir + '/public/')
