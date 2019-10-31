require 'gosu'
module ZOrder
    BACKGROUND, MONEY, PLAYER, UI = *0..3
end
class Player
    attr_reader :score, :dead
    def initialize
        @image = Gosu::Image.new('media/lenin.jpg') #need file extension
        @x = @vel_x = 0.0
        @y = 400
        @score = 0
        @dead = false
    end

    def warp(x)
        @x  = x
    end
    def accelerate
        @vel_x += 0.5
    end
    def move_left
        @x -= @vel_x
        @x %= 640
        @vel_x *= 0.95
    end
    def move_right
        @x += @vel_x
        @x %= 640
        @vel_x *= 0.95
    end
    def draw
        @image.draw(@x, @y, ZOrder::PLAYER, factor_x = 0.05, factor_y = 0.05)
    end
    def collect_money(moneys)
        moneys.reject! do |money|
            if Gosu.distance(@x, @y, money.x, money.y) < 25
                @score += (10 * money.bigness).to_i
                true
            else
                false
            end
        end
    end
    def hit_bombs(bombs)
        bombs.reject! do |bomb|
            if Gosu.distance(@x, @y, bomb.x, bomb.y) < 25 
                @dead = true
                true
            elsif bomb.y > 500
                true
            else
                false
            end

        end
    end
end

class Money 
    attr_reader :bigness, :x, :y
    def initialize(size)
        @x = rand * 640
        @y = 480.0
        @bigness = size
        @image = Gosu::Image.new('media/money.png') # need money pic
    end
    def draw
        @image.draw(@x, @y, ZOrder::MONEY, factor_x = 0.1*@bigness, factor_y = 0.1* @bigness)
    end
    def move
        @y += @bigness
        @y %= 480
    end
end
class Bomb 
    attr_reader :x, :y
    def initialize
        @x = rand * 640
        @y = 0.0
        @image = Gosu::Image.new('media/stalin.jpg') # need bomb pic
    end
    def draw
        @image.draw(@x, @y, ZOrder::MONEY, factor_x = 0.07, factor_y = 0.07)
    end
    def move
        @y += 5   
    end
end

class Tutorial < (Gosu::Window)
    def initialize
      super 640, 480
      self.caption = "Money Bomb"
      
      @background_image = Gosu::Image.new("media/back.jpg", tileable: true) # need background pic
      
      @player = Player.new
      @player.warp(360)
      
      @moneys = Array.new
      @bombs = Array.new
      
      @font = Gosu::Font.new(20)
      @big_font = Gosu::Font.new(100)
    end
    
    def update
      if Gosu.button_down? Gosu::KB_LEFT or Gosu.button_down? Gosu::GP_LEFT
        @player.accelerate
        @player.move_left
      end
      if Gosu.button_down? Gosu::KB_RIGHT or Gosu.button_down? Gosu::GP_RIGHT
        @player.accelerate
        @player.move_right
      end
      if !@player.dead
        @player.hit_bombs(@bombs)
        @player.collect_money(@moneys)
        if rand(100) == 1 and @bombs.size < 3
            @bombs.push(Bomb.new)
        end
        if rand(100) < 4 and @moneys.size < 25
            @moneys.push(Money.new(rand))
        end
        @bombs.each {|bomb| bomb.move}
        @moneys.each {|money| money.move}
    end
    end
    
    def draw
      @background_image.draw(0, 0, ZOrder::BACKGROUND, factor_x = 0.47, factor_y = 0.25)
      if !@player.dead
        @player.draw
        @moneys.each { |money| money.draw }
        @bombs.each {|bomb| bomb.draw}
      else
        @big_font.draw_text("YOU LOST\nKarl is\nDisappointed", 640 / 6, 480 / 2.5, ZOrder::UI, 1.0, 1.0, Gosu::Color::GREEN) if @player.dead
      end
      @font.draw_text("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLUE)
    end
    
    def button_down(id)
      if id == Gosu::KB_ESCAPE
        close
      else
        super
      end
    end
  end
  
  Tutorial.new.show
