require "io/console"

module Efeitos

  # Printa um texto caractere por caractere (como se estivesse digitando).
  #
  # @param texto [String] O texto a ser escrito
  #
  # @param velocidade [Number] Tempo que demorará para escrever o próximo caractere
  #
  # @return [void]
  def maquina_texto(texto, velocidade = 0.05, txt_comum = true)
    @txt_l = texto.length
    @caractere = nil

    if txt_comum
      # Ajuste da velocidade que o texto aparece de acordo com a qtd de caracteres
      if @txt_l < 6 then velocidade = 0.09
      elsif @txt_l > 20 then velocidade = 0.02
      end
    end
    # Printando o texto
    texto.each_char.with_index do |char, i|
      
      # Quando já tiver três caracteres ou mais printados e clicar em alguma tecla
      if i >= 3 and IO.select([$stdin], nil, nil, 0)
        @caractere = STDIN.getch #Pega qual tecla foi
      end
      
      if txt_comum
        # Se a tecla clicada for enter ou espaço printa o restante do texto inteiro
        if @caractere == "\r" or @caractere == " "
          print @restante_txt = texto[i, @txt_l]
          break
        end
      end

      print char # Printa o caractere atual 
      sleep velocidade # Espera certo tempo até o programa continuar
    end
    puts # Pula linha pro próximo texto
  end

  # Limpa determinada quantidade de linhas.
  #
  # @param tutorial [Boolean] Caso seja usado para apagar o tutorial do livro.
  #
  # @param qtd [Integer] Quantidade de linhas 
  #
  # @return [void]
  def limpa_linhas(tutorial, qtd)
    # Para apagar o tutorial do livro
    if tutorial then  IO.console.cursor_up(3)  end
    # Limpando a linha atual
    $stdout.print "\e[K"        
    qtd.times do
      # Movendo o cursor 1 linha para baixo
      IO.console.cursor_down(1)  
      # Limpando o texto da linha
      $stdout.print "\e[K"        
    end
    # Subindo todas as linhas
    IO.console.cursor_up(qtd)
  end

  # Calcula quantas colunas serão preenchidas de espaços em branco para que o texto seja printado no meio do terminal (não printa). 
  #
  # @param [String] txt Texto que deseja calcular.
  #
  # @param [Boolean] font Caso esteja usando a gem Font. Por padrão é true.
  #
  # @return [String] Retorna a quantidade de espaços.
  def espacos_ate_o_meio(txt, font = true)
    @centro_tela = IO.console.winsize[1] / 2
    @espacos = ""
  
    # Se estiver usando uma fonte
    if font 
      @altura_font = 8
      @largura_font = (txt.length / @altura_font).ceil
      @centro_txt = @largura_font / 2     
    else  
      @centro_txt = txt.length / 2  
    end
    
    # - 1 por causa da barra de rolagem do temrinal
    @p_meio = @centro_tela - @centro_txt - 1

    @p_meio.times do
      @espacos += " "
    end

    return @espacos
  end

end

