class Irma
    attr_accessor :pirraca
    attr_accessor :conseguiu_fazer_etapa
    attr_accessor :faz_etapa

    def initialize()
      self.pirraca = false
      self.conseguiu_fazer_etapa = true
      self.faz_etapa = 0
    end

    # Caso o self.conseguiu_fazer etapa seja true, retorna 1 (o índice da mensagem que ela pede para fazer uma poção 
    # completa). Caso seja false, retorna 0 (o índice da mensagem que ela diz que pediria, mas desistiu).
    #
    # @return [Integer] 1 ou 0
    def fazer_pocao_completa()
      if self.conseguiu_fazer_etapa
        return 1
      else
        return 0
      end
    end
end