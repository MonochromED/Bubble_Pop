#Projectile Class

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

  def changeFaceDirection(face_direction)
    case
    when face_direction.match(/up/)
      @face = $directions["up"]
    when face_direction.match(/down/)
      @face = $directions["down"]
    when face_direction.match(/left/)
      @face = $directions["left"]
    when face_direction.match(/right/)
      @face = $directions["right"]     
    else
      @face = nil
    end    
  end
end