require "io/console"

module Efeitos

  # Printa um texto caractere por caractere (como se estivesse digitando).
  # 
  # @param texto [String] O texto a ser escrito
  # @param velocidade [Number] Tempo que demorará para escrever o próximo caractere
  # @return [void]
  def maquina_texto(texto, velocidade = 0.05)
    @txt_l = texto.length
    @caractere = nil

    # Ajuste da velocidade que o texto aparece de acordo com a qtd de caracteres
    if @txt_l < 6 then velocidade = 0.09
    elsif @txt_l > 20 then velocidade = 0.02
    end

    # Printando o texto
    texto.each_char.with_index do |char, i|
      
      # Quando já tiver três caracteres ou mais printados e clicar em alguma tecla
      if i >= 3 and IO.select([$stdin], nil, nil, 0)
        @caractere = STDIN.getch #Pega qual tecla foi
      end
      
      # Se a tecla clicada for enter ou espaço printa o restante do texto inteiro
      if @caractere == "\r" or @caractere == " "
        print @restante_txt = texto[i, @txt_l]
        break
      end
      print char # Printa o caractere atual 
      sleep velocidade # Espera certo tempo até o programa continuar
    end
    puts # Pula linha pro próximo texto
  end

end

