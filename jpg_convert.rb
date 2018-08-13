workspace_path = "public/card/movie/"
original_path = workspace_path + "original/"
tmp_path = workspace_path + "tmp/"
jpg_list_path = workspace_path + "jpg_list.txt"


File.open(jpg_list_path, mode = "r"){|f|
  f.each_line{|line|
    image_name = line.chomp!
    base_name = File.basename image_name, ".jpg"
    image_path = original_path + image_name
    puts image_path

    command1 = "convert -crop 4980x664+0+0 #{image_path} #{tmp_path + "dest1.jpg"}"
    command2 = "convert -crop 4980x664+0+664 #{image_path} #{tmp_path + "dest2.jpg"}"
    command3 = "convert -crop 4980x664+0+1328 #{image_path} #{tmp_path + "dest3.jpg"}"
    command4 = "convert +append #{tmp_path + "dest1.jpg"} #{tmp_path + "dest2.jpg"} #{tmp_path + "dest3.jpg"} #{workspace_path + base_name + ".jpg"}"
    system(command1)
    system(command2)
    system(command3)
    system(command4)
  }
}

# exec( "echo 'hi'" )
