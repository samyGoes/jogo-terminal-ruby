require "tty-font"
require "tty-prompt"
require "rainbow/refinement"
using Rainbow
require "io/console"
require "json"
require_relative "GerenciadorDialogo"
require_relative "../modules/Efeitos"
$efeitos = include Efeitos

caminho_r = File.expand_path("../../data/roteiro.json", __dir__)
$roteiro = JSON.load_file(caminho_r)

caminho_s = File.expand_path("../../data/salvamento.json", __dir__)
$save = JSON.load_file(caminho_s)
#$save_inicial = $save
#$save_inicial.freeze

class Menu
  attr_accessor :voltar

  def initialize()
    @font = TTY::Font.new(:doom)
    @prompt = TTY::Prompt.new
    @espacos_t = $efeitos.espacos_ate_o_meio(@font.write("Encomenda"))
    @espacos_m = $efeitos.espacos_ate_o_meio("novo jogo", false)
    @espacos_f = $efeitos.espacos_ate_o_meio(@font.write("Finais"))
    self.voltar = false
  end

  # Cria o menu inicial.
  #
  # @return [void]
  def tela_menu()
    # Limpando o terminal inteiro
    system("clear") || system("cls")
    # Deixando o cursor oculto
    $stdout.print "\e[?25l"
    # Printando o título
    puts "\n"
    $efeitos.maquina_texto(@font.write("#{@espacos_t}Encomenda").color("7209b7"), 0.0009 , false)

    # Opções do menu
    @opcoes = [
      { name: "#{@espacos_m}NOVO JOGO"}, 
      { name: "#{@espacos_m}CONTINUAR", disabled: ""},
      { name: "#{@espacos_m}FINAIS"}
    ]
    @opcao = @prompt.select(@espacos_m, @opcoes, help: "Use as setas", cycle: true, 
                            active_color: ->(str) { (str).color("9046FF") },
                            symbols: { marker: "" })
    
    # Retirando os espaços dos items do menu
    (@opcoes.length).times do | i |
      @opcoes[i][:name].strip!
    end

    case @opcao
      when "novo jogo".upcase
        puts "aa #{@opcoes.class}"
        puts @opcoes[0].class
        # puts $save
        # puts "\n---------\n"
        # puts $save_inicial
        # $save = $save_inicial

        # Limpando o terminal inteiro
        system("clear") || system("cls") 
        puts "Aperte enter ou espaço\n".color("858585")
        @dialogo = GerenciadorDialogo.new
        # MAIN LOOP
        loop do
          # Deixando o cursor oculto
          $stdout.print "\e[?25l"
          # Pega a tecla apertada
          @caractere = STDIN.getch  
          # Se não tiver chegado a nenhum final 
          if @dialogo.final == false
            # Se clicar enter ou espaço chama o gerenciador de diálogo
            if @caractere == "\r" or @caractere == " "
              @dialogo.sistema_dialogo()
            end          

            # Se clicar s encerra a execução do jogo (apenas para facilitar na hora de testar)
            if @caractere == "s"
              break
            end    
          else
            break           
          end     
        end
        tela_menu()
      when "continuar".upcase
        puts "Escolhi continuar"
        puts "Escolhi linguagem"
      when "finais".upcase
        # Limpando o terminal inteiro
        system("clear") || system("cls")
        # Deixando o cursor oculto
        $stdout.print "\e[?25l"   

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


  private

  # Printa os finais disponíveis e quantos o jogador desbloqueou.
  #
  # @return [void]
  def printa_finais()
    @finais = []
    ($roteiro["finais"].length).times do | i |
      @finais[i] = $roteiro["finais"][i][0]
    end

    @espacos = $efeitos.espacos_ate_o_meio(@finais.max_by(&:length), false)
    
    puts "Esc para voltar ao menu\n".color("858585")
    
    $efeitos.maquina_texto(@font.write("#{@espacos_f}Finais").color("7209b7"), 0.0009 , false)

    # Printando os finais e verificando quais finais o jogador desbloqueou para pintar de outra cor
    ($roteiro["finais"].length).times do | i |
      if $save["finais_coletados"].include?($roteiro["finais"][i][0])
        puts @espacos + $roteiro["finais"][i][0].color("7209b7") + "\n"
      else
        puts @espacos + $roteiro["finais"][i][0].color("858585") + "\n"
      end
    end
    
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
      # Limpando o terminal inteiro
      system("clear") || system("cls")
      self.voltar = true
    end
  end
end