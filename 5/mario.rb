require 'ruby2d'

# Window size
set width: 800, height: 600

player_x = 11
player_y = 11
player_speed = 5
player_jump = false
player_img = Image.new('phaser-dude.png', width: 27, height: 40, z: 10)

map = []

File.open('map.txt', 'r') do |file|
    file.each_line do |line|
      map << line.chomp
    end
  end
  
  tile_size = 50
  
  map.each_with_index do |row, y|
    row.chars.each_with_index do |tile, x|
      if tile == '*'
        Rectangle.new(
          x: x * tile_size,
          y: y * tile_size,
          width: tile_size,
          height: tile_size,
          color: 'green',
          z: 1
        )
      end
    end
  end
  
on :key_held do |event|
    case event.key
    when 'left'
      player_x -= player_speed
    when 'right'
      player_x += player_speed
    when 'up'
      if !player_jump
        player_jump = true
        player_y -= 100
      end
    end
  end
  
  update do
    player_y += player_speed
  
    player_bottom = player_y + player_img.height
    player_left = player_x
    player_right = player_x + player_img.width
    map_x = player_x / tile_size
    map_y_bottom = player_bottom / tile_size
    map_y_top = player_y / tile_size
  
    # Ensure player position is within map boundaries
    map_x = [map_x, map[0].size - 1].min
    map_y_bottom = [map_y_bottom, map.size - 1].min
    map_y_top = [map_y_top, map.size - 1].min
  
    if map_y_bottom >= 0 && map[map_y_bottom][map_x] == '*'
      player_jump = false
      player_y = map_y_bottom * tile_size - player_img.height
    end
  
    if map_y_top >= 0 && map[map_y_top][map_x] == '*'
      player_y = (map_y_top + 1) * tile_size
    end
  
  
    # Check fall out of map
    if player_y > (Window.height - player_img.height)
      close # End the game
    end
  
    player_img.x = player_x
    player_img.y = player_y
  end
  
  # Show window
  show