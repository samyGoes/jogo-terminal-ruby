module Efeitos

  def maquina_texto(texto, velocidade = 0.05)
    @txt_l = texto.length

    if @txt_l < 6 then velocidade = 0.09
    elsif @txt_l > 20 then velocidade = 0.02
    end

    texto.each_char do |char|
      print char
      #$stdout.flush
      sleep velocidade
    end
    puts #pula linha pro próximo texto
  end

end

