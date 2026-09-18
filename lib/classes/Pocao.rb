require "tty-prompt"
require "json"

caminho = File.expand_path("../../data/livro_pocoes.json", __dir__)
$livro_p = JSON.load_file(caminho)

class Pocao
  attr_accessor :etapa

  def initialize()
    @etapa = 2
    @prompt = TTY::Prompt.new
    @pocao_completa = false
  end

  def fazendo_pocao()
    case @etapa
      when 2
          @resp = @prompt.ask("#{$livro_p["pocoes"][0][0]["nome"]} [2° Etapa]:")
          # Se a resposta do jogador for igual a resposta do puzzle
          if @resp.to_i == $livro_p["resp_puzzle"][0][0]
            @etapa = 3
            fazendo_pocao
          else 
            puts "Hm... acho que não é bem isso."
            fazendo_pocao()
          end
      when 3
          @resp = @prompt.ask("#{$livro_p["pocoes"][0][0]["nome"]} [3° Etapa]:")
          if @resp.to_i == $livro_p["resp_puzzle"][0][1]
            @etapa = 4
            fazendo_pocao
          else 
            puts "Hm... acho que não é bem isso."
            fazendo_pocao()
          end   
      when 4 
          @resp = @prompt.select($livro_p["pocoes"][3][0]["nome"], $livro_p["pocoes"][3][0]["opcoes_resp"])
          if @resp == $livro_p["resp_puzzle"][0][2]
            $salvamento["pocao_completa"] = true
            return
          else
            puts "Hm... acho que não é bem isso."
            fazendo_pocao()
          end
    end
  end
end