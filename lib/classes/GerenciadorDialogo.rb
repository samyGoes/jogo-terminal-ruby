require "json"
require 'rainbow/refinement'
using Rainbow
require "tty-prompt"
require_relative "../modules/Efeitos"
require_relative "Pocao"
require_relative "Livro"
require "tty-font"
$efeitos = include Efeitos

caminho_r = File.expand_path("../../data/roteiro.json", __dir__)
$roteiro = JSON.load_file(caminho_r)

caminho_s = File.expand_path("../../data/salvamento.json", __dir__)
$save = JSON.load_file(caminho_s)

class GerenciadorDialogo
    attr_accessor :dia
    attr_accessor :nome
    attr_accessor :mensagem
    attr_accessor :qtd_falas
    attr_accessor :i_fala
    attr_accessor :i_escolha
    attr_accessor :final_pocao_errada
    attr_accessor :dia_1

    def initialize()
      @prompt = TTY::Prompt.new
      @font = TTY::Font.new(:doom)
      self.i_fala = $save["i_fala"]
      self.dia = $save["dia"]
      self.qtd_falas = $roteiro["dias"][self.dia].length - 1
      self.i_escolha = []
      self.final_pocao_errada = false
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
      
      elsif @dados.dig("escolhas") 
        # CRIA UM SELECT COM SUAS ESCOLHAS DE RESPOSTA
        self.mensagem = @prompt.select(self.nome.color("9046FF"), @dados["escolhas"],
                                        cycle: true,
                                        help: "Use as setas",
                                        active_color: :white)
        puts "\n"
        indice_msg("e")
        
      elsif @dados.dig("respostas") 
        # IRMÃ RESPONDE DE ACORDO COM A SUA ESCOLHA ANTERIOR
        print self.nome.color("5DB7DE") + " "
        self.mensagem = @dados["respostas"][self.i_escolha[0]]
        $efeitos.maquina_texto(self.mensagem)
        puts "\n"
        
      elsif @dados.dig("opcoes_j")
         # CRIA UM SELECT COM SUAS ESCOLHAS DE RESPOSTA BASEADAS NA RESPOTA DA SUA AMIGA
        self.mensagem = @prompt.select(self.nome.color("9046FF"), @dados["opcoes_j"][self.i_escolha[0]],
                                    cycle: true,
                                    help: "Use as setas",
                                    active_color: :white)
        puts "\n"
        indice_msg("o")

      elsif @dados.dig("opcoes_i")
        # IRMÃ RESPONDE DE ACORDO COM A SUA ESCOLHA ANTERIOR
        print self.nome.color("5DB7DE") + " "
        self.mensagem = @dados["opcoes_i"][self.i_escolha[0]][self.i_escolha[1]]
        $efeitos.maquina_texto(self.mensagem)
        puts "\n"
      end

      # Verificando se o livro será abertado naquele momento
      if @dados.dig("livro")
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
      if @dados.dig("pocao")
        @pocao = Pocao.new
        @p = @pocao.fazendo_pocao()
        if @p == :final then  self.final_pocao_errada = true  end            
        #puts "retorno: #{@p}"
      end

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