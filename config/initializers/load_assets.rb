require 'fileutils'

current_dir = Dir::pwd
FileUtils.cp_r(current_dir + '/mydata/out/', current_dir + '/public/')
FileUtils.cp_r(current_dir + '/mydata/download/', current_dir + '/public/')
