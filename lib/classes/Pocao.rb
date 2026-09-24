require "tty-prompt"
require "json"

class Pocao
  attr_accessor :etapa
  attr_accessor :pocao_atual
  attr_accessor :pocao_completa

  def initialize()
    @prompt = TTY::Prompt.new
    self.etapa = 2
    self.pocao_completa = $salvamento["pocao_completa"]
    self.pocao_atual = $salvamento["pocao_atual"]
  end

  # Puzzle das poções. Abre as opções pro jogador responder e selecionar respostas da poção atual.
  #
  # @return [void]
  def fazendo_pocao()
    case self.etapa
      when 2
          # Desocultando cursor
          $stdout.print "\e[?25h"
          @resp = @prompt.ask("#{$livro["pocoes"][0][self.pocao_atual]["nome"]} [2° Etapa]:")
          puts "\n"
          # Se a resposta do jogador for igual a resposta do puzzle
          if @resp.to_i == $livro["resp_puzzle"][self.pocao_atual][0]
            self.etapa = 3
            fazendo_pocao()
          else 
            puts "Hm... acho que não é bem isso."
            puts "\n"
            fazendo_pocao()
          end
      when 3
          # Desocultando cursor
          $stdout.print "\e[?25h"
          @resp = @prompt.ask("#{$livro["pocoes"][0][self.pocao_atual]["nome"]} [3° Etapa]:")
          puts "\n"
          if @resp.to_i == $livro["resp_puzzle"][self.pocao_atual][1]
            self.etapa = 4
            fazendo_pocao()
          else 
            puts "Hm... acho que não é bem isso."
            puts "\n"
            fazendo_pocao()
          end   
      when 4 
          # Ocultando cursor
          $stdout.print "\e[?25l"

          @pocoes_2 = []
          @indice_pocao_escolhida = 0

          # Guardando os nomes das poções da página 4
          ($livro["pocoes"][3].length).times do | i |
            @pocoes_2[i] = $livro["pocoes"][3][i]["nome"]        
          end
          
          # Select para escolher qual poção você quer combinar com a anterior
          #puts "Vetor pocoes_2: #{@pocoes_2}\n"
          @pocao_escolhida = @prompt.select("Qual poção deseja combinar? ", @pocoes_2)
          puts "\n"

          # Pegando o índice da poção escolhida
          ($livro["pocoes"][3].length).times do | i |
            if @pocao_escolhida == $livro["pocoes"][3][i]["nome"]
              @indice_pocao_escolhida = i
            end
          end

          # Select para escolher a resposta da poção selecionada
          @resp = @prompt.select(@pocao_escolhida, $livro["pocoes"][3][@indice_pocao_escolhida]["opcoes_resp"])
          puts "\n"
          if @resp == $livro["resp_puzzle"][self.pocao_atual][2]
            $salvamento["pocao_completa"] = true
            $salvamento["pocao_atual"] += 1
            return
          else
            puts "Hm... acho que não é bem isso."
            puts "\n"
            fazendo_pocao()
          end
    end
  end
end