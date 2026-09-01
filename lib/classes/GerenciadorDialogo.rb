require "json"
require "pastel"
require "tty-prompt"
require_relative "../modules/Efeitos"
$efeitos = include Efeitos

$caminho_r = File.expand_path("../../data/roteiro.json", __dir__)
$roteiro = JSON.load_file($caminho_r)

$caminho_s = File.expand_path("../../data/salvamento.json", __dir__)
$salvamento = JSON.load_file($caminho_s)

class GerenciadorDialogo
    attr_accessor :id
    attr_accessor :nome
    attr_accessor :mensagem
    attr_accessor :cena
    attr_accessor :i_escolha

    def initialize()
      @id = $salvamento["id"]
    end

    # Sistema gerenciador de diálogo
    # 
    # @return [void]
    def sistema_dialogo()
      @dados = $roteiro["cenas"][0][@id]
      @pastel = Pastel.new
      @prompt = TTY::Prompt.new

      @nome, @mensagem = @dados.values_at("nome", "mensagem")

      # PRINTANDO A MENSAGEN
      if @mensagem != nil      
        # PRINTANDO O NOME DE QUEM MANDOU A MENSAGEM
        case @nome
          when "Amiga" then print @pastel.magenta(@nome) + " "   
          when "Jogador" then print @pastel.cyan(@nome) + " "       
        end

        $efeitos.maquina_texto(@mensagem)
        puts "\n"
      
      elsif @dados.dig("escolhas") 
        # CRIA UM SELECT COM SUAS ESCOLHAS DE RESPOSTA
        @nome = @pastel.cyan("Jogador")
        @mensagem = @prompt.select(@nome, @dados["escolhas"],
                       cycle: true,
                       help: "Use as setas",
                       active_color: :white)
        puts "\n"
        indice_msg("e")
        
      elsif @dados.dig("respostas") 
        # AMIGA RESPONDE DE ACORDO COM A SUA ESCOLHA ANTERIOR
        print @pastel.magenta(@nome) + " "
        @mensagem = @dados["respostas"][@i_escolha]
        $efeitos.maquina_texto(@mensagem)
        puts "\n"
        
      elsif @dados.dig("opcoes_j")
         # CRIA UM SELECT COM SUAS ESCOLHAS DE RESPOSTA BASEADAS NA RESPOTA DA SUA AMIGA
        @nome = @pastel.cyan("Jogador")
        @mensagem = @prompt.select(@nome, @dados["opcoes_j"][@i_escolha]["escolhas"],
                      cycle: true,
                      help: "Use as setas",
                      active_color: :white)
        puts "\n"
        indice_msg("o")

      elsif @dados.dig("opcoes_a")
         # AMIGA RESPONDE DE ACORDO COM A SUA ESCOLHA ANTERIOR
        print @pastel.magenta("Amiga ")
        @mensagem = @dados["opcoes_a"][@i_escolha[0]]["respostas"][@i_escolha[1]]
        $efeitos.maquina_texto(@mensagem)
        puts "\n"
      end
      @id = @id + 1
      $salvamento["id"] = @id
      #print "atributo id: ", @id, "\n"
      #print "json id: ", $salvamento["id"] = @id, "\n"
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