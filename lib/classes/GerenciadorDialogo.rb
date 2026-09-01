require "json"
require "pastel"
require "tty-prompt"

$caminho_r = File.expand_path("../../data/roteiro.json", __dir__)
$roteiro = JSON.load_file($caminho_r)

$caminho_s = File.expand_path("../../data/salvamento.json", __dir__)
$salvamento = JSON.load_file($caminho_s)

class GerenciadorDialogo
    attr_accessor :id
    attr_accessor :nome
    attr_accessor :mensagem
    attr_accessor :cena

    def initialize()
      @id = $salvamento["id"]
    end

    def sistema_dialogo()
      @dados = $roteiro["cenas"][0][@id]
      @pastel = Pastel.new
      @prompt = TTY::Prompt.new

      @nome, @mensagem = @dados.values_at("nome", "mensagem")

      case @nome
        when "Amiga" then print @pastel.blue(@nome) + " \n"   
        when "Jogador" then print @pastel.green(@nome) + " \n"       
      end

      puts @mensagem
      @id = @id + 1
      $salvamento["id"] = @id
        
      if $roteiro.dig("cenas", 0, @id, "escolhas")
        @nome = "Jogador"
        print @pastel.green(@nome) + " \n"  
        @prompt.select("", $roteiro["cenas"][0][@id]["escolhas"],
                       cycle: true,
                       help: "Use as setas",
                       active_color: :white)
      end
 
      #print "atributo id: ", @id, "\n"
      #print "json id: ", $salvamento["id"] = @id, "\n"
      
    end

    def salva_dados(caminho, arquivo)
      File.open(caminho, "w") do |f|
        f.write(JSON.pretty_generate(arquivo))
      end
    end
end