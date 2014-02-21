#bubble_pop run file

require_relative 'enemy'
require_relative 'unit'
require_relative 'map'
require_relative 'projectile'


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


puts "Enter player name?"
user_input = gets.chomp.to_s.downcase


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