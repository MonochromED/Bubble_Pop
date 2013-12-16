#level_board Class.
#This class creates the level's board and the object keeps track
#of each cell's properties.  

#require the matrix class by including the matrix file
require 'matrix'


#overhaul all marking to be done by the 'markPositionOnMap'
#overhaul enemy and traps into own class
#add in face direction to hero and enemy class.  add in method to fire projectile

$directions = Hash.new
$directions["up"] = "up"
$directions["right"] = "right"
$directions["down"] = "down"
$directions["left"] = "left"


class Map
	attr_accessor :map
	attr_reader :traps_list
	attr_reader :map_height
	attr_reader :map_width
	attr_reader :goal
	attr_accessor :enemy
	attr_accessor :projectiles_list
	def initialize(width = 10 , height = 10)
		@map = Matrix.build(height,width){|row, column| "x"}
		@map_width = width
		@map_height = height
		@traps_list = [[2,2], [5,5] , [7,7]]
		@goal =[[width-1, height-1]]
		@enemy = [[rand(width),rand(height)]]
		@projectiles_list = Array.new #create projectile class to insert objects into this array
	end

	def markPositionOnMap(position_x, position_y, value)
		@map.send :[]=, position_y, position_x, value
	end

	def checkForEncounter(unit_object)
		traps_list.each do |trap_x, trap_y|
			if unit_object.position_x === trap_x && unit_object.position_y === trap_y
				puts "trap on #{trap_x} x and #{trap_y} y" 
				puts "You are trapped"
				puts "you lose"
				return true
			end
		end

		goal.each do |goal_x, goal_y|
			if unit_object.position_x === goal_x && unit_object.position_y === goal_y
				puts "goal on #{goal_x} x and #{goal_y} y" 
				puts "You have found the goal"
				puts "You win!"
				return true
			end
		end

		projectiles_list.each do |projectile|
			if unit_object.position_x === projectile.position_x && unit_object.position_y === projectile.position_y
				puts "you have been hit"
				puts "you lost"
				return true
			end
		end

		if enemy != nil
			#overhaul enemy into own class.  Make similar to projectiles_list for @enemy data member
			enemy.each do |enemy_x, enemy_y|
				if unit_object.position_x === enemy_x && unit_object.position_y === enemy_y
					puts "battle time"
					puts "pick 0 or 1"
					user_choice = gets.chomp.to_s
					random_flip = rand(2).to_s
					if user_choice === random_flip
						puts "you defeated the enemy"
						#CHANGE THIS TO USE EMEMY CLASS

						@enemy = nil
						#reprint Hero over enemy tile

					else
						puts "the enemy defeated you and reset your position"
						unit_object.position_x = 0
						unit_object.position_y = 0
						markPositionOnMap(enemy_x, enemy_y, "E")
						unit_object.markUnitLocation(self, 'H')
						#enemy spawns projectiles on map 1-4 projectiles
						random_number = rand(4)+1
						random_number.times do
							self.generateProjectile(rand(15), rand(15), "up", "enemy")
						end
						showAllProjectiles()
						printCurrentMap()
					end
				end
        #projectile will destroy enemy unit.  Projectile will disappear after.
        #move this to a reject! iterator in future patch.
        projectiles_list.each do |projectile|
          if projectile.position_x === enemy_x && projectile.position_y === enemy_y
            markPositionOnMap(enemy_x, enemy_y, "x")
            @enemy = nil
            projectiles_list.delete(projectile)
            puts "enemy destroyed"
          end
        end
			end
		end
	end

	#overhaul traps into own class.  Make similar to projectiles_list for @enemy data member
	def showTrappedBlocks()
		self.traps_list.each do|trap_x, trap_y|
			self.markPositionOnMap(trap_x, trap_y, "O")
		end
	end

	def markEnemyLocation(marker = "E")
		self.enemy.each do|enemy_x, enemy_y|
			self.markPositionOnMap(enemy_x, enemy_y, "E")
		end
	end

	#add in projectile and add to list.  Face depends on unit firing.  Position begins
	#1 block in front of face direction.  Projectile moves 1 block per game tick.
	def generateProjectile(position_x, position_y, face, owner)
    case
    when face.match(/up/)
      face_direction = $directions["up"]
    when face.match(/down/)
      face_direction = $directions["down"]
    when face.match(/left/)
      face_direction = $directions["left"]
    when face.match(/right/)
      face_direction = $directions["right"]     
    else
      face_direction = nil
    end
		projectile = Projectile.new(position_x, position_y, face_direction, owner)
		self.projectiles_list.push(projectile)
	end

	#all projectiles on the projectiles list move by 1 block per game tick.  If leaves map, deleted.  
	#*NOT IMPLEMENTED*If a projectile encounters an obstacle, is deleted.  
	#Encounters with a destructable object or unit runs that encounter event.
	#check if move valid first, then move.  otherwise bug seems to occur
	def moveAllProjectiles()
		self.projectiles_list.each do |projectile|
			projectile_face_direction = projectile.face
			case 
			when projectile_face_direction.match(/up/)
				removeEntityMarkerFromLocation(projectile.position_x, projectile.position_y)
				projectile.position_y -= 1
				projectile.moveProjectile(projectile.position_x, projectile.position_y)

			when projectile_face_direction.match(/down/)
				removeEntityMarkerFromLocation(projectile.position_x, projectile.position_y)
				projectile.position_y += 1
				projectile.moveProjectile(projectile.position_x, projectile.position_y)

			when projectile_face_direction.match(/left/)
				removeEntityMarkerFromLocation(projectile.position_x, projectile.position_y)
				projectile.position_x -= 1
				projectile.moveProjectile(projectile.position_x, projectile.position_y)

			when projectile_face_direction.match(/right/)
				removeEntityMarkerFromLocation(projectile.position_x, projectile.position_y)
				projectile.position_x += 1
				projectile.moveProjectile(projectile.position_x, projectile.position_y)

			else
				puts "Unknown command.  Try again."
		
			end



			puts "****#{projectile_face_direction}, #{projectile.position_x}, #{projectile.position_y} idobj: #{projectile}******DEBUG"		
		end


		projectilesWithinMapBounds()
	end

	#checks if projectiles are within map bounds

	def projectilesWithinMapBounds()
		map_minimum_width = 0
		map_minimum_height = 0			
		#delete out of bounds projectile from the projectiles_list and then destroy projectile, and removes from map.

		projectiles_list.reject!{|projectile|
			projectile_position_x = projectile.position_x
			projectile_position_y = projectile.position_y
			if (projectile_position_y < map_minimum_height || projectile_position_y >= (self.map_height-1) ||
				projectile_position_x < map_minimum_width || projectile_position_x >= (self.map_width-1))
				removeEntityMarkerFromLocation(projectile_position_x, projectile_position_y)
			end				
		}		


	end

	#Removes marker value on map.  Entity still contains its position, but mark no longer on map.
	def removeEntityMarkerFromLocation(position_x, position_y)
		self.markPositionOnMap(position_x,position_y,"x")
	end
	#showing all projectiles
	def showAllProjectiles(marker = "*")
		self.projectiles_list.each do |projectile|
			self.markPositionOnMap(projectile.position_x, projectile.position_y, marker)
		end
			
		

	end

	#Shows unit locations
	def printCurrentMap()
		self.map.to_a.each do |row|
			puts row.join " "
		end	
	end

	#delete all projectiles in projectiles_list
	def deleteAllProjectiles()
		self.projectiles_list.reject!{ |projectile|
			projectile_position_x = projectile.position_x
			projectile_position_y = projectile.position_y
			puts "**#{projectile_position_x},,#{projectile_position_y}"
			if projectile.position_y > 2 || projectile.position_x > 2
				self.markPositionOnMap(projectile_position_x,projectile_position_y,"x")
			end
		}
		
	end
