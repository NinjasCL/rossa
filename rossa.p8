pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- profesor rossa
-- ninjas.cl
-- camilo castro
-- 2017

-- system constants and tables
debug = false
max_integer = 32767
bitmap_unit = 8 -- pixels

colors = {
	black = 0,
	dark_blue = 1,
	dark_purple = 2,
	dark_green = 3,
	brown = 4,
	dark_gray = 5,
	light_gray = 6,
	white = 7,
	red = 8,
	orange = 9,
	yellow = 10,
	green = 11,
	blue = 12,
	indigo = 13,
	pink = 14,
	peach = 15
}

buttons = {
	left = 0,
	right = 1,
	up = 2,
	down = 3,
	a = 4,
	b = 5
}

screen = {
 width = 128,
 height = 128
}

-- game related tables
game = {
 frames = 0,
 update = {},
 state = 0,
 states = {
 	menu = 0,
 	menu_idle = 1,
 	play = 2,
 	play_idle = 3,
 	play_start = 4,
 	play_end = 5,
 	over = 6,
 	over_idle = 7,
 	idle = 8
 },
 fps = 30,
 sfxs = {
 	click = 0,
 	throw = 5,
 	hurt = 6,
 	item = 7,
 	walk = 9,
 	life_up = 10,
 	item_gold = 11
 },
 songs = {
 	intro = 0,
 	level_start = 3,
 	game_over = 4
 },
 time = {
 	init = time(),
 	seconds = 0
 },
 difficulty = {
 		lives = 3,
 		speed = 1.5
 },
 max_score = max_integer
}

game.time.frame_counter = 0

game.time.wait = 
function (seconds)

	if game.frames <= 0 then
		return false
	end
	
	game.time.frame_counter = 
		game.time.frame_counter 
																	or 0
																	
	seconds = flr(seconds) or 1
		
	local wait = game.fps * seconds
	
	if game.time.frame_counter
	 <= wait then
		game.time.frame_counter = 
			game.time.frame_counter + 1
	else
		game.time.frame_counter = 0
	end
	

	return (
		game.time.frame_counter % 
		wait == 0)
end

game.update.seconds = 
function () 

	game.time.seconds = 
			game.time.seconds or 0
	
 game.time.seconds = 
 		flr(time() - 
			game.time.init)
 
 return game.time.seconds
 
end

game.update.frames = 
function ()

	game.frames = game.frames or 0
	
 if game.frames <
 		 max_integer then
     game.frames = game.frames + 1
 else 
     game.frames = 0
 end
 
 return game.frames
 
end

-- useful for creating an 
-- animation
-- every n frame
game.is_frame = 
function (frame)
    frame = flr(frame) or 4
    return (game.frames % 
    		(frame * 2) < frame)
end

-- audio helper table

audio = {}

audio.sfx = nil
audio.sfx2 = nil
audio.sfx3 = nil
audio.music = nil

audio.channels = {}
audio.channels.sfx = 1
audio.channels.sfx2 = 2
audio.channels.sfx3 = 3
audio.channels.music = 0

audio.mute = {}
audio.play = {}

audio.mute.sfx = 
function (channel)
  channel = channel or 
  		audio.channels.sfx or 2
  sfx(-1, channel)
end

audio.mute.sfx2 = 
function ()
	audio.mute.sfx(
			audio.channels.sfx2)
end

audio.mute.sfx3 =
function ()
	audio.mute.sfx(
			audio.channels.sfx3)
end

audio.mute.music =
function (channel)
 channel = channel or 
 		audio.channels.music or 0
 music(-1, channel)
end

audio.play.sfx =
function (channel)
 channel = channel or 
 		audio.channels.sfx or 1
 
 if audio.sfx then
   sfx(audio.sfx, channel)
   audio.sfx = nil
 end
end

audio.play.sfx2 =
function (channel)
 channel = channel or 
 		audio.channels.sfx2 or 2
 
 if audio.sfx2 then
   sfx(audio.sfx2, channel)
   audio.sfx2 = nil
 end
end

audio.play.sfx3 =
function (channel)
 channel = channel or 
 		audio.channels.sfx3 or 3
 
 if audio.sfx3 then
   sfx(audio.sfx3, channel)
   audio.sfx3 = nil
 end
end

audio.play.music =
function (channel)
 
 channel = channel or 
 	audio.channels.music or 0
 	
 if audio.music then
   music(audio.music, channel)
   audio.music = nil
 end
end


-- utility functions
utils = {}
utils.rand = 
function (n)
  return flr(rnd(n))
end

-- math
-- https://www.youtube.com/watch?v=nzhzgxfkfuy
-- https://github.com/cauli/picobox/blob/master/collisions.p8

utils.range_intersect =
function (min0, max0, 
										min1, max1)

	return max(min0, max0)
	>= min(min1, max1) and
	min(min0,max0) <= 
	max(min1,max1)
	
end

utils.collide =
function (rect1, rect2)
			
	local min0x = flr(rect1.x)

	local max0x = 
		flr(rect1.x + rect1.width)
	
		
	local min1x = flr(rect2.x)
	
	local max1x = 
		flr(rect2.x + rect2.width)
	
	
	local min0y = flr(rect1.y)
	
	local max0y =
		flr(rect1.y + rect1.height)
	
		
	local min1y = flr(rect2.y)
	
	local max1y =
		flr(rect2.y + rect2.height)
	
	
	return utils.range_intersect(
		min0x, max0x, min1x, max1x) 
		
		and utils.range_intersect(
		min0y, max0y, min1y, max1y)
end

utils.hitbox =
function (x1,y1,x2,y2)
	
	local object = {
		x = x1,
		y = y1,
		width = x2,
	 height = y2
	}
	
	object.draw = 
		function (clr)
			
			clr = clr or colors.red
			
			if debug then
				rect(object.x,
					object.y,
					object.x + object.width,
					object.y + object.height,
					clr
					)
			end
			
		end
	
	return object
	
