# contador_assembly
Arduino e Assembly - AVR

O projeto consiste na elaboração de um contador digital, que pode ser programado para funcionar em dois estados diferentes, estado de incremento ou estado de decremento. Um LED está instalado ao lado do display de 7 segmentos para sinalizar o estado atual do contador, caso esteja em modo de incremento o LED fica acesso, e caso esteja em modo de decremento o LED permanece apagado.

O incremento e decremento do número exibido no display pode ser acionado através de dois botões disponíveis próximos ao Display de 7 segmentos. Enquanto o modo de incremento estiver ativo, não é possível decrementar o valor, e vice-versa.
O sistema coloca o contador automaticamente em modo de incremento durante a inicialização, ou quando estiver exibindo o número ZERO, e aciona o modo de decremento sempre que chegar ao número 9.
