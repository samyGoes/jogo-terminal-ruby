require "json"
require 'rainbow/refinement'
using Rainbow
require "tty-prompt"
require "tty-font"
require_relative "Pocao"
require_relative "Livro"

class GerenciadorDialogo
    attr_accessor :dia
    attr_accessor :nome
    attr_accessor :mensagem
    attr_accessor :qtd_falas
    attr_accessor :i_fala
    attr_accessor :i_escolha
    attr_accessor :final
    attr_accessor :dia_1
    attr_accessor :evento

    def initialize()
      @prompt = TTY::Prompt.new(quiet: true)
      @font = TTY::Font.new(:doom)
      self.i_fala = $save["i_fala"]
      self.dia = $save["dia"]
      self.qtd_falas = $roteiro["dias"][self.dia].length - 1
      self.i_escolha = []
      self.final = false
      self.dia_1 = true
    end

    # Sistema gerenciador de diálogo.
    #
    # @return [void]
    def sistema_dialogo()
      @dados = $roteiro["dias"][self.dia][self.i_fala]

      if self.dia_1
        $efeitos.maquina_texto(@font.write("  DIA    " + (self.dia + 1).to_s).color("7209b7"), 0.0009 , false)
        self.dia_1 = false
      end

      # Atribuindo vo valores contidos nas chaves "nome" e "mensagem" aos atributos "nome" e "mensagem"
      self.nome, self.mensagem = @dados.values_at("nome", "mensagem")

      # PRINTANDO A MENSAGEN E OS NOMES
      if self.mensagem != nil      
        # PRINTANDO O NOME DE QUEM MANDOU A MENSAGEM
        case self.nome
          when "Irmã" then print self.nome.color("5DB7DE") + " "   
          when "Você" then print self.nome.color("9046FF") + " "       
        end

        # Verificando se o valor do atributo "mensagem" é um array ou não
        if self.mensagem.is_a?(Array)
          # Verificando se é um array 2d
          if self.mensagem.any?(Array)
            $efeitos.maquina_texto(self.mensagem[self.i_escolha[0]][self.i_escolha[1]])
          # ou um array 1d
          else
            $efeitos.maquina_texto(self.mensagem[self.i_escolha[0]])
          end
        # Se for apenas uma String
        else
          $efeitos.maquina_texto(self.mensagem)
        end
        puts "\n"
      
      elsif @dados.key?("escolhas") 
        # CRIA UM SELECT COM SUAS ESCOLHAS DE RESPOSTA
        self.mensagem = @prompt.select(self.nome.color("9046FF"), @dados["escolhas"], 
                                        cycle: true, 
                                        help: "Use as setas", 
                                        active_color: ->(str) { (str).color("9046FF") },
                                        symbols: { marker: "" })
        # Deixando o cursor oculto
        $stdout.print "\e[?25l"
        print self.nome.color("9046FF") + " "
        $efeitos.maquina_texto(self.mensagem)
        puts "\n"
        indice_msg("e")
        
      elsif @dados.key?("respostas") 
        # IRMÃ RESPONDE DE ACORDO COM A SUA ESCOLHA ANTERIOR
        print self.nome.color("5DB7DE") + " "
        self.mensagem = @dados["respostas"][self.i_escolha[0]]
        $efeitos.maquina_texto(self.mensagem)
        puts "\n"
        
      elsif @dados.key?("opcoes_j")
         # CRIA UM SELECT COM SUAS ESCOLHAS DE RESPOSTA BASEADAS NA RESPOTA DA SUA AMIGA
        self.mensagem = @prompt.select(self.nome.color("9046FF"), @dados["opcoes_j"][self.i_escolha[0]],
                                    cycle: true,
                                    help: "Use as setas",
                                    active_color: ->(str) { (str).color("9046FF") },
                                    symbols: { marker: "" })
        # Deixando o cursor oculto
        $stdout.print "\e[?25l"
        print self.nome.color("9046FF") + " "
        $efeitos.maquina_texto(self.mensagem)
        puts "\n"
        indice_msg("o")

      elsif @dados.key?("opcoes_i")
        # IRMÃ RESPONDE DE ACORDO COM A SUA ESCOLHA ANTERIOR
        print self.nome.color("5DB7DE") + " "
        self.mensagem = @dados["opcoes_i"][self.i_escolha[0]][self.i_escolha[1]]
        $efeitos.maquina_texto(self.mensagem)
        puts "\n"
      end

      # Verificando se o livro será abertado naquele momento
      if @dados.key?("livro")
        @livro = Livro.new
        @livro.livro_aberto = true
        if @livro.tutorial then  @livro.p_tutorial()  end

        loop do
          if @livro.livro_aberto == false then break end
          @livro.printa_pagina()
          @livro.mexe_no_livro()        
        end
      end

      # Verificando se é para fazer a poção naquele momento
      if @dados.key?("pocao")
        @pocao = Pocao.new
        @p = @pocao.fazendo_pocao()
        if @p == :final then  self.final = true  end            
        #puts "retorno: #{@p}"
      end

      eventos(@dados)
      finais()

      # Quando acabar as falas do dia passa para o próxima dia
      if self.i_fala == self.qtd_falas 
        self.dia += 1   
        self.i_fala = 0
        sleep(0.8)
        $efeitos.maquina_texto(@font.write("  DIA   " + (self.dia + 1).to_s).color("7209b7"), 0.0009 , false)
      # Ainda não acabou as falas do dia, então passa pra próxima fala 
      else
        self.i_fala += 1
      end

      salva_dados()
      return
    end
    
    
    private 

    # Para cada dia do jogo, configura os eventos que irão ocorrer.
    #
    # @param dados [Hash] Passar a variável @dados do método sistema_dialogo.
    #
    # @return [void]
    def eventos(dados)
      case self.dia
        when 1 # DIA 2
          # Se a chave 'evento' existir no objeto atual e sua escolha for a resposta de índice 1
          if dados.key?("evento") and self.i_escolha[0] == 1           
            if dados["evento"] == "pagina"        # E se o evento for o de "pagina"
              $save["pag_3"] = true               # Você desbloqueia a página 3
              @i_evento = busca_evento("livro")
              $roteiro["dias"][self.dia][self.i_fala + @i_evento]["livro"] = true
            # Se o evento for o "errar base"
            elsif dados["evento"] == "errar base"
              $save["pode_errar_pocao"] = false   # Você não poderá errar nenhuma etapa da poção
              self.evento = dados["evento"]
            end
          end
        when 2 # DIA 3

        when 3 # DIA 4
        
        when 4 # DIA 5
      end
    end

    # Verifica se determinada chave existe dentro do objeto.
    #
    # @param chave [String] Chave que será buscada no objeto.
    #
    # @return [Integer] Retorna o índice do objeto em que a chave está.
    def busca_evento(chave)
      @i = 1
      while $roteiro["dias"][self.dia][self.i_fala + @i].key?(chave) == false
        @i += 1
      end
      return @i
    end

    # Atribui um final específico com base no evento.
    #
    # @return [void]
    def finais()
      if self.final
        if self.evento == "errar base"
          $efeitos.maquina_texto($roteiro["finais"][1][1])
          $save["finais_coletados"].push($roteiro["finais"][1][0])
        else
          $efeitos.maquina_texto($roteiro["finais"][0][1])
          $save["finais_coletados"].push($roteiro["finais"][0][0])
        end
      end
    end

    # Pega o índice da mensagem que o jogador escolheu e atribui ao atributo self.i_escolha.
    #
    # @param tipo [String] "e" para a chave "escolhas" e "o" para a chave "opcoes_j". Cada uma possui um laço diferente para acessar o índice
    #
    # return [void]
    def indice_msg(tipo)
      @i = 0
      
      if tipo == "e"
        while @dados["escolhas"][@i] != self.mensagem
          @i = @i + 1
        end
        self.i_escolha[0] = @i

      elsif tipo == "o"
        while @dados["opcoes_j"][self.i_escolha[0]][@i] != self.mensagem
          @i = @i + 1
        end
        self.i_escolha[1] = @i
      else
        puts "Valor inválido"
      end
    end

    def salva_dados()
      $save["dia"] = self.dia
      $save["i_fala"] = self.i_fala
    end

    # def cria_save(caminho, arquivo)
    #   File.open(caminho, "w") do |f|
    #     f.write(JSON.pretty_generate(arquivo))
    #   end
    # end
end