end

-- gameplay tables

player = {
	lives = game.difficulty.lives,
	score = 0,
	offset = 0,
	sprites = {},
	title = "",
	id = 0,
	
	rossa = {
			right = 64,
			right2 = 65,
			left = 66,
			left2 = 67,
			idle = 68,
			title = "rossa",
			offset = 0,
			id = 0
	},
	
	guru = {
			right = 179,
			right2 = 180,
			left = 181,
			left2 = 182,
			idle = 183,
			title = "guru guru",
			offset = 8,
			id = 1
	},
	
	carter = {
			right = 163,
			right2 = 164,
			left = 165,
			left2 = 166,
			idle = 167,
			title = "don carter",
			offset = 8,
			id = 2
	},
	
	pos = {
		x = 40,
		y = 100
	},
	
	hitbox = 
			utils.hitbox(0,0,0,0),
	
	state = 0,
	
	states = {
		idle = 0,
		left = 1,
		right = 2,
		hurt = 3,
		dead = 4,
		item = 5,
		hurt_left = 6,
		hurt_right = 7
	}
}

player.sprites = player.rossa

player.title = 
	player.rossa.title

player.hurt_time = 0

player.is_hurt = 
function ()
	return 
				player.state == 
					player.states.hurt or
				player.state ==
					player.states.hurt_left or
				player.state ==
					player.states.hurt_right or
				player.hurt_time > 0
end

player.change_lives =
function (increment)
	
	increment = increment or 1
	
	player.lives =
		player.lives + increment
end

player.life_up =
function ()
	player.change_lives(1)
	audio.sfx2 = game.sfxs.life_up
end

player.life_down =
function ()
	player.change_lives(-1)
end

player.draw = 
function ()
	
	local sprite = 
		player.sprites.idle
		
	local frame = 4
	
	local x = player.pos.x
	local y = player.pos.y

	if player.state == nil then
		player.state = 
			player.states.idle
	end

	
	if player.is_hurt() then
		
			if game.time.wait(1) then
				
				player.hurt_time =
					player.hurt_time + 1
					
			end
			
			if player.hurt_time >= 2 then
				
				player.state = 
					player.states.idle
					
					player.hurt_time = 0
			end
			
	else
			player.state = 
				player.states.idle
			
			player.hurt_time = 0
	end
	
	if btnp(buttons.left)
		or btnp(buttons.right)
		or btnp(buttons.a)
		or btnp(buttons.b)
		or btnp(buttons.up)
		or btnp(buttons.down)
		 then
				audio.sfx = game.sfxs.walk
	end
	
	
	if btn(buttons.left) 
	or btn(buttons.b) 
	or btn(buttons.down)then
			
			if player.is_hurt() then
				player.state =
					player.states.hurt_left
			else
				player.state = 
					player.states.left
			end
			
			sprite = 
				player.sprites.left
				
			if game.is_frame(frame) then
				sprite = 
					player.sprites.left2
			end
			
			player.pos.x = 
				player.pos.x -
				game.difficulty.speed
						
			-- check collision left
			-- give 4 pixel more allowed
			player.pos.x = max(-4, player.pos.x)
			
	end
	
	if btn(buttons.right) 
	or btn(buttons.a) 
	or btn(buttons.up) then
	
			if player.is_hurt() then
				player.state =
					player.states.hurt_right
			else
				player.state = 
					player.states.right
			end
		
			sprite = 
				player.sprites.right
				
			if game.is_frame(frame) then
				sprite = 
					player.sprites.right2
			end
			
			player.pos.x = 
				player.pos.x +
				game.difficulty.speed
			
			-- check collision right
			-- give 4 pixel more allowed
			player.pos.x = min(
											screen.width - bitmap_unit + 4, 
											player.pos.x)
	end
	
	player.hitbox = 	
		utils.hitbox(
			x, 
			y,
			bitmap_unit - 2,
			bitmap_unit - 1
		)
		
	player.hitbox.draw()
	
	
	if debug then
		print("player pos x "..
		player.pos.x, 60, 20, 
		colors.yellow)
		
		print("player pos y "..
		player.pos.y, 60, 30, 
		colors.yellow)
		
	 print("player width "..
		player.hitbox.width, 60, 40, 
		colors.yellow)
		
		print("player height "..
		player.hitbox.height, 60, 50, 
		colors.yellow)
		
		print("player state " ..
		player.state, 60, 60,
		colors.yellow)
	end
						
	spr(sprite, x, y)
			
end

gameplay = {}

gameplay.lifebar = {
		sprites = {
			heart = 18
		}
}

gameplay.lifebar.draw = 
function()

	local bar_height = 12
	local bar_width = screen.width
	
	rectfill(0,0, 
		bar_width,
		bar_height,
		colors.dark_blue
		)
	
	local heart = 
		gameplay.lifebar.sprites.heart
		
	local heart_x = 10
	local heart_y = 2
	local space = 2
	
	if player.lives >= max_integer 
				then
				player.lives = max_integer
	end
	
	if player.lives > 0 then
		spr(heart, heart_x, heart_y)
	end
	
	if player.lives > 1 then
		spr(heart, 
			heart_x 
			+ bitmap_unit
			+ space, 
			heart_y)
	end			
	
	if player.lives > 2 then
		spr(heart,
		heart_x
		+ bitmap_unit * 2
		+ space * 2,
		heart_y
		)
	end
	
	print(player.title, 40, 
							heart_y + 1, 
							colors.white)
	
	if player.score >= 
				game.max_score then
		player.score = game.max_score
	end
	
	print("score "..player.score,
	85,
	heart_y + 1,
	colors.pink
	)
	
end

entities = {}
entities.items = {}