end



class Projectile
	attr_accessor :position_x, :position_y, :face, :owner



	def initialize(p_position_x = 0, p_position_y = 0, face = "up", owner = "none")
		@position_x = p_position_x
		@position_y = p_position_y
    @face = nil
		self.changeFaceDirection(face)
		@owner = owner
	end

	def moveProjectile(position_x, position_y)
		self.position_x = position_x
		self.position_y = position_y
	end

  def changeFaceDirection(faceDirection)
    case
    when faceDirection.match(/up/)
      @face = $directions["up"]
    when faceDirection.match(/down/)
      @face = $directions["down"]
    when faceDirection.match(/left/)
      @face = $directions["left"]
    when faceDirection.match(/right/)
      @face = $directions["right"]     
    else
      @face = nil
    end    
  end
end




class Unit
	attr_accessor :position_x, :position_y, :face
	def initialize(position_x = 0, position_y = 0, faceDirection = $directions["up"])
		@position_x = position_x
		@position_y = position_y
    @face = nil
    self.changeFaceDirection(faceDirection)
    @name = nil
	end


	def moveUnitToLocation(position_x , position_y)
		@position_x = position_x
		@position_y = position_y
	end

	def markUnitLocation(mapObject,value)
		mapObject.markPositionOnMap(@position_x,@position_y,value)

	end

	def removeUnitLocation(mapObject)
		mapObject.markPositionOnMap(@position_x,@position_y,"x")
	end

	def moveUnitUp(mapObject)

		#add in test to see if valid spot on grid
		if 0 <= @position_y-1 && @position_y-1 < mapObject.map_height
			self.removeUnitLocation(mapObject)
			@position_y = @position_y - 1
			self.markUnitLocation(mapObject, "H")
		else
			puts "INVALID MOVE"
		end
	end

	def moveUnitDown(mapObject)
		if 0 <= @position_y+1 && @position_y+1 < mapObject.map_height
			self.removeUnitLocation(mapObject)
			@position_y = @position_y + 1
			self.markUnitLocation(mapObject, "H")
		else
			puts "INVALID MOVE"
		end
	end	

	def moveUnitLeft(mapObject)
		if 0 <= @position_x-1 && @position_x-1 < mapObject.map_width
			self.removeUnitLocation(mapObject)
			@position_x = @position_x - 1
			self.markUnitLocation(mapObject, "H")
		else
			puts "INVALID MOVE"
		end
	end	

	def moveUnitRight(mapObject)
		if 0 <= @position_x+1 && @position_x+1 < mapObject.map_width
			self.removeUnitLocation(mapObject)
			@position_x = @position_x + 1
			self.markUnitLocation(mapObject, "H")
		else
			puts "INVALID MOVE"
		end
	end

  def changeFaceDirection(faceDirectionString)
    case
    when faceDirectionString.match(/up/)
      @face = $directions["up"]
    when faceDirectionString.match(/down/)
      @face = $directions["down"]
    when faceDirectionString.match(/left/)
      @face = $directions["left"]
    when faceDirectionString.match(/right/)
      @face = $directions["right"]     
    else
      @face = nil
    end    
  end

  #places projectile 1 block in front of unit that fires it.  Front determined
  #by face direction of unit.
  def fireProjectile(mapObject)
    face_direction = @face

    case face_direction
    when $directions["up"]
      mapObject.generateProjectile(@position_x, @position_y, face_direction, @name)
    when $directions["down"]
      mapObject.generateProjectile(@position_x, @position_y, face_direction, @name)    
    when $directions["left"]
      mapObject.generateProjectile(@position_x, @position_y, face_direction, @name)
    when $directions["right"]
      mapObject.generateProjectile(@position_x, @position_y, face_direction, @name) 
    else     
    end

  end
