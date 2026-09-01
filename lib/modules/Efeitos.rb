module Efeitos

  def maquina_texto(texto, velocidade = 0.02)
    texto.each_char do |char|
      print char
      #$stdout.flush
      sleep velocidade
    end
    puts #pula linha pro próximo texto
  end

end