entities.type = {
	item = 0,
	fire = 1
}

entities.destroy =
function (item)
	del(entities.items,
		item)
end

entities.vhs = {}

entities.vhs.counter = 0


entities.vhs.last = nil

entities.vhs.showing_score = 
																			false

entities.vhs.show_score =
function ()

	if entities.vhs.showing_score
	and entities.vhs.last != nil 
	then
		
		print(entities.vhs.last.score, 
					player.pos.x,
					player.pos.y - 20,
					colors.white)
					
		if game.time.wait(1) then
			entities.vhs.showing_score =
						 false
	 end
	 
 end


end

entities.vhs.new = 
function ()
local object = {
		type = entities.type.item,
		pos = {
			x = 0,
			y = -10
		},
		speed = {
			x = 0,
			y = 1.5
		},
		hitbox = 
			utils.hitbox(0,0,0,0),
			
		sprite = 0,
		score = 0,
		sfx = game.sfxs.item,
		
		normal = {
			sprite = 86,
			score = 50,
			sfx = game.sfxs.item
		},
		
		gold = {
			sprite = 87,
			score = 100,
			sfx = game.sfxs.item_gold
		}
	}
	
	object.sprite = 
	object.normal.sprite
		
	object.score = 
			object.normal.score
			
	object.sfx = 
			object.normal.sfx
			
	if utils.rand(
					1000) % 7 == 0 then
			
			object.sprite = 
				object.gold.sprite
			
			object.score = 
				object.gold.score
				
			object.sfx =
				object.gold.sfx
				
	end
	
	object.draw = 
	function ()
		
		object.hitbox = 
		 		utils.hitbox(
		 			object.pos.x,
		 			object.pos.y,
		 			 
		 			bitmap_unit,
		 			bitmap_unit
		 		)
		
		if object.pos.y <
		 screen.height then
		 
				spr(object.sprite,
				object.pos.x,
				object.pos.y)
				
				object.hitbox.draw(
					colors.pink
				)
				
				if debug then
					print("vhs pos x "..
					object.pos.x, 0, 20, 
					colors.white)
					
					print("vhs pos y "..
					object.pos.y, 0, 30, 
					colors.white)
					
				 print("vhs width "..
					object.hitbox.width, 0, 40, 
					colors.white)
					
					print("vhs height "..
					object.hitbox.width, 0, 50, 
					colors.white)
				end				
		else
		  entities.destroy(object)
		  entities.vhs.counter = 
		  	entities.vhs.counter - 1
		end
		
	end
		
	object.check_collision =
		function ()
				 							 
				if utils.collide(
													player.hitbox,
													object.hitbox) 
							then
					
						if debug then
							print("colission vhs"
								,0,117,
								colors.yellow)
						end
						
						audio.sfx3 = 
							object.sfx
							
						player.score = 
							player.score + 
							object.score
						

						entities.vhs.showing_score = true
						entities.vhs.last = object
											
						entities.destroy(object)
						entities.vhs.counter =
							entities.vhs.counter - 1
				end
				
				
		end
	
	return object
	
end


entities.vhs.create =
function ()
	
	local obj = entities.vhs.new()
	
	obj.pos.x = utils.rand(
		screen.width - bitmap_unit)
	 		
	add(entities.items, obj)
	
	entities.vhs.counter = 
		entities.vhs.counter + 1
	
	return obj
	 
end

entities.fire = {}
entities.fire.new = 
function ()
	local object = {
		type = entities.type.fire,
		pos = {
			x = 0,
			y = 0
		},
		speed = {
			x = 0,
			y = game.difficulty.speed
		},
		hitbox = {},
		
		sprites = {
			h = 84,
			v = 83
		}
	}
	
	object.draw = 
	function ()
		
		if object.pos.y <
		 screen.height then
		 
		 	local sprite =
		 		object.sprites.h
		 	
		 	if game.is_frame(4) then
		 		sprite = 
		 			object.sprites.v
		 	end
		 	
		 	object.hitbox = 
		 		utils.hitbox(
		 			object.pos.x + 1,
		 			object.pos.y + 1,
		 		 
		 			bitmap_unit / 2, 
		 			bitmap_unit - 3
		 		)
	 	
				spr(sprite,
				object.pos.x,
				object.pos.y)
				
				object.hitbox.draw(
					colors.yellow
				)
						
				else
				  entities.destroy(object)
				end
		
	end
	
	object.check_collision =
		function ()
				
				
				if utils.collide(
					player.hitbox,
					object.hitbox) and
					not player.is_hurt() then
					
						if debug then
							print("colission fire"
								,0,117,
								colors.red)
						end
						
						audio.sfx2 = 
							game.sfxs.hurt
						
						player.life_down()
						
						player.state =
							player.states.hurt
					
						entities.destroy(object)
						
				end
				
		end
	
	return object
	
end

entities.fire.create =
function ()
	
	local obj = entities.fire.new()
	
	obj.pos.x = utils.rand(
		screen.width - bitmap_unit)
			
	add(entities.items, obj)
	 
end

gameplay.stages = {
	level1 = {
		id = 0,
		max_items = 20,
		max_vhs = 1
	}
}

gameplay.draw_items =
function (level)
	
	level = level or 
		gameplay.stages.level1
	
	for i = #entities.items,
		level.max_items do
			entities.fire.create()
	end
	
	for i = entities.vhs.counter,
		level.max_vhs - 1 do

			entities.vhs.create()
		
	end
	
	for item 
		in all(entities.items) do
		
			item.pos.y =  
				item.pos.y + item.speed.y
			
			item.draw()
			item.check_collision()
			
	end
	
	entities.vhs.show_score()
	
end

gameplay.score = {}
gameplay.score.step = 1
gameplay.score.limit = 250