end


class Enemy < Unit

end


#------Program Main----------------
#Initialize unit and World
World = Map.new(15,15)
Tom = Enemy.new
World.showTrappedBlocks()
World.markEnemyLocation()
World.generateProjectile(3,0,"left", "none")
World.generateProjectile(4,1,"left", "none")
World.generateProjectile(5,2,"left", "none")
World.generateProjectile(6,3,"left", "none")
World.generateProjectile(7,4,"left", "none")
World.generateProjectile(4,14,"up", "none")
World.generateProjectile(5,14,"up", "none")
World.generateProjectile(6,14,"up", "none")
World.generateProjectile(7,14,"up", "none")
World.generateProjectile(10,5,"right","none")
World.generateProjectile(11,5,"right","none")
World.generateProjectile(10,7,"down","none")
World.generateProjectile(11,7,"down","none")


World.printCurrentMap()

#Program loop here
user_input = nil

while user_input != "q" do
	#moves all projectiles
	World.moveAllProjectiles()

	#shows all traps.  Reshows if was covered by another entity
	World.showTrappedBlocks()

	#shows all projectiles
	World.showAllProjectiles()

	#marks enemy location if enemy present
	if World.enemy != nil
		World.markEnemyLocation()
	end

	#places unit
	Tom.markUnitLocation(World,"H")


	#checks for unit trapped
	if World.checkForEncounter(Tom) === true
		break
	end

	#Shows unit locations
	World.printCurrentMap()


	puts "c = change face direction ; w = up ; s = down ; a = left ; d = right ; e = fire ; r = remove all projectiles ; q = quit" ;
	puts "your next move?"
	user_input = gets.chomp.to_s.downcase

	case 
    when user_input.match(/c/)
      puts "Face Direction select: w = up ; s = down ; a = left ; d = right"
      user_input = gets.chomp.to_s.downcase

      case
      when user_input.match(/w/)
        Tom.changeFaceDirection("up")
      when user_input.match(/s/)
        Tom.changeFaceDirection("down")
      when user_input.match(/a/)
        Tom.changeFaceDirection("left")
      when user_input.match(/d/)
        Tom.changeFaceDirection("right")
      end
		when user_input.match(/w/)
			Tom.moveUnitUp(World)
		when user_input.match(/s/)
			Tom.moveUnitDown(World)
		when user_input.match(/a/)
			Tom.moveUnitLeft(World)
		when user_input.match(/d/)
			Tom.moveUnitRight(World)
    when user_input.match(/e/)
      Tom.fireProjectile(World)
		when user_input.match(/r/)
			World.deleteAllProjectiles()
		when user_input.match(/q/)
		else
			puts "Unknown command.  Try again."
		
	end
end











