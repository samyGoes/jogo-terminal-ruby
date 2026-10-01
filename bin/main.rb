require_relative "../lib/classes/GerenciadorDialogo"
require "io/console"
require 'rainbow/refinement'
using Rainbow

# Deixando o cursor oculto
$stdout.print "\e[?25l"
puts "  APERTE ENTER PARA COMEÇAR  \n".bg("7209b7").bold

dialogo = GerenciadorDialogo.new

#MAIN LOOP
loop do
  # Deixando o cursor oculto
  $stdout.print "\e[?25l"
  caractere = STDIN.getch

  # Se clicar enter ou espaço chama o gerenciador de diálogo
  if caractere == "\r" or caractere == " " and dialogo.final_pocao_errada == false
    dialogo.sistema_dialogo()
  end

  # Se clicar s encerra a execução do jogo
  if caractere == "s"
    break
  end

end
