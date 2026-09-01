require_relative "../lib/classes/GerenciadorDialogo"
require "io/console"
require "pastel"

pastel = Pastel.new

puts pastel.on_magenta.white.bold("  APERTE ENTER PARA COMEÇAR  \n")
dialogo = GerenciadorDialogo.new

#MAIN LOOP
loop do
  caractere = STDIN.getch
  #puts "Você pressionou a tecla: '#{caractere}'"
  
  if caractere == "\r" or caractere == " "
    dialogo.sistema_dialogo()
  end

end