gameplay.score.check = 
function ()

	-- give life every 250 points
			
	if flr(player.score) >= 
	gameplay.score.step * 
	gameplay.score.limit 
	then
		
		gameplay.score.step =
			gameplay.score.step + 1
			
		player.life_up()
		
		game.difficulty.speed =
			game.difficulty.speed + 0.02
	end
	
end

-- level 1

gameplay.stages.level1.draw =
function ()

	-- sky
	rectfill(0, 0, 
									screen.width, 
									screen.height,
				 				colors.blue)

	-- paisaje lindo
	
	-- map(celx, cely, posx, 
	-- posy, wide, tall)
	
	-- background
	map(0,4,0,90,16,5)
	
	-- background animation
	if game.is_frame(15) then
		map(6,2,104,90,2,2)
	end
	
	-- smoke
	map(13,2,104,75,2,2)
	
	if game.is_frame(15) then
		map(10,2,104,75,3,2)
	end
	
	player.pos.y = 120	
	player.draw()
				
	gameplay.draw_items(
		gameplay.stages.level1)
	
	gameplay.score.check()
end

gameplay.draw = 
function ()

	if game.state == 
			game.states.play then
		
		audio.mute.music()
		
		game.state = 
			game.states.play_idle
						
		audio.music = 
					game.songs.level_start		
	end
	
	if game.state ==
		game.states.play_idle then
			
		print(player.title .. 
				" start!", 
				40 - player.offset, 60, 
				colors.pink)
		
		if game.time.wait(2) then
				game.state = 
						game.states.play_start
		end
		
	end
	
	if game.state ==
		game.states.play_start then
		
		audio.mute.music()
		
		if gameplay.stage == 
		gameplay.stages.level1.id then
			gameplay.stages.level1.draw()
		end
		
		gameplay.lifebar.draw()
		
		if player.lives < 0 then
			game.state = game.states.over
		end
		
		if debug then
			print("speed " ..
				game.difficulty.speed,
				0,60, colors.orange)
		end
		
	end
	
end

gameover = {
  continue = false
}

gameover.draw = 
function ()

	if game.state ==
		game.states.over then
		
		audio.mute.music()
		
		audio.music = 
			game.songs.game_over
		
		game.state = 
			game.states.over_idle
	end
	
	if game.state ==
		game.states.over_idle then
		
		-- restart
		
		if game.time.wait(3) then
				gameover.continue = true
		end
		
		if gameover.continue then
				if btn(buttons.a)
				or btn(buttons.b)
				or btn(buttons.left)
				or btn(buttons.right)
				or btn(buttons.up)
				or btn(buttons.down)
				then
				  gameover.continue = false
					_init()
				end
		end
		
		-- 15 seconds to restart
		-- if no input is given
		if game.time.wait(15) then
		  gameover.continue = false
		  _init()
		end
		
		local x = 50
		local y = 30
		
		print("game over",x, y, 
		colors.pink)
		
		-- carter			
		local image = {
			celx = 59,
			cely = 2,
			x = x,
			y = y + 10,
			wide = 4,
			tall = 3
			}
			
	
		if game.is_frame(15) then
			image.y = image.y + 2
			image.celx = 69
		end
		
		-- rossa
		if player.id ==
			player.rossa.id then
				image.celx = 64
				
				if game.is_frame(15) then
					image.celx = 69
					image.cely = 5
				end
		end
		
		if player.id ==
			player.guru.id then
			image.celx = 59
			image.cely = 5
			
			if game.is_frame(15) then
				image.celx = 64
			end
		end
		
		map(image.celx,
						image.cely,
						image.x,
						image.y,
						image.wide,
						image.tall
					)
		
		print("score ".. 
			player.score,x ,y + 40, 
			colors.yellow)
		
		--print("press 'z' to restart",
		--x - 20, y + 70, colors.white)
			
	end
end

menu = {}

menu.logo = {}
menu.logo.pos = {
	x = 25,
	y = 20,
	wide = 10,
	tall = 6,
	map_x = 74,
	map_y = 1
}

menu.logo.draw =
function (x, y)
	
	x = x or menu.logo.pos.x or 0
	y = y or menu.logo.pos.y or 0
	
	menu.logo.pos.total_x = x + 
										menu.logo.pos.wide
										
	menu.logo.pos.total_y = y + 
										bitmap_unit * 
										(menu.logo.pos.tall +
										 menu.logo.pos.map_y)
	
	map(menu.logo.pos.map_x, 
					menu.logo.pos.map_y, 
					x, y, 
					menu.logo.pos.wide, 
					menu.logo.pos.tall)
end

menu.pointer =
{
	sprite = 2,
	pos = {
		x = 0,
		y = 0
	},
	state = 0,
	states = {
		rossa = 0,
		guru = 1,
		carter = 2
	}
}

