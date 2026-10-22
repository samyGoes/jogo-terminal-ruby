require "json"
require 'rainbow/refinement'
using Rainbow
require "tty-prompt"
require "tty-font"
require_relative "Pocao"
require_relative "Livro"
require_relative "Irma"

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
      @espacos = $efeitos.espacos_ate_o_meio(@font.write("DIA   #{(self.dia + 1).to_s}"))
      @irma = Irma.new
      @livro = Livro.new
      @pocao = Pocao.new(@irma)
    end

    # Sistema gerenciador de diálogo.
    #
    # @return [void]
    def sistema_dialogo()
      @dados = $roteiro["dias"][self.dia][self.i_fala]

      if self.dia_1
        $efeitos.maquina_texto(@font.write("#{@espacos}DIA    " + (self.dia + 1).to_s).color("7209b7"), 0.0009 , false)
        self.dia_1 = false
      end

      # Atribuindo os valores contidos nas chaves "nome" e "mensagem" aos atributos "nome" e "mensagem"
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
        # Para quando só tiver uma resposta independente da escolha anterior do jogador
        if @dados["opcoes_i"][self.i_escolha[0]][self.i_escolha[1]].nil? 
          self.i_escolha[1] = 0  
        end
        self.mensagem = @dados["opcoes_i"][self.i_escolha[0]][self.i_escolha[1]]
        $efeitos.maquina_texto(self.mensagem)
        puts "\n"
      end

      # Verificando se o livro será aberto naquele momento
      if @dados.key?("livro") and @dados["livro"]
        @livro.livro_aberto = true
        if @livro.tutorial then  @livro.p_tutorial()  end

        loop do
          if @livro.livro_aberto == false then break end
          @livro.printa_pagina()
          @livro.mexe_no_livro()        
        end
      end

      # Verificando se é para fazer a poção naquele momento
      if @dados.key?("pocao") and @dados["pocao"]
        @p = @pocao.fazendo_pocao()
        if @p == :final then  self.final = true  end         
      end

      eventos(@dados)
      finais()

      # Quando acabar as falas do dia passa para o próximo dia
      if self.i_fala == self.qtd_falas 
        self.dia += 1   
        self.i_fala = 0
        sleep(0.8)
        $efeitos.maquina_texto(@font.write("#{@espacos}DIA    #{(self.dia + 1).to_s}").color("7209b7"), 0.0009 , false)
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
          # Se você escolheu pegar a página 3
          if dados.key?("evento") and self.i_escolha[0] == 1           
            if dados["evento"] == "pagina"
              # Você desbloqueia a página 3
              @livro.pag_3 = true
              # O livro vai abrir naquele momento só se você escolheu pegar a página 3               
              @i_evento = busca_evento("livro")
              $roteiro["dias"][self.dia][self.i_fala + @i_evento]["livro"] = true
            # Se o evento for o "errar base"
            elsif dados["evento"] == "errar base"
              # Você não poderá errar nenhuma etapa da poção
              @pocao.pode_errar = false  
              self.evento = dados["evento"]
            end
          end
        when 2 # DIA 3
          # Se você resolveu dar a chance a sua irmã de fazer alguma etapa da poção
          if dados.key?("evento") and self.i_escolha[0] == 0         
            if dados["evento"] == "fazer etapa"       
              # E essa etapa for a segunda etapa
              if self.i_escolha[1] == 0    
                # Ela vai errar e a poção terá que ser refeita, você não poderá errar.
                @pocao.pode_errar = false
              end
              # E essa etapa for a terceira etapa 
              if self.i_escolha[1] == 1
                @irma.faz_etapa = 3      
                @irma.conseguiu_fazer_etapa = true
              # E essa etapa for a quarta etapa 
              elsif self.i_escolha[1] == 2
                @irma.faz_etapa = 4
                @irma.conseguiu_fazer_etapa = true
              end                    
            end
          # Você não quis deixar sua irmã fazer nenhuma das etapas
          else
            @irma.pirraca = true
          end
        when 3 # DIA 4
          # Você vai ter que fazer a base
          @pocao.etapa = 1
          # Zerando o faz_etapa porque a irmã não vai fazer nenhuma
          @irma.faz_etapa = 0
        when 4 # DIA 5
          if dados.key?("evento") 
            if dados["evento"] == "irma fazer pocao"
              if @irma.fazer_pocao_completa() == 1
                # Ela vai pedir para fazer uma poção completa
                self.i_escolha[0] = 1
              else
                # Ela não vai pedir para fazer uma poção completa
                self.i_escolha[0] = 0
              end
            elsif dados["evento"] == "voce fazer pocao"     
              if self.i_escolha[0] == 1          
                case self.i_escolha[1] 
                  when 0  # Caso o jogador escolha confiar a poção completa a irmã
                    @i_evento = busca_evento("pocao")
                    $roteiro["dias"][self.dia][self.i_fala + @i_evento]["pocao"] = nil        
                  when 1  # Caso o jogador queira que a irmã faça apenas a base
                    @pocao.etapa = 2            
                  when 2  # Caso o jogador queira fazer a poção completa
                    @pocao.etapa = 1
                end
              end
            end
          end
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