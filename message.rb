require "simple-random"

class Message
  attr_accessor :r1, :r2, :rFinal, :interaction,
                :arrivedAt,
                :requestDuration,
                :swIn, :swInDuration,
                :saIn, :saInDuration,
                :bdIn, :bdDuration, :bdOut,
                :saOut, :saOutDuration,
                :swOut, :swOutDuration,
                :receivingDuration,
                :firewallDelay,
                :m1, :m2, :m3, :m4, :m5, :m5, :m6, :m7, :m8, :m9

  def initialize()
    @rFinal = rand(0..1000)/1000.0

    if @rFinal > 0.95
      @interaction = 1
    elsif @rFinal > 0.76
      @interaction = 2
    else
      @interaction = 3
    end

    generateDurations()

    #tamanho das mensagens baseado na dist triangular.
    r = SimpleRandom.new
    @m1 = r.triangular(100, 200, 250) * (rand(100..110)/100.0)
    @m2 = r.triangular(100,200,300) * (rand(100..110)/100.0)
    @m3 = r.triangular(250,400,450)* (rand(100..110)/100.0)
    @m4 = r.triangular(1500,2500,3000) * (rand(100..110)/100.0)
    @m5 = r.triangular(1500,2100,2800) * (rand(100..110)/100.0)
    @m6 = r.triangular(400,550,800) * (rand(100..110)/100.0)
    @m7 = r.triangular(2000,3000,3500) * (rand(100..110)/100.0)
    @m8 = r.triangular(1800,2000,2300) * (rand(100..110)/100.0)
    @m9 = r.triangular(1500,2100,2800) * (rand(100..110)/100.0)
  end

  def generateDurations()

    if @interaction == 1

      @swInDuration = rand(4..6)/1000.0
      @swOutDuration = 0
      @saInDuration = 0
      @saOutDuration = 0
      @firewallDelay = 0
      @bdDuration = 0

    elsif @interaction == 2

      @swInDuration = rand(5..7)/1000.0
      @swOutDuration = rand(7..10)/1000.0
      @saInDuration = rand(40..60)/1000.0
      @saOutDuration = 0
      @firewallDelay = rand(3..5)/1000.0
      @bdDuration = 0

    else

      @swInDuration = rand(9..12)/1000.0
      @swOutDuration = rand(9..12)/1000.0
      @saInDuration = rand(40..60)/1000.0
      @saOutDuration = rand(60..120)/1000.0
      @firewallDelay = rand(7..10)/1000.0
      @bdDuration = rand(15..30)/1000.0 + rand(50..400)/1000.0

    end
    @requestDuration = 0.005
  end
end