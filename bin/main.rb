require_relative "../lib/classes/GerenciadorDialogo"
require "io/console"
require "tty-box"
require 'rainbow/refinement'
using Rainbow

puts "  APERTE ENTER PARA COMEÇAR  \n".bg("7209b7").bold
dialogo = GerenciadorDialogo.new

#MAIN LOOP
loop do
  caractere = STDIN.getch
  #puts "Você pressionou a tecla: '#{caractere}'"
  
  # Se clicar enter ou espaço chama o gerenciador de diálogo
  if caractere == "\r" or caractere == " "
    dialogo.sistema_dialogo()
  end
  if caractere == "s"
    break
  end

end



# box = TTY::Box.frame(width: TTY::Screen.width, height: 10, padding: 1,title: {top_left: "LIVRO DE POÇÕES", bottom_right: "pag 1"}) do

#   "Poção de restauração  " + " 1 ".bg("7209b7") + " " + " 3 ".bg("89023e") + " " + " 5 ".bg("13505b") +
#   " " + " BGHA! ".bg("68d6f8").color("000000") + "\n\n" +
  
#   "Poção de força        " + " 1 ".bg("7209b7") + " " + " 3 ".bg("89023e") + " " + " 5 ".bg("13505b") +
#   " " + " BGHA! ".bg("68d6f8").color("000000") + "\n"

# end

# print box