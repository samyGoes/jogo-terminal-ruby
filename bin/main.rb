require_relative "../lib/classes/GerenciadorDialogo"

i = 0

#MAIN LOOP
while i < 5
  dialogo = GerenciadorDialogo.new
  dialogo.sistema_dialogo()
  i = i + 1
end