menu.options = {}
menu.options.draw = 
function ()

	local pointer = menu.pointer
	local x = pointer.pos.x
	local y = pointer.pos.y
	
	local colour = colors.white
	local colour2 = colors.white
	local colour3 = colors.white
	
	local states = pointer.states
	
	local state = pointer.state
					or states.rossa
	
	if btnp(buttons.up) or btnp(buttons.left) then
	
		audio.sfx = game.sfxs.click
		
		if state == 
			states.rossa then
			pointer.state =
				states.carter
		end
		
		if state ==
			states.guru then
			pointer.state =
				states.rossa
		end
		
		if state ==
			states.carter then
				pointer.state =
					states.guru
		end
	end
	
	if btnp(buttons.down) or btnp(buttons.right) then
	
		audio.sfx = game.sfxs.click
		
		if state == 
			states.rossa then
			pointer.state =
				states.guru
		end
		
		if state ==
			states.guru then
			pointer.state =
				states.carter
		end
		
		if state ==
			states.carter then
				pointer.state =
					states.rossa
		end
	end
	
	x = 40
	y = 80
	
	if state ==
		states.rossa then
		
		colour = colors.pink
		
		player.sprites = 
			player.rossa
			
		player.title = 
			player.rossa.title
			
		player.offset =
			player.rossa.offset
		
		player.id =
			player.rossa.id
	end
		
	if state ==
		states.guru then
		
		y = y + 10
		colour2 = colors.pink
		
		player.sprites =
			player.guru
		
		player.title =
			player.guru.title
			
		player.offset =
			player.guru.offset
		
		player.id =
			player.guru.id
	end
	
	if state ==
		states.carter then
		
		y = y + 20
		colour3 = colors.pink
		
		player.sprites = 
			player.carter
		
		player.title = 
			player.carter.title
			
		player.offset = 
			player.carter.offset
			
		player.id = 
			player.carter.id
	end
	
	spr(pointer.sprite,x,y)
	
	print("rossa", 50, 80, 
						colour)	

 print("guru guru", 50, 90,
 				 colour2)
 				 
 print("don carter", 50, 100, 
 					colour3)
 
end

menu.draw = 
function ()
	
	if game.state == 
		game.states.menu then
		
		audio.mute.music()
		
		audio.music = game.songs.intro

		game.state = 
				game.states.menu_idle
	end
	
	if game.state == 
	game.states.menu_idle then
		
		menu.logo.draw()
		
		menu.options.draw()
		
		--print("press 'z' to play",
		--	menu.logo.pos.x + 5,
		--	menu.logo.pos.y - 15,
		--	colors.pink)
			
		print("♥2017 ✽ninjas.cl",
			menu.logo.pos.x + 6,
			menu.logo.pos.total_y + 40,
			colors.white)
		
		if btnp(buttons.a) or btnp(buttons.b) then
			game.state = 
				game.states.play
		end
		
	end
end


-- main functions
function _init()
	
	audio.mute.music()
	audio.mute.sfx()
	
	audio.mute.sfx2()
	audio.mute.sfx3()
	
	game.state = game.states.menu
	game.frames = 0
	
	game.time.seconds = 0
	game.time.init = time()
	
	gameplay.stage = 
		gameplay.stages.level1.id
	
	gameplay.score.step = 1
		
	player.lives = 
		game.difficulty.lives
		
	player.score = 0
	
	player.sprites = player.rossa
	
	player.title = 
		player.rossa.title	
	
	player.offset =
		player.rossa.offset
	
	player.id = 
		player.rossa.id
			
 entities.items = {}
 entities.vhs.counter = 0
 entities.vhs.showing_score = false
 entities.vhs.last = nil
 
 game.time.frame_counter = 0
 
 menu.pointer.state =
 	menu.pointer.states.rossa
 
 game.difficulty.speed = 1
 
end

function _update()

 audio.play.sfx()
 audio.play.sfx2()
 
 audio.play.sfx3()
 audio.play.music()
 
 game.update.frames()
 game.update.seconds()
    
end

function _draw()

 cls()

 menu.draw()
 gameplay.draw()
 gameover.draw()
 
 if debug then
 
 	local y = 10
 	local x = 5
 	
 	rectfill(0,y,
 	screen.width, y + 5, 
 	colors.black)
 	
 	print(game.time.seconds 
 							.. " seconds ", 
 							x, y,
  					colors.red)
  					
  print(game.frames
  					.. " frames ",
  					x + 60, y, 
  					colors.yellow)
 end
 
