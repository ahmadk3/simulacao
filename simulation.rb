require_relative "message"

class Simulation
  attr_accessor :table,
                :messagesQuantity,
                :roteadorDelay,
                :messages,
                :fila,
                :velocidade,
                :tempoEntreChegadas,
                :decoyTable, :width, :height

  def initialize (qty)
    @messagesQuantity = qty
    @roteadorDelay = 0.00015
    @velocidade = 80000000.0
    @tempoEntreChegadas = 0.0005
    @width = 19
    @height = qty + 1

    @messages = []
    qty.times do
      @messages << Message.new
    end

    @table = Array.new(@height){Array.new(@width)}

    @table[0][0] = "MessageID"
    @table[0][1] = "TEC"
    @table[0][2] = "Entrada SW Ida"
    @table[0][3] = "Duracao SW Ida"
    @table[0][4] = "Saida SW Ida"
    @table[0][5] = "Entrada SA Ida"
    @table[0][6] = "Duracao SA Ida"
    @table[0][7] = "Saida SA Ida"
    @table[0][8] = "Entrada DB"
    @table[0][9] = "Duracao DB"
    @table[0][10] = "Saida DB"
    @table[0][11] = "Entrada SA Volta"
    @table[0][12] = "Duracao SA Ida"
    @table[0][13] = "Saida SA Volta"
    @table[0][14] = "Entrada SW Volta"
    @table[0][15] = "Duracao SW"
    @table[0][16] = "Saida SW Volta"
    @table[0][17] = "Recepcao da resposta"
    @table[0][18] = "Interacao"

    #preenche a tabela com os ids das mensagens
    id()
    sw()
    sa()
    db()
    saBack()
    swBack()
    tempoFinal()
  end

  def id
    (@messages.size).times do |i|
      @table[i+1][0] = i
      @table[i+1][1] = i > 0? @tempoEntreChegadas + @table[i][1] : @tempoEntreChegadas
    end
  end

  def sw
    @messages.each_with_index do |m, i|
      if i == 0
        @table[i+1][2] = m.m1/@velocidade + @table[i+1][1]
        @table[i+1][3] = m.swInDuration
        @table[i+1][4] = @table[i+1][3] + @table[i+1][2]
      else
        if @table[i+1][1] > @table[i][4]
          @table[i+1][2] = m.m1/@velocidade + @table[i+1][1]
        else
          @table[i+1][2] = @table[i][4] + m.m1/@velocidade
        end
        @table[i+1][3] = m.swInDuration
        @table[i+1][4] = @table[i+1][3] + @table[i+1][2]
      end
      @table[i+1][18] = m.interaction
    end
  end

  def interaction1Back
    @messages.each_with_index do |m, i|
      if m.interaction == 1
        @table[i+1][17] = m.m2/@velocidade + m.requestDuration
      end
    end
  end

  def sa
    first = true
    lastIndex = nil
    @messages.each_with_index do |m, i|
      if m.interaction != 1
        if first
          @table[i+1][5] = m.m3/@velocidade + @table[i+1][4]
          @table[i+1][6] = m.saInDuration
          @table[i+1][7] = @table[i+1][5] + @table[i+1][6]
          lastIndex = i+1
          first = false
        else
          if @table[i+1][4] > @table[lastIndex][7]
            @table[i+1][5] = m.m3/@velocidade + @table[i+1][4]
          else
            @table[i+1][5] = @table[lastIndex][7] + m.m3/@velocidade
          end
          @table[i+1][6] = m.saInDuration
          @table[i+1][7] = @table[i+1][6] + @table[i+1][5]
          lastIndex = i+1
        end
      end
    end
  end

  def db
    first = true
    lastIndex = nil
    @messages.each_with_index do |m, i|
      if m.interaction == 3
        if first
          @table[i+1][8] = m.m6/@velocidade + @table[i+1][7]
          @table[i+1][9] = m.bdDuration
          @table[i+1][10] = @table[i+1][8] + @table[i+1][9]
          lastIndex = i+1
          first = false
        else
          if @table[i+1][7] > @table[lastIndex][10]
            @table[i+1][8] = m.m6/@velocidade + @table[i+1][7]
          else
            @table[i+1][8] = @table[lastIndex][10] + m.m6/@velocidade
          end
          @table[i+1][9] = m.bdDuration
          @table[i+1][10] = @table[i+1][9] + @table[i+1][8]
          lastIndex = i+1
        end
      end
    end
  end

  def saBack
    @decoyTable = Array.new(@height){Array.new(@width)}
    @height.times do |i|
      @width.times do |j|
        @decoyTable[i][j] = @table[i][j]
      end
    end

    firstBack = getMinimumSABack()
    while(firstBack)
      @table[firstBack[:index]+1][11] = @messages[firstBack[:index]].m7/@velocidade + @table[firstBack[:index]+1][firstBack[:column]]
      @table[firstBack[:index]+1][12] = @messages[firstBack[:index]].saOutDuration
      @table[firstBack[:index]+1][13] = @table[firstBack[:index]+1][firstBack[:column]] + @table[firstBack[:index]+1][12]
      firstBack = getMinimumSABack()
    end
  end

  def swBack
    @decoyTable = Array.new(@height){Array.new(@width)}
    @height.times do |i|
      @width.times do |j|
        @decoyTable[i][j] = @table[i][j]
      end
    end

    firstBack = getMinimumSWBack()
    while(firstBack)
      @table[firstBack[:index]+1][14] = @messages[firstBack[:index]].m8/@velocidade + @table[firstBack[:index]+1][firstBack[:column]]
      @table[firstBack[:index]+1][15] = @messages[firstBack[:index]].swOutDuration
      @table[firstBack[:index]+1][16] = @table[firstBack[:index]+1][firstBack[:column]] + @table[firstBack[:index]+1][15]
      firstBack = getMinimumSWBack()
    end
  end

  #funcao para retornar o menor tempo de retorno do SW
  def getMinimumSWBack
    array2 = []
    array3 = []
    @messages.each_with_index do |m, i|
      if m.interaction == 2
        array2 << {index:i, time:@decoyTable[i+1][7], column:7}
      elsif m.interaction == 3
        array3 << {index:i, time:@decoyTable[i+1][10], column:10}
      end
    end

    min2 = 99999
    h2 = nil
    array2.each do |a|
      if a[:time] < min2
        min2 = a[:time]
        h2 = a
      end
    end

    min3 = 99999
    h3 = nil
    array3.each do |a|
      if a[:time] < min3
        min3 = a[:time]
        h3 = a
      end
    end

    if min2 == 99999 && min3 == 99999
      return nil
    end

    if(h2.nil? && !h3.nil?)
      @decoyTable[h3[:index]+1][h3[:column]] = 99999
      return h3
    elsif(h3.nil? && !h2.nil?)
      @decoyTable[h2[:index]+1][h2[:column]] = 99999
      return h2
    end

    if (h2[:time] < h3[:time])
      @decoyTable[h2[:index]+1][h2[:column]] = 99999
      return h2
    else
      @decoyTable[h3[:index]+1][h3[:column]] = 99999
      return h3
    end
  end

  #funcao para retornar o menor tempo de retorno do SA
  def getMinimumSABack
    array3 = []
    @messages.each_with_index do |m, i|
      if m.interaction == 3
        array3 << {index:i, time:@decoyTable[i+1][10], column:10}
      end
    end

    min3 = 99999
    h3 = nil
    array3.each do |a|
      if a[:time] < min3
        min3 = a[:time]
        h3 = a
      end
    end
    if min3 == 9999
      return nil
    end
    @decoyTable[h3[:index]+1][h3[:column]] = 9999
    return h3
  end

  def tempoFinal
    @messages.each_with_index do |m, i|
      if m.interaction != 1
        c = 16
      else
        c = 4
      end
        @table[i+1][17] =  @table[i+1][c] + m.m2/@velocidade + m.requestDuration
    end
  end

end

msgs = ARGV[0] ? ARGV[0] : 250

s = Simulation.new(msgs)

File.open("simulacao.csv", 'w') { |file|
  s.table.each do |line|
    line.each do |c|
      file.write("#{c},")
    end
    file.write("\n")
  end }