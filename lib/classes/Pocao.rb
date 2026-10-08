require "tty-prompt"
require "json"
require_relative "Livro"
require "io/console"
require "rainbow/refinement"
using Rainbow

class Pocao
  attr_accessor :etapa
  attr_accessor :pocao_atual
  attr_accessor :chances
  attr_accessor :pode_errar

  def initialize()
    @prompt = TTY::Prompt.new
    self.etapa = 2
    self.pocao_atual = $save["pocao_atual"]
    self.chances = $save["chances"]
    self.pode_errar = $save["pode_errar_pocao"]
  end

  # Puzzle das poções. Abre as opções pro jogador responder e selecionar respostas da poção atual.
  #
  # @return [String]
  def fazendo_pocao()
    case self.etapa
      when 2
          # Desocultando cursor
          $stdout.print "\e[?25h"
          @resp = @prompt.ask("#{$livro["pocoes"][0][self.pocao_atual]["nome"]} [2° Etapa]:")
          puts "\n"
          # Se a resposta do jogador for igual a resposta do puzzle
          if @resp.to_i == $livro["pocoes"][0][self.pocao_atual]["resp"][0]
            self.etapa = 3
            fazendo_pocao()
          else 
            if self.pode_errar
              print "Você ".color("9046FF")
              # Randomizando a mensagem do jogador falando que algo deu errado
              print $efeitos.maquina_texto($roteiro["resp_erro"][rand(3)])
              puts "\n"
              abrir_livro_ou_fazer_pocao(5)       
            else
              return :final
            end
          end
      when 3
          # Desocultando cursor
          $stdout.print "\e[?25h"
          @resp = @prompt.ask("#{$livro["pocoes"][0][self.pocao_atual]["nome"]} [3° Etapa]:")
          puts "\n"
          # Se a resposta do jogador for igual a resposta do puzzle
          if @resp.to_i == $livro["pocoes"][0][self.pocao_atual]["resp"][1]
            self.etapa = 4
            fazendo_pocao()
          else 
            if self.pode_errar
              print "Você ".color("9046FF")
              # Randomizando a mensagem do jogador falando que algo deu errado
              print $efeitos.maquina_texto($roteiro["resp_erro"][rand(3)])
              puts "\n"
              abrir_livro_ou_fazer_pocao(5)  
            else
              return :final
            end
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
          @pocao_escolhida = @prompt.select("Qual poção deseja combinar? ", @pocoes_2,
                                            cycle: true,
                                            help: "Use as setas",
                                            active_color: :white)
          puts "\n"

          # Pegando o índice da poção escolhida
          ($livro["pocoes"][3].length).times do | i |
            if @pocao_escolhida == $livro["pocoes"][3][i]["nome"]
              @indice_pocao_escolhida = i
            end
          end

          # Select para escolher a resposta da poção selecionada
          @resp = @prompt.select(@pocao_escolhida + $livro["pocoes"][3][@indice_pocao_escolhida]["etapa-1"], $livro["pocoes"][3][@indice_pocao_escolhida]["opcoes_resp"],
                                  cycle: true,
                                  help: "Use as setas",
                                  active_color: :white)
          puts "\n"
          # Retirando uma parte do nome da poção escolhida
          @p = @pocao_escolhida.sub("Poção ", "")

          # Se a resposta para o puzzle da poção escolhida estiver correta
          if @resp == $livro["pocoes"][3][@indice_pocao_escolhida]["resp"]     
            # Se a combinação final das poções estiver correta
            if verifica_pocao_final(@p)
              self.pocao_atual += 1
              $save["pocao_atual"] = self.pocao_atual
  
              IO.console.cursor_up(8)
              $efeitos.limpa_linhas(false, 8)
              return
            # Resposta correta, porém combinação errada
            else
              if self.pode_errar
                self.chances -= 1
                # Você errou a combinação das poções duas vezes (gastou suas duas chances)
                if self.chances == 0
                  #puts $efeitos.maquina_texto($roteiro["finais"][0])
                  return :final
                end

                # Você errou a combinação das poções uma vez
                print "Você ".color("9046FF")
                # Randomizando a mensagem do jogador falando que a combinação das poções está errada
                print $efeitos.maquina_texto($roteiro["resp_c_erro"][rand(3)])
                puts "\n"
                sleep(0.6)
                print "Você ".color("9046FF")
                print $efeitos.maquina_texto("Gastei muito tempo fazendo uma poção errada, só tenho tempo para tentar fazer mais uma poção completa.")
                puts "\n"
                
                abrir_livro_ou_fazer_pocao(10)  
              else
                return :final
              end
            end  
          # Resposta errada
          else
            if self.pode_errar
              print "Você ".color("9046FF")
              # Randomizando a mensagem do jogador falando que algo deu errado
              print $efeitos.maquina_texto($roteiro["resp_erro"][rand(3)])
              puts "\n"
              abrir_livro_ou_fazer_pocao(7)    
            else
              return :final
            end
          end       
    end
  end


  private

  # Cria um select com as opções: abrir o livro e continuar o preparo da poção.
  #
  # @param linhas [Integer] Quantidade de linhas que vão ser apagadas
  #
  # @return [void]
  def abrir_livro_ou_fazer_pocao(linhas)
    # Ocultando o cursor
    $stdout.print "\e[?25l"
    @resp = @prompt.select("O que deseja?", "Abrir o livro", "Preparar a poção",
                            cycle: true,
                            help: "Use as setas",
                            active_color: :white)
    # Sobe o cursor e apaga algumas linhas
    IO.console.cursor_up(linhas)
    $efeitos.limpa_linhas(false, linhas)

    case @resp
      when "Abrir o livro"
        @livro = Livro.new
        @livro.livro_aberto = true

        loop do
          if @livro.livro_aberto == false then break end
          @livro.printa_pagina()
          @livro.mexe_no_livro()        
        end 
        fazendo_pocao()
      when "Preparar a poção" then  fazendo_pocao()
    end
  end

  # Verifica se a poção final está correta (se a combinação das poções foi a necessária).
  #
  # @param pocao [String] Nome da poção escolhida.
  #
  # @return [Boolean]
  def verifica_pocao_final(pocao)
    if $livro["encomenda"][self.pocao_atual].include?(pocao) then  
      return true  
    end
    
    return false  
  end

end