end
__gfx__
0000000000000000000e000000000eeeeeeee0000000000000005555555000000000000005550000005555500005555055666655000000000000000000000000
00000eeeeee00000000ee000000eeeeeeeeeee0000000000000555ffff5500005555555555555000005575500055575555555555000007770000000000000eee
000eeeeeeeeee000000eee0000eeeeeeeeeeeee0000000000055ffffffff500055755575555755000057175005557175555555550000077777000000000eeeee
00eeeeeeeeeeee00000eeee000eeeeeeeeeeeee000000000055ffffffffff5005717571755717550005575505555575555577755000777777777000000eeeeee
0eeeeeeeffeeee00000eee00000eee6666666eeee0000000055fffffffffff00557555750557555500555550575555505551175500777777777770000eeeeeee
0eeeeeeffffeeee0000ee00000066666616616eeee00000005ffffffffffff00555555550055575500557550717555005551175500777777777770000eeeeeef
eeeeeefffffeeee0000e000000066666616616eeee00000005ffffffffffff0000000000000571750057175057555000555555550077777777777700eeeeeeff
eeeeefffffffeee0000000000006699966996600eee0000005ffffffffffff0000000000000557500055755055500000555555550777777777777770eeeeefff
eeeefffdffdffee00770077000666999999999900ee000000ffffffff1ff1f0000500000075000000750000000000000000000000777777d7777777000000000
eefffffdffdffee0788778870066699999999999900000000ffffffff1ff1ff000550000717500007500000000000000000000000777d77dddd777d000000000
eeeffffffffff0007888888700666699999999999000000000fffffffffffff05575500007055000500000000000000000000000777dd77dddd777dd00000000
eeefffeeeeeef00078888887000666699999999999000000000fffff555550005717005005500000005000000000000000000000777dd77ddddd77dd00000000
0eeffeeeefeee00078888887000666666999999999000000000ffff55fff5000057507550005055000000000000000000000000d77ddddddddddddddd0000000
0000eeefffffe00007888870000066666666999999000000000ffff55fff5000005071750000507500000050000000000000000dddddddddddddddddd0000000
00000ffffff00000007887000006666666660099900000000000fff55f5f5000000057500005571700000555770000000000000ddddddddddddddddddd000000
000000ffff00000000077000006666666666600000000000000000ff5555500000000500000005750000005777700000000000dddddddddddddddddddd000000
0eeeeee00eeeeee000eeee000eeeeee0eeeeeee00eeeee00000ee0004444444400000000000000000000007777700000000000dd33333333dddddddddd000000
0eeeeeee0e000ee00eeeeee0eeeeeee0eeeeeee00eeeeee000eeee004444444400000000000000000000007777770000000000dd33333333ddddddddddd00000
0ee000ee0e000ee00ee00ee0eee00000ee000000eee0000000eeee004444444400000000000000000000077d7777700000000ddd33333333dddddddddddd0000
0ee000ee0e00eee00ee00ee0eee00000eeeeeee0eee000000ee00ee04444444400000000000000000000077777d7700000000ddd33333333dddddddddddd0000
0eeeeeee0eeeeee00ee00ee0eeeeeee0eeeeeee00eeeee000ee00ee04444444400000000000000000000777d7ddd77000000dddd33333333ddddddddddddd000
0eeeeee00eeeeeee0ee00ee0eeeeeee0ee0000000000eee0eeeeeeee4444444400000000000300000000777ddddddd000000dddd33333333ddddddddddddd000
0eee00000ee000ee0eeeeee0eee00000eeeeeee00eeeeee0ee0000ee44444444000000030033300300007ddddddddd000000dddd33333333dddddddddddddd00
0eee00000ee0000e00eeee00eee00000eeeeeee0eeeeee00ee0000ee4444444400000000330303300000dddddddddd00000ddddd33333333dddddddddddddd00
00000077777000000000007777000000000000077000000000000077770000000000000000030000000dddddddddddd0000dddddddddddddddddddddddddddd0
000007777d77000000000ddd777000000000007d7000000000000777777700000000000300333003000dddddddddddd00dddddddddddddddddddddddddddddd0
0000777dddddd0000000dddddd7d000000000ddddd000000000d7dddd7dd0000000000003303033000dddddddddddddd0ddddddddddddddddddddddddddddddd
0000dddddddddd00000dddd3ddddd0000000ddddddd0000d00dddddddddd000000000000000300000ddddddddddddddd0ddddddddddddddddddddddddddddddd
000dddddddddddd000dddd333ddddd00000dddddddddddddddddddddddddd000ddd0000000030000dddddddddddddddddddddddddddddddddddddddddddddddd
0ddddddddddddddd0dddd33333ddddddddddddddd33ddddddddddd333ddddd00dddd0000000300ddd33ddddddd333ddddd33333dddd33dddddd333dddddddddd
d33ddddd333333dddddd3333333ddddd333333dd3333ddddddddd33333dddddd33dddddddd333ddd3333dddd3333333dd3333333d33333ddd333333ddddddddd
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
000ee0000000ee0000ee0000000ee000000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00effe00000effe00effe00000effe0000effe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00efe000000efe0000efe000000efe0000efe0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07575700000575000757570000757500005750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f05550f00075557ff05550f0f7555570075557000000000000000000000000000000000000000000000000000000000550000000000000055000000000000000
005050000f050550005050000050050ff05050f00000000000000000000000000000000000000000000000000000000ff00000000000000ff000000000000000
05000500000500500050050005005000005050000000000000000000000000000000000000000000000000000000000f500000000000f00f500f000000000000
04400440000440440440440044044000044044000000000000000000000000000000000000000000000000000000000770000000000007077070000000000000
00000000000000000000000000080000000900000000000000000000000000000000000000000000000000000000007787000000000000778700000000000000
000000000000000000000000008a800000a8a0000000000000000000000000000000000000000000000000000000070780700000000000078000000000000000
00000000000000000000000000aaa00000989000000000000000000000000000000000000000000000000000000000f7700f0000000000077000000000000000
000000000000000000000000098a8900098a89000000000000000000000000000000000000000000000000000000000770000000000000077000000000000000
00000000000000000000000009a8a90000aaa000000000000000000000000a0a0000000000000000000000000000000111000000000000011000000000000000
000000000000000000000000089a9800089a98000000000005555550055555a00000000000000000000000000000000100100000000000100100000000000000
000000000000000000000000008a80000089800000000000057557500575575a0000000000000000000000000000000100100000000000100100000000000000
00000000000000000000000000080000000800000000000005555550055555500000000000000000000000000000000440440000000000440440000000000000
00000002200000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000028820000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000288882000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000028888e8200000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000288888e200000000070000000000000000000000000000000000000000000000000000000000000000000000000ee00000000000000ee000000000000000
000028888e820000000000700000000000000000000000000000000000000000000000000000000000000000000000e660000000000000e66000000000000000
00000288882000000000000700000000000000000000000000000000000000000000000000000000000000000000000699000000000060069906000000000000
00000028820000000000000000000000000000000000000000000000000000000000000000000000000000000000000660000000000006066060000000000000
00000000700000000000000000000555555555555550000000000000000000007575757557755555000000000000006666000000000000666600000000000000
00000007000000000000000000000555555555555550000000000000000000007575777557557575000000000000060660600000000000066000000000000000
00000000700000000000000000000077000000007700000000000005500000005755757577555755000000000000006660060000000000066000000000000000
00000000070000000000000000000006000000006000000000000055550000005555555555557575000000000000000660000000000000066000000000000000
00000000007000000000000000000000000000000000000000000555555000004444444444444444000000000000000666000000000000066000000000000000
000000000700000000000000000000000000000000000000000057555755000000dddd0000dddd00000000000000000600600000000000600600000000000000
000000007000000000000000000000000000000000000000000571757175500000a99a0000a99a00000000000000000600600000000000600600000000000000
00000007000000000000000000000000000000000000000000555755575555000008800000088000000000000000000990990000000000990990000000000000
00000000000000000000000000660000000000000066600000000000000700000000000000000600000000000000000000000000000000000000000000000000
00004948840000000000000006666000000000007766660000000000066600000000000000006006000000000000000000000000000000000000000000000000
000945a5549400000000000077776600000000077766660000000000076660000000000000000000000000000000000000000000000000000000000000000000
0044558a155940000000000077666660000000777666760000000000077666000000000000000000000000000000000000000000000000000000000000000000
00491111111440000000000776666600000000777766660000000000007600000000000000000000000000000000000000000000000000000000000000000000
0058944844a850000000007776666600000000076666660000000000000066000000000000000000000000000000000000000000000000000000000000000000
00daa48aa55a8d000000007776666600000000077666660000000000000666600000000000000000000000000000000000000000000000000000000000000000
0dd885588dd8d9d00000077766676600000000077776660000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dadadd8ad8a8ad00000077776666000000000076667600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d88a8da88dd98d00000007666666000000000077666600000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd889d88dd8888d0000007766666000000000007766600000000000000000000000000000000000000000000000000000000000000000000000000000000000
dda9addda8dd8aa80000007777666000000000000760000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd8d8dd88ddddd88000000766676000000000000000660000000000000000000000000000000000ee00000000000000ee0000000000000000000000000000000
ddadddddaddddddd00000077666600000000000000666600000000000000000000000000000000effe000000000000effe000000000000000000000000000000
dd8ddddd8ddddddd00000007766600000000000000000000000000000000000000000000000000efe00000000000f0efe00f0000000000000000000000000000
dddddddddddddddd0000000076000000000000000000000000000000000000000000000000000005700000000000050570500000000000000000000000000000
00000000000000000000000000055000000055000055000000055000000550000000000000000055750000000000005575000000000000000000000000000000
00004a484400000000000000000ff0000000ff0000ff0000000ff000000ff0000000000000000505705000000000000570000000000000000000000000000000
000945555444000000000000000f50000000f500005f00000005f000000f500000000000000000f5500f00000000000550000000000000000000000000000000
0044551a155940000000000007787700000787000778770000778700077877000000000000000005500000000000000550000000000000000000000000000000
004a11111114400000000000f07770f00077777ff07770f0f7777770f07770f00000000000000005550000000000000550000000000000000000000000000000
005448414489500000000000001010000f010110001010000010010f001010000000000000000005005000000000005005000000000000000000000000000000
00d8548445588d000000000001000100000100100010010001001000001010000000000000000005005000000000005005000000000000000000000000000000
0dd88555add889d00000000004400440000440440440440044044000044044000000000000000004404400000000004404400000000000000000000000000000
0dd8a9ddadddaad000000000000ee0000000ee0000ee0000000ee000000ee0000000000000000000000000000000000000000000000000000000000000000000
0dd98ddddd88add00000000000e69900000e69900996e00000996e0000e699000000000000000000000000000000000000000000000000000000000000000000
dd998ddd8dd9dadd0000000000066000000066000066000000066000000660000000000000000000000000000000000000000000000000000000000000000000
dd89dddda8dddddd0000000006666600000666000666660000666600006660000000000000000000000000000000000000000000000000000000000000000000
dddd8dd9a8dadddd0000000060666060006666666066606066666660066666000000000000000000000000000000000000000000000000000000000000000000
dadddddddddddd8d0000000000606000060606600060600000600606606060600000000000000000000000000000000000000000000000000000000000000000
dd8dd8ddaddd9a8d0000000006000600000600600060060006006000006060000000000000000000000000000000000000000000000000000000000000000000
dd98dddddadd8ddd0000000009900990000990990990990099099000099099000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000eeeeee00eeeeee000eeee000eeeeee0eeeeeee00eeeee0000eeee000eeeeee0000000000000000000000000000000000000000
00000000000000000000000000eeeeeee0e000ee00eeeeee0eeeeeee0eeeeeee00eeeeee00eeeeee00e000ee0000000005555555500000000000000000000000
00000000000000000000000000ee000ee0e000ee00ee00ee0eee00000ee000000eee000000ee00ee00e000ee0000000005575557500000000000000000000000
00000000000000000000000000ee000ee0e00eee00ee00ee0eee00000eeeeeee0eee000000ee00ee00e00eee0000000005717571700000000000000000000000
00000000000000000000000000eeeeeee0eeeeee00ee00ee0eeeeeee0eeeeeee00eeeee000ee00ee00eeeeee0000000005575557500000000000000000000000
00000000000000000000000000eeeeee00eeeeeee0ee00ee0eeeeeee0ee0000000000eee00ee00ee00eeeeeee000000005555555500000000000000000000000
00000000000000000000000000eee00000ee000ee0eeeeee0eee00000eeeeeee00eeeeee00eeeeee00ee000ee000000000000000000000000000000000000000
00000000000000000000000000eee00000ee0000e00eeee00eee00000eeeeeee0eeeeee0000eeee000ee0000e000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000eeeeee000eeee000eeeee000eeeee00000ee0000000000000000000000000000000000
0000000000000000000000000000000000000000055555555000000000e000ee00eeeeee00eeeeee00eeeeee000eeee000000000000000000000000000000000
0000000000000000000000000000000000000000055755575000000000e000ee00ee00ee0eee00000eee0000000eeee000000000000000000000000000000000
0000000000000000000000000000000000000000057175717000000000e00eee00ee00ee0eee00000eee000000ee00ee00000000000000000000000000000000
0000000000000000000000000000000000000000055755575000000000eeeeee00ee00ee00eeeee000eeeee000ee00ee00000000000000000000000000000000
0000000000000000000000000000000000000000055555555000000000eeeeeee0ee00ee00000eee00000eee0eeeeeeee0000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000ee000ee0eeeeee00eeeeee00eeeeee0ee0000ee0000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000ee0000e00eeee00eeeeee00eeeeee00ee0000ee0000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000eeeeeeee0000000000000005555555000000000000000000000000000000000000
00000000000000000000000000000000000000eeeeee0000000000000000eeeeeeeeeee0000000000000555ffff5500000000000000000000000000000000000
000000000000000000000000000000000000eeeeeeeeee0000000000000eeeeeeeeeeeee0000000000055ffffffff50000000000000000000000000000000000
00000000000000000000000000000000000eeeeeeeeeeee000000000000eeeeeeeeeeeee000000000055ffffffffff5000000000000000000000000000000000
0000000000000000000000000000000000eeeeeeeffeeee0000000000000eee6666666eeee0000000055fffffffffff000000000000000000000000000000000
0000000000000000000000000000000000eeeeeeffffeeee00000000000066666616616eeee00000005ffffffffffff000000000000000000000000000000000
000000000000000000000000000000000eeeeeefffffeeee00000000000066666616616eeee00000005ffffffffffff000000000000000000000000000000000
000000000000000000000000000000000eeeeefffffffeee0000000000006699966996600eee0000005ffffffffffff000000000000000000000000000000000
000000000000000000000000000000000eeeefffdffdffee00000000000666999999999900ee000000ffffffff1ff1f000000000000000000000000000000000
000000000000000000000000000000000eefffffdffdffee0000000000066699999999999900000000ffffffff1ff1ff00000000000000000000000000000000
000000000000000000000000000000000eeeffffffffff0000000000000666699999999999000000000fffffffffffff00000000000000000000000000000000
000000000000000000000000000000000eeefffeeeeeef00000000000000666699999999999000000000fffff555550000000000000000000000000000000000
0000000000000000000000000000000000eeffeeeefeee00000000000000666666999999999000000000ffff55fff50000000000000000000000000000000000
0000000000000000000000000000000000000eeefffffe00000000000000066666666999999000000000ffff55fff50000000000000000000000000000000000
00000000000000000000000000000000000000ffffff00000000000000006666666660099900000000000fff55f5f50000000000000000000000000000000000
000000000000000000000000000000000000000ffff00000000000000006666666666600000000000000000ff555550000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000e000000eee00ee00ee00ee0eee00000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000ee00000e0e0e0e0e000e000e0e00000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000eee0000ee00e0e0eee0eee0eee00000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000eeee000e0e0e0e000e000e0e0e00000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000eee0000e0e0ee00ee00ee00e0e00000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000077070707770707000000770707077707070000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000700070707070707000007000707070707070000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000700070707700707000007000707077007070000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707070707070707000007070707070707070000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000777007707070077000007770077070700770000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000770007707700000007707770777077707770777000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707070707070000070007070707007007000707000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707070707070000070007770770007007700770000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707070707070000070007070707007007000707000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000777077007070000007707070707007007770707000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000770770077707770770077700000007000007700777077007770777007700000077070000000000000000000000000000
00000000000000000000000000000000777770000707070070000700000007777007070070070700700707070000000700070000000000000000000000000000
00000000000000000000000000000000777770077707070070000700000007770007070070070700700777077700000700070000000000000000000000000000
00000000000000000000000000000000077700070007070070000700000077770007070070070700700707000700000700070000000000000000000000000000
00000000000000000000000000000000007000077707770777000700000000070007070777070707700707077000700077077700000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100010100000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000460000464646464600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0045000000000000000000000000000000004646464600000046460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202122232425222147080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000066000000a0a189878885868283000000000000000000000000000046464646000000000000000000000000000000000000000000000000000060614b4c006061999a0060614d4e00000000464646464600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000b0b100979895969293000000000000464660610000000000464646000046466061000000000000000000004646606100000000000062635b5c006263a9aa0070715d5e00464608472122252526474646000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000808145464646000000007071004b4c00464646460000000062630000000000000000000000007071004d4e000000737879750073787975007378797500464600000046464646474646000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000001c90911f464646000000760c0c775b5c0046464646000000760c0c77595a0000000000000000760c0c775d5e00000060616b6c0060616d6e0060619b9c00000f01460304050607464646000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000028292a2b2c2e2e2f0000007374747878787874747500464646737474787878787474750000000073747478787878747475000062637b7c0070717d7e467071abac00471011461314151617464600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
303132333435363738393a3b3c3d3e3f00000000000000464646464600000000000000000000000000000000000000000000000000000000000000737879750073787975007378797500004747474646464700004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d00000000004646464646464646464646000000000000000000000000000000000000000000000000000000000000000000000000000000000000004747474700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010c01002c146321202c0002c000240001c0001a00018000170001600015000140001400025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002e770227502e770227502c770207501e000000002a7701e7502a7701e7502a7701e7501900000000257701975025770197502577019750000000000019000000001e0000000020000300002700028000
010800002e0702c0002e070000002c0700000000000000002a0702a0702a0702a0702a0702a0700000000000250702507025070250702507025070000000000025070000002a070000002c0702c0703300033000
010800003307033070330703307033070330703300000000310703107031070310703107031070000000000031070250003107000000310700000031070270002f0702f0002f000280002c0702b0002c00000000
0108000031070000003107000000310700000031070000002f0702f0702f0702f0002800034070280003507029000370702b00035070290003407034070280002900035070350703507030000000000000000000
011000002e131251110d0113670012004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030000
01140000241313c1313a131220110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c000
010800002e071220361601616016162061e0001e00016100171002310025100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002277000000227700000020770207701e700000001e7701e7701e7701d000190001977019770197701d000190001e000197701e0001d7701d7701d770000001d7701d0001d770000001e7701e7701e770
010a00001005018010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000035000
010600003a0702c0003a0700000038070000000000000000360703607036070360703607000000000000000031070310703107031070310702500025000000000000000000000000000000000000000000000000
010800003a0712e036160161601600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 02404344
01 03424344
04 04424344
04 01424344
04 08424344

