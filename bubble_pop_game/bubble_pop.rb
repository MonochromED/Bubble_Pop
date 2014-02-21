#bubble_pop run file

require_relative 'enemy'
require_relative 'unit'
require_relative 'map'
require_relative 'projectile'


#------Program Main----------------
#Initialize unit and world
puts "Enter player name?"
user_input = gets.chomp.to_s.downcase
hero = Unit.new(0,0,"south",user_input)

world = Map.new(15,15)
world.spawnTrapsOnMap(3)
world.spawnEnemiesOnMap(2)
world.showTrappedBlocks()
world.markEnemyLocation()
world.generateProjectile(3,0,"left", "none")
world.generateProjectile(4,1,"left", "none")
world.generateProjectile(5,2,"left", "none")
world.generateProjectile(6,3,"left", "none")
world.generateProjectile(7,4,"left", "none")
world.generateProjectile(4,14,"up", "none")
world.generateProjectile(5,14,"up", "none")
world.generateProjectile(6,14,"up", "none")
world.generateProjectile(7,14,"up", "none")
world.generateProjectile(10,5,"right","none")
world.generateProjectile(11,5,"right","none")
world.generateProjectile(10,7,"down","none")
world.generateProjectile(11,7,"down","none")


world.printCurrentMap()

puts "Hero #{hero.name} has joined the battle!"

#Program loop here
user_input = nil

while user_input != "q" do
  #moves all projectiles
  world.moveAllProjectiles()

  #shows all traps.  Reshows if was covered by another entity
  world.showTrappedBlocks()

  #shows all projectiles
  world.showAllProjectiles()

  #marks enemy location if enemy present
  if world.enemy_list != nil
    world.markEnemyLocation()
  end

  #places unit
  hero.markUnitLocation(world,"H")


  #checks for unit trapped
  if world.checkForEncounter(hero) === true
    break
  end

  #Shows unit locations
  world.printCurrentMap()





  puts "c = change face direction ; w = up ; s = down ; a = left ; d = right ; e = fire ; r = remove all projectiles ; q = quit" ;
  puts "your next move?"
  user_input = gets.chomp.to_s.downcase

  case 
    when user_input.match(/c/)
      puts "Face Direction select: w = up ; s = down ; a = left ; d = right"
      user_input = gets.chomp.to_s.downcase

      case
      when user_input.match(/w/)
        hero.changeFaceDirection("up")
      when user_input.match(/s/)
        hero.changeFaceDirection("down")
      when user_input.match(/a/)
        hero.changeFaceDirection("left")
      when user_input.match(/d/)
        hero.changeFaceDirection("right")
      end
    when user_input.match(/w/)
      hero.moveUnitUp(world)
    when user_input.match(/s/)
      hero.moveUnitDown(world)
    when user_input.match(/a/)
      hero.moveUnitLeft(world)
    when user_input.match(/d/)
      hero.moveUnitRight(world)
    when user_input.match(/e/)
      hero.fireProjectile(world)
    when user_input.match(/r/)
      world.deleteAllProjectiles()
    when user_input.match(/q/)
    else
      puts "Unknown command.  Try again."
    
  end
end