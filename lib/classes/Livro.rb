require "json"
require "tty-box"
require 'rainbow/refinement'
using Rainbow

caminho_l = File.expand_path("../../data/livro_pocoes.json", __dir__)
$livro = JSON.load_file(caminho_l)

class Livro
    attr_accessor :pag_atual
    attr_accessor :livro_aberto

    def initialize()
      self.pag_atual = 0
      self.livro_aberto = false
    end

    def printa_pagina()
      if self.livro_aberto
        case self.pag_atual
          when 0 # Página 1
            @pag_1 = $livro["pocoes"][0]
            @pocoes = ""
            @box = TTY::Box.frame(width: TTY::Screen.width, height: 10, padding: 1,title: {top_left: "LIVRO DE POÇÕES", bottom_right: "pag 1"}) do
              # Pegando as informações de cada poção da página 1
              0.upto(@pag_1.length - 1) do | i |
                @pocoes = @pocoes + 
                @pag_1[i]["nome"] + "   " + "   ".bg(@pag_1[i]["cores"][0]) + "   " +
                @pag_1[i]["etapa-2"][0].bg(@pag_1[i]["cores"][1]) + " " +
                @pag_1[i]["etapa-2"][1].bg(@pag_1[i]["cores"][2]) + " " +
                @pag_1[i]["etapa-2"][2].bg(@pag_1[i]["cores"][3]) + "   " +
                @pag_1[i]["etapa-3"].bg(@pag_1[i]["cores"][4]).color("000000") + "\n\n"
              end
              # Variável com toda a string sobre as poções para o box
              @pocoes
            end

            print @box
            puts
          when 1 # Página 2
            @pag_2 = $livro["pocoes"][1]
            @pocoes = ""
            @box = TTY::Box.frame(width: TTY::Screen.width, height: 10, padding: 1,title: {top_left: "LIVRO DE POÇÕES", bottom_right: "pag 2"}) do
              "página 2"
              # Variável com toda a string sobre as poções para o box
              #@pocoes
            end

            print @box
            puts
          when 2 # Página 3
            @pag_3 = $livro["pocoes"][2]
            @pocoes = ""
            @box = TTY::Box.frame(width: TTY::Screen.width, height: 10, padding: 1,title: {top_left: "LIVRO DE POÇÕES", bottom_right: "pag 3"}) do
              "página 3"
              # Variável com toda a string sobre as poções para o box
              #@pocoes
            end

            print @box
            puts
          when 3 # Página 4
            @pag_4 = $livro["pocoes"][3]
            @pocoes = ""
            @box = TTY::Box.frame(width: TTY::Screen.width, height: 10, padding: 1,title: {top_left: "LIVRO DE POÇÕES", bottom_right: "pag 4"}) do
              # Pegando as informações de cada poção da página 4
              0.upto(@pag_4.length - 1) do | i |
                @pocoes = @pocoes + 
                @pag_4[i]["nome"] + "   " + @pag_4[i]["etapa-1"].bg(@pag_4[i]["cor"]) + "\n\n"
              end
              # Variável com toda a string sobre as poções para o box
              @pocoes
            end
            print @box
            puts
        end
      end
    end

    def mexe_no_livro()
      @tecla = STDIN.getch #Pega qual tecla foi digitada
      # Se clicar no esc fecha o livro
      if @tecla == "\e" 
        self.livro_aberto = false

      # Voltando uma página
      elsif @tecla == "a" 
        self.pag_atual = self.pag_atual - 1
        if self.pag_atual < 0  then self.pag_atual = 0  end
        #puts self.pag_atual

      # Indo para próxima página
      elsif @tecla == "d" 
        self.pag_atual = self.pag_atual + 1
        if self.pag_atual > 3  then self.pag_atual = 3  end
        #puts self.pag_atual
      end
    end
    
end