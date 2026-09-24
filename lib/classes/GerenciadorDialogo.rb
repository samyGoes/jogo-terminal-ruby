require "json"
require 'rainbow/refinement'
using Rainbow
require "tty-prompt"
require_relative "../modules/Efeitos"
require_relative "Pocao"
require_relative "Livro"
$efeitos = include Efeitos

caminho_r = File.expand_path("../../data/roteiro.json", __dir__)
$roteiro = JSON.load_file(caminho_r)

caminho_s = File.expand_path("../../data/salvamento.json", __dir__)
$salvamento = JSON.load_file(caminho_s)

class GerenciadorDialogo
    attr_accessor :i_fala
    attr_accessor :nome
    attr_accessor :mensagem
    attr_accessor :cena
    attr_accessor :i_escolha
    attr_accessor :qtd_falas
    attr_accessor :pode_abrir_livro

    def initialize()
      @pode_abrir_livro = true
      @prompt = TTY::Prompt.new
      self.i_fala = $salvamento["i_fala"]
      self.qtd_falas = $roteiro["cenas"][0].length - 1
    end

    # Sistema gerenciador de diálogo.
    #
    # @return [void]
    def sistema_dialogo()
      @dados = $roteiro["cenas"][0][self.i_fala]
      # puts "qtd falas #{self.qtd_falas}"
      # puts "i_fala #{self.i_fala}"

      self.nome, self.mensagem = @dados.values_at("nome", "mensagem")

      # PRINTANDO A MENSAGEN
      if self.mensagem != nil      
        # PRINTANDO O NOME DE QUEM MANDOU A MENSAGEM
        case self.nome
          when "Irmã" then print self.nome.color("5DB7DE") + " "   
          when "Você" then print self.nome.color("9046FF") + " "       
        end

        $efeitos.maquina_texto(self.mensagem)
        puts "\n"
      
      elsif @dados.dig("escolhas") 
        # CRIA UM SELECT COM SUAS ESCOLHAS DE RESPOSTA
        #self.nome = "Você".color("9046FF")
        self.mensagem = @prompt.select(self.nome.color("9046FF"), @dados["escolhas"],
                                    cycle: true,
                                    help: "Use as setas",
                                    active_color: :white)
        puts "\n"
        indice_msg("e")
        
      elsif @dados.dig("respostas") 
        # IRMÃ RESPONDE DE ACORDO COM A SUA ESCOLHA ANTERIOR
        print self.nome.color("5DB7DE") + " "
        self.mensagem = @dados["respostas"][self.i_escolha]
        $efeitos.maquina_texto(self.mensagem)
        puts "\n"
        
      elsif @dados.dig("opcoes_j")
         # CRIA UM SELECT COM SUAS ESCOLHAS DE RESPOSTA BASEADAS NA RESPOTA DA SUA AMIGA
        self.nome = "Você".color("9046FF")
        self.mensagem = @prompt.select(self.nome, @dados["opcoes_j"][self.i_escolha]["escolhas"],
                                    cycle: true,
                                    help: "Use as setas",
                                    active_color: :white)
        puts "\n"
        indice_msg("o")

      elsif @dados.dig("opcoes_i")
         # AMIGA RESPONDE DE ACORDO COM A SUA ESCOLHA ANTERIOR
        print "Irmã ".color("5DB7DE")
        self.mensagem = @dados["opcoes_i"][self.i_escolha[0]]["respostas"][self.i_escolha[1]]
        $efeitos.maquina_texto(self.mensagem)
        puts "\n"
      end

      # Quando acabar as falas da cena cria o objeto Poção para iniciar o puzzle
      if self.i_fala == self.qtd_falas 
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
        @pode_abrir_livro = true
        #@pocao = Pocao.new
        # Se a poção não está completa então chama a função de fazer a poção
        if $salvamento["pocao_completa"] == false
          #@pocao.fazendo_pocao()            
        else
        #Poção está completa
          puts "Poção completa, ir para próxima cena"
        end
      else
        self.i_fala = self.i_fala + 1
        $salvamento["i_fala"] = self.i_fala
        #puts "atributo id: #{self.i_fala}"
        #puts "json id: #{$salvamento["i_fala"]}"
      end

      return
    end
    
    private 

    # Pega o índice da mensagem que o jogador escolheu e atribui ao atributo self.i_escolha.
    #
    # return [void]
    def indice_msg(tipo)
      @i = 0
      
      if tipo == "e"
        while @dados["escolhas"][@i] != self.mensagem
          @i = @i + 1
        end
        self.i_escolha = @i

      elsif tipo == "o"
        while @dados["opcoes_j"][self.i_escolha]["escolhas"][@i] != self.mensagem
          @i = @i + 1
        end
        self.i_escolha = [self.i_escolha, @i]
      else
        puts "Valor inválido"
      end
    end

    def salva_dados(caminho, arquivo)
      File.open(caminho, "w") do |f|
        f.write(JSON.pretty_generate(arquivo))
      end
    end
end