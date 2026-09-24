require "json"
require "tty-box"
require "io/console"
require 'rainbow/refinement'
using Rainbow

caminho_l = File.expand_path("../../data/livro_pocoes.json", __dir__)
$livro = JSON.load_file(caminho_l)

class Livro
    attr_accessor :pag_atual
    attr_accessor :livro_aberto
    attr_accessor :altura_pag
    attr_accessor :pag_3
    attr_accessor :tutorial

    def initialize()
      self.pag_atual = 0
      self.livro_aberto = false
      self.altura_pag = 15
      self.pag_3 = false
      self.tutorial = $salvamento["livro_tutorial"]
    end

    # Printa a página atual do livro.
    #
    # @return [void]
    def printa_pagina()
      if self.livro_aberto
        case self.pag_atual
          when 0 # Página 1
            @pag_1 = $livro["pocoes"][0]
            @pocoes = ""
            @box = TTY::Box.frame(width: TTY::Screen.width, height: self.altura_pag, padding: [1,2], title: {top_left: "LIVRO DE POÇÕES", bottom_right: "pag 1"}) do
              
              # Pegando as informações de cada poção da página 1
              0.upto(@pag_1.length - 1) do | i |
                @titulo = espacos(alinhamento(0, @pag_1[i]["nome"])[1]) + "  Base    2° Etapa    3° Etapa \n\n"

                @pocoes += 
                @pag_1[i]["nome"] + espacos(alinhamento(0, @pag_1[i]["nome"])[0]) + "   " + "   ".bg(@pag_1[i]["cores"][0]) + "   " +
                @pag_1[i]["etapa-2"][0].bg(@pag_1[i]["cores"][1]) + " " +
                @pag_1[i]["etapa-2"][1].bg(@pag_1[i]["cores"][2]) + " " +
                @pag_1[i]["etapa-2"][2].bg(@pag_1[i]["cores"][3]) + "   " +
                @pag_1[i]["etapa-3"].bg(@pag_1[i]["cores"][4]).color("000000") + "\n\n"
              end
              # Variável com toda a string sobre as poções para o box
              @titulo + @pocoes
            end

            print @box
            puts
            # Subindo o cursor até o topo da pagina
            IO.console.cursor_up(self.altura_pag + 1)
          when 1 # Página 2
            @pag_2 = $livro["pocoes"][1]
            @info = ""
            @box = TTY::Box.frame(width: TTY::Screen.width, height: self.altura_pag, padding: [1,2], title: {top_left: "LIVRO DE POÇÕES", bottom_right: "pag 2"}) do
              2.times do | i | 
                @info += @pag_2[i]["titulo"] + @pag_2[i]["desc"] + "\n\n"
              end

              0.upto(@pag_2[2]["simbolos"].length - 1) do | i |
                @info += @pag_2[2]["simbolos"][i] + "\n"
              end

              # Variável com toda a string sobre as poções para o box
              @info
            end

            print @box
            puts
            # Subindo o cursor até o topo da pagina
            IO.console.cursor_up(self.altura_pag + 1)
          when 2 # Página 3
            @pag_3 = $livro["pocoes"][2]
            @info = ""
            @box = TTY::Box.frame(width: TTY::Screen.width, height: self.altura_pag, padding: [1,2], title: {top_left: "LIVRO DE POÇÕES", bottom_right: "pag 3"}) do
              @p = 0
              0.upto(@pag_3.length - 1) do | i |
                @p += 1
                if @p == 6 
                  @info += @pag_3[i] + "\n"
                  @p = 0
                else
                  @info += @pag_3[i] + "    "
                end
              end
              # Variável com toda a string sobre as poções para o box
              @info
            end

            print @box
            puts
            # Subindo o cursor até o topo da pagina
            IO.console.cursor_up(self.altura_pag + 1)
          when 3 # Página 4
            @pag_4 = $livro["pocoes"][3]
            @pocoes = ""
            @box = TTY::Box.frame(width: TTY::Screen.width, height: self.altura_pag, padding: [1,2],title: {top_left: "LIVRO DE POÇÕES", bottom_right: "pag 4"}) do
              # Pegando as informações de cada poção da página 4
              0.upto(@pag_4.length - 1) do | i |
                @pocoes += 
                @pag_4[i]["nome"] + espacos(alinhamento(3, @pag_4[i]["nome"])[0]) + "   " + 
                @pag_4[i]["etapa-1"].bg(@pag_4[i]["cor"]) + "\n\n"
              end
              # Variável com toda a string sobre as poções para o box
              @pocoes
            end
            print @box
            puts
            # Subindo o cursor até o topo da pagina
            IO.console.cursor_up(self.altura_pag + 1)
        end
      end
    end

    # Opções para mudar de página e fechar o livro.
    # 
    # @return [void]
    def mexe_no_livro()
      #Pega qual tecla foi digitada
      @tecla = STDIN.getch 
      # Se clicar no esc fecha o livro
      if @tecla == "\e" 
        self.livro_aberto = false
        limpa_linhas(self.altura_pag + 2)
      
      # Voltando uma página
      elsif @tecla == "a" 
        self.pag_atual = self.pag_atual - 1
        # Garantindo que não seja menor que zero
        if self.pag_atual < 0  then  self.pag_atual = 0  end

        # Ignorando a terceira página se ela não estiver disponível
        if self.pag_atual == 2 && self.pag_3 == false
          self.pag_atual = 1
        end

      # Indo para próxima página
      elsif @tecla == "d" 
        self.pag_atual = self.pag_atual + 1
        # Garantindo que não seja maior que 3
        if self.pag_atual > 3  then  self.pag_atual = 3  end

        # Ignorando a terceira página se ela não estiver disponível
        if self.pag_atual == 2 && self.pag_3 == false
          self.pag_atual = 3
        end
      end

      # Para que o tutorial rode uma única vez
      $salvamento["livro_tutorial"] = false
    end

    # Printa uma explicação de como mexer no livro.
    #
    # @return [void]
    def p_tutorial()
      puts " Esc para sair do livro. \n A e D para mudar de página.\n".color("858585")
    end


    private

    # Verifica o maior nome de poção do livro e retorna a diferença de caracteres entre
    # ele e o nome do parâmetro.
    #
    # @param pag [Integer] Índice da página do JSON que irá buscar o nome
    #
    # @param nome [String] Nome que será comparado
    #
    # @return [Integer] 
    def alinhamento(pag, nome)
      @nome_maior = 0
      @espaco = 0

      0.upto($livro["pocoes"][pag].length - 1) do | i |
        @atual_nome_p = $livro["pocoes"][pag][i]["nome"].length
        
        # Evitando de acessar um valor nulo
        if $livro["pocoes"][pag][i + 1] == nil 
          break
        else
          # Acessando o nome posterior ao atual
          @prox_nome_p = $livro["pocoes"][pag][i + 1]["nome"].length

          if @atual_nome_p > @prox_nome_p
            @nome_maior = @atual_nome_p
          else
            @nome_maior = @prox_nome_p
          end
        end
      end

      @espaco = @nome_maior - nome.length
      #puts "\n Nome maior: #{@nome_maior} \n Nome param: #{nome.length} \n Espaços necessários: #{@espaco}"
      return [@espaco, @nome_maior]
    end

    # Preenche uma variável com determinada quantidade de espaços em branco.
    # 
    # @param qtd [Integer] Quantidade de espaços
    #
    # @return [String]
    def espacos(qtd)
      @espacos = ""
      qtd.times do  @espacos += " "  end
      return @espacos
    end

    # Limpa determinada quantidade de linhas.
    #
    # @param qtd [Integer] Quantidade de linhas 
    #
    # @return [void]
    def limpa_linhas(qtd)
      # Para apagar o tutorial
      if self.tutorial then  IO.console.cursor_up(3)  end
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
    
end