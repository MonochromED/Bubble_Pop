#Map Class.
#This class creates the level's board and the object keeps track
#of each cell's properties.  

#require the matrix class by including the matrix file
require 'matrix'

#Require other classes
require_relative 'projectile'
require_relative 'unit'
require_relative 'enemy'
require_relative 'trap'
require_relative 'goal'



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
  attr_accessor :enemy_list
  attr_accessor :projectiles_list
  def initialize(width = 10 , height = 10)
    @map = Matrix.build(height,width){|column, row| "x"}
    @map_width = width
    @map_height = height
    @traps_list = []
    @goal =[Goal.new(map_width-1, map_height-1)]
    @enemy_list = []
    @projectiles_list = Array.new #create projectile class to insert objects into this array
  end

  def markPositionOnMap(position_x, position_y, value)
    @map.send :[]=, position_y, position_x, value
  end

  def checkForEncounter(unit_object)
    traps_list.each do |trap|
      if locationOfTwoMatches(unit_object , trap)
        puts "trap on #{trap.position_x} x and #{trap.position_y} y" 
        puts "You are trapped"
        puts "you lose"
        return true
      end
    end

    goal.each do |goal|
      if locationOfTwoMatches(unit_object , goal)
        puts "goal on #{goal.position_x} x and #{goal.position_y} y" 
        puts "You have found the goal"
        puts "You win!"
        return true
      end
    end

    projectiles_list.each do |projectile|
      if locationOfTwoMatches(unit_object , projectile)
        puts "you have been hit"
        puts "you lost"
        return true
      end
    end

    if enemy_list != nil
      #overhaul enemy into own class.  Make similar to projectiles_list for enemy_list data member
      enemy_list.each do |enemy|
        if locationOfTwoMatches(unit_object , enemy)
          puts "battle time"
          puts "pick 0 or 1"
          user_choice = gets.chomp.to_s
          random_flip = rand(2).to_s
          if user_choice === random_flip
            puts "you defeated an enemy"


            enemy_list.delete(enemy)
            #reprint Hero over enemy tile

          else
            puts "an enemy defeated you and reset your position"
            unit_object.position_x = 0
            unit_object.position_y = 0
            markPositionOnMap(enemy.position_x, enemy.position_y, "E")
            unit_object.markUnitLocation(self, 'H')
            #enemy spawns projectiles on map 1-4 projectiles
            random_number = rand(4)+1
            random_number.times do
              self.generateProjectile(rand(map_width), rand(map_width), "up", "enemy")
            end
            showAllProjectiles()
            printCurrentMap()
          end
        end
        #projectile will destroy enemy unit.  Projectile will disappear after.
        #move this to a reject! iterator in future patch.
        projectiles_list.each do |projectile|
          if locationOfTwoMatches(projectile , enemy)
            markPositionOnMap(enemy.position_x, enemy.position_y, "x")
            enemy_list.delete(enemy)
            projectiles_list.delete(projectile)
            puts "enemy destroyed"
          end
        end
      end
    end
  end

  def showTrappedBlocks()
    self.traps_list.each do|trap|
      self.markPositionOnMap(trap.position_x, trap.position_y, "O")
    end
  end

  def markEnemyLocation(marker = "E")
    self.enemy_list.each do|enemy|
      self.markPositionOnMap(enemy.position_x, enemy.position_y, "E")
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
      puts "**#{projectile_position_x},#{projectile_position_y}"
      if projectile.position_y >= 0 || projectile.position_x >= 0
        self.markPositionOnMap(projectile_position_x,projectile_position_y,"x")
      end
    }
    
  end

  #generate trap at location
  def generateTrapOnMap(position_x = rand(map_width), position_y = rand(map_height))
    traps_list.push(Trap.new(position_x,position_y))
  end

  #Checks if location of 2 things have matching x and y
  def locationOfTwoMatches(unit_a , unit_b)
    if unit_a.position_x === unit_b.position_x && unit_a.position_y === unit_b.position_y
      return true
    else
      return false
    end
  end

  #generate enemy on map
  def generateEnemyOnMap(position_x = rand(map_width), position_y = rand(map_height))
    enemy_list.push(Enemy.new(position_x, position_y))
  end

  #spawn specified number of enemies at random map locations
  def spawnEnemiesOnMap(quantity = 1)
    quantity.times do
      generateEnemyOnMap()
    end
  end

  #spawn specified number of traps at random locations
  def spawnTrapsOnMap(quantity = 1)
    quantity.times do
      generateTrapOnMap()
    end
  end

end



















