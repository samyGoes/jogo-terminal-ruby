require "tty-font"
require "tty-prompt"
require "rainbow/refinement"
using Rainbow
require "io/console"
require_relative "GerenciadorDialogo"
require_relative "../modules/Efeitos"
$efeitos = include Efeitos

class Menu
  attr_accessor :voltar

  def initialize()
    @font = TTY::Font.new(:doom)
    @prompt = TTY::Prompt.new
    self.voltar = false
  end

  # Cria o menu inicial.
  #
  # @return [void]
  def tela_menu()
    #IO.console.cursor_up(2)
    #$efeitos.limpa_linhas(false, 2) 
    # Deixando o cursor oculto
    $stdout.print "\e[?25l"
    # Printando o título
    $efeitos.maquina_texto(@font.write("  Encomenda").color("7209b7"), 0.0009 , false)

    # Opções do menu
    @opcoes = [
      { name: "novo jogo"}, 
      { name: "continuar", disabled: "(Em desenvolvimento)"},
      { name: "linguagem", disabled: "(Em desenvolvimento)"},
      { name: "finais"}
    ]
    @opcao = @prompt.select("", @opcoes, help: "Use as setas", cycle: true, 
                            active_color: ->(str) { (str).color("9046FF") },
                            symbols: { marker: "" })

    case @opcao
      when "novo jogo"
        IO.console.cursor_up(9)
        $efeitos.limpa_linhas(false, 9) 
        puts "Aperte enter ou espaço".color("858585")
        @dialogo = GerenciadorDialogo.new
        loop do
          # Deixando o cursor oculto
          $stdout.print "\e[?25l"
          # Pega a tecla apertada
          @caractere = STDIN.getch
          # Se clicar enter ou espaço chama o gerenciador de diálogo
          if @caractere == "\r" or @caractere == " " and @dialogo.final == false
            @dialogo.sistema_dialogo()
          end          

          # Se clicar s encerra a execução do jogo (apenas para facilitar na hora de testar)
          if @caractere == "s"
            break
          end
        end
      when "continuar"
        puts "Escolhi continuar"
      when "linguagem"
        puts "Escolhi linguagem"
      when "finais"
        printa_finais()
        loop do
          volta_menu()
          if self.voltar
            self.voltar = false
            break
          end
        end
        tela_menu()
    end
  end

  # Printa os finais disponíveis e quantos o jogador desbloqueou.
  #
  # @return [void]
  def printa_finais()
    IO.console.cursor_up(9)
    $efeitos.limpa_linhas(false, 9) 
    puts "Esc para voltar ao menu".color("858585")
    puts "finais"
    return
  end

  # Volta para o menu se apertar esc.
  #
  # @return [void]
  def volta_menu()
    # Deixando o cursor oculto
    $stdout.print "\e[?25l"
    @caractere = STDIN.getch 
    if @caractere == "\e"
      IO.console.cursor_up(2)
      $efeitos.limpa_linhas(false, 2) 
      self.voltar = true
    end
  end
end