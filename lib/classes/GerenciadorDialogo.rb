require "json"
require 'rainbow/refinement'
using Rainbow
require "tty-prompt"
require_relative "../modules/Efeitos"
require_relative "Pocao"
$efeitos = include Efeitos

$caminho_r = File.expand_path("../../data/roteiro.json", __dir__)
$roteiro = JSON.load_file($caminho_r)

$caminho_s = File.expand_path("../../data/salvamento.json", __dir__)
$salvamento = JSON.load_file($caminho_s)

class GerenciadorDialogo
    attr_accessor :i_fala
    attr_accessor :nome
    attr_accessor :mensagem
    attr_accessor :cena
    attr_accessor :i_escolha
    attr_accessor :qtd_falas

    def initialize()
      @prompt = TTY::Prompt.new
      @i_fala = $salvamento["i_fala"]
      @qtd_falas = $roteiro["cenas"][0].length - 1
    end

    # Sistema gerenciador de diálogo
    # 
    # @return [void]
    def sistema_dialogo()
      @dados = $roteiro["cenas"][0][@i_fala]
      # puts "qtd falas #{@qtd_falas}"
      # puts "i_fala #{@i_fala}"

      @nome, @mensagem = @dados.values_at("nome", "mensagem")

      # PRINTANDO A MENSAGEN
      if @mensagem != nil      
        # PRINTANDO O NOME DE QUEM MANDOU A MENSAGEM
        case @nome
          when "Amiga" then print @nome.color("5DB7DE") + " "   
          when "Jogador" then print @nome.color("9046FF") + " "       
        end

        $efeitos.maquina_texto(@mensagem)
        puts "\n"
      
      elsif @dados.dig("escolhas") 
        # CRIA UM SELECT COM SUAS ESCOLHAS DE RESPOSTA
        @nome = "Jogador".color("9046FF")
        @mensagem = @prompt.select(@nome, @dados["escolhas"],
                                    cycle: true,
                                    help: "Use as setas",
                                    active_color: :white)
        puts "\n"
        indice_msg("e")
        
      elsif @dados.dig("respostas") 
        # AMIGA RESPONDE DE ACORDO COM A SUA ESCOLHA ANTERIOR
        print @nome.color("5DB7DE") + " "
        @mensagem = @dados["respostas"][@i_escolha]
        $efeitos.maquina_texto(@mensagem)
        puts "\n"
        
      elsif @dados.dig("opcoes_j")
         # CRIA UM SELECT COM SUAS ESCOLHAS DE RESPOSTA BASEADAS NA RESPOTA DA SUA AMIGA
        @nome = "Jogador".color("9046FF")
        @mensagem = @prompt.select(@nome, @dados["opcoes_j"][@i_escolha]["escolhas"],
                                    cycle: true,
                                    help: "Use as setas",
                                    active_color: :white)
        puts "\n"
        indice_msg("o")

      elsif @dados.dig("opcoes_a")
         # AMIGA RESPONDE DE ACORDO COM A SUA ESCOLHA ANTERIOR
        print "Amiga ".color("5DB7DE")
        @mensagem = @dados["opcoes_a"][@i_escolha[0]]["respostas"][@i_escolha[1]]
        $efeitos.maquina_texto(@mensagem)
        puts "\n"
      end

      # Quando acabar as falas da cena cria o objeto Poção para iniciar o puzzle
      if @i_fala == @qtd_falas 
        @pocao = Pocao.new
        # Se a poção não está completa então chama a função de fazer a poção
        if $salvamento["pocao_completa"] == false
          @pocao.fazendo_pocao()            
        else
        #Poção está completa
          puts "Poção completa, ir para próxima cena"
        end
      else
        @i_fala = @i_fala + 1
        $salvamento["i_fala"] = @i_fala
        #puts "atributo id: #{@i_fala}"
        #puts "json id: #{$salvamento["i_fala"]}"
      end

      return
    end

    # Pega o índice da mensagem que o jogador escolheu e atribui ao atributo @i_escolha
    # 
    # return [void]
    def indice_msg(tipo)
      @i = 0
      
      if tipo == "e"
        while @dados["escolhas"][@i] != @mensagem
          @i = @i + 1
        end
        @i_escolha = @i

      elsif tipo == "o"
        while @dados["opcoes_j"][@i_escolha]["escolhas"][@i] != @mensagem
          @i = @i + 1
        end
        @i_escolha = [@i_escolha, @i]
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