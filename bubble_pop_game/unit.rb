#Unit Class
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