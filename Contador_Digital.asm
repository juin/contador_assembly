/*
Funcao: CONTADOR DIGITAL
Descri��o: Exibir atrav�s de um display de 7 segmentos, o n�meros de 0 a 9. Tais n�meros podem ser incrementados ou decrementados de acordo
com o bot�o pressionado pelo usu�rio. Um LED localizado no canto superior esquerdo, indica o modo de trabalho atual do contador.
LED ligado = Incremento
LED desligado = Decremento
Alunos:
CREMILDO LIMA GOMES
FRANCISCO ERLAN CANGU��
NAILTON GON�ALVES ALVES
YURY BARROS DAMASCENO
Disciplina: OAC - Organizacao e Arquitetura de Computadores
Curso: Sistemas de Informa��o
IFBA - Instituto Federal da Bahia.
*/

//Defini��es de registradores e PINOS
.DEF TEMP = R16
.DEF CONT = R19
.DEF endereco = R17
.DEF saida = R18
.EQU sgA = PB5 
.EQU sgB = PD3 
.EQU sgC = PD4 
.EQU sgD = PD5 
.EQU sgE = PD6 
.EQU sgF = PD7 
.EQU sgG = PB0
.EQU DISPLAY = PB1 
.EQU BUT = PB2
.EQU BOTAO = PB3
.EQU LED = PB4
.cseg
.org 0x00
	rjmp INICIO

INICIO:
  CLI //Desabilita interrupcoes
  LDI CONT,-1     //CONT = 0
  LDI R20,0xFF    //carrega R20 com o valor 0xFF
  OUT DDRD,R20    //configura todos os pinos do PORTD como sa�da 
  OUT PORTD,R20    //coloca todos os pinos do PORTD em 5v 
  LDI R21,0b11110011 // carrega R21 com o valor 0b1110011 -- (0-Entrada e 1-Sa�da)
  OUT DDRB,R21    //configura os pinos do PORTB como sa�da e outros como entrada
  OUT PORTB, R21    //coloca todos os pinos do PORTB em 5v
  LDI R28,0 //Carrega o valor inicial do estado inicial do sistema como MODO DE INCREMENTAR (0-Incrementa ---- 1-Decremento)

	//Programa��o da Mem�ria RAM
	ldi TEMP,100 //valor a ser gravado na mem�ria RAM
	ldi r29, 0x60 //Byte inferior do endereco (X)
	ldi r30, 0x00 //Byte superior do endereco (X)
	rcall ram_w //escrita na ram
	rcall ram_r //leitura da ram

	CPI saida,100 //Compara se valor resgatado da RAM = 100
	BREQ pisca2 //Se for igual pisca LED 2x
	RJMP eeprom	//Pula para proxima rotina, Trabalhar com EEPROM
//Rotina para PISCAR LED
pisca2:
	CBI PORTB,LED
	rcall congela
	SBI PORTB,LED
	rcall congela
	CBI PORTB,LED
	rcall congela
	SBI PORTB,LED
	rcall congela
	rjmp eeprom

eeprom: //Trabalhando com EEPROM
	LDI TEMP,0x04 //Carrega valor a ser gravado na EEPROM
	LDI endereco, 0x01 //endere�o onde ser� gravado o dado na eeprom
	RCALL grava_e2p //escrita na EEPROM
	RCALL le_e2p //leitura na EEPROM

	CPI saida,0x04 //Compara se valor resgatado da EEPROM eh igual a 0x04
	BREQ pisca //pisca LED
	rjmp principal //Pula para parte principal do programa

pisca:
	CBI PORTB,LED
	rcall congela
	SBI PORTB,LED
	rcall congela
	CBI PORTB,LED
	rcall congela
	SBI PORTB,LED
	rcall congela
	rjmp principal

//Tudo acima dessa linha so executa apenas uma vez durante a inicializacao do sistema.

PRINCIPAL:
	
	//Verifica se est� em modo de 0-Incrementa ou 1-Decrementa
	CPI R28,0
	BREQ BUT1
	BRNE BUT2

//Bot�o 1 � para incrementar contador.
BUT1:
	LDI R28,0
	SBIC PINB,BOTAO //Verifica se bot�o 1 foi pressionado.
	RJMP BUT1 //Sen�o foi pressionado fica no loop at� ser.
SOLTAR:
	SBIS PINB,BOTAO //Verifica se bot�o foi solto
	RJMP SOLTAR //sen�o fica aguardando soltar bot�o
	RCALL ATRASO //rotina de atraso para evitar ruido
	RJMP incrementa //pula para incrementa

//Bot�o 2 para decrementar contador.
BUT2:
	LDI R28,1
	SBIC PINB,BUT //Verifica se bot�o 2 foi pressionado.
	RJMP BUT2 //Sen�o foi pressionado fica no loop at� ser.
SOLT:
	SBIS PINB,BUT  //Verifica se bot�o foi solto
	RJMP SOLT //sen�o fica aguardando soltar bot�o
	RCALL ATRASO //rotina de atraso para evitar ruido
	RJMP decrementa //pula para decrementa

incrementa:
  SBI PORTB,LED //LIGA LED enquanto estiver incrementando.
  INC CONT      //Incrementa Contador
  RJMP zero      //Escreve o Digito correspondente 
decrementa:
  CBI PORTB,LED //Apaga LED enquanto estiver decrementando.
  DEC CONT      //Decrementa TEMP, pois est� com valor 10 
  RJMP zero     //Escreve o Digito correspondente
 //Mapa para cada digito do display 
zero: //Exibe numero ZERO
  CPI CONT,0x00    //Compara se CONT = 0 
  BRNE um        //Se CONT != 0, ent�o pule para um 
  LDI TEMP,0b00000000  //Mapa para mostrar numero 0 
  OUT PORTD,TEMP    //Mostra 0 no display
  CBI PORTB,sgA
  SBI PORTB,sgG
  RCALL ATRASO    //Chama atraso para ser v�sivel a mudan�a de um n�mero para o outro. 
  LDI R28,0
  RJMP PRINCIPAL
um: //Exibe numero UM
  CPI CONT,0x01 
  BRNE dois //Se CONT != 1, ent�o pule para dois 
  LDI TEMP,0b11100111 
  OUT PORTD,TEMP
  SBI PORTB,sgA
  SBI PORTB,sgG
  RCALL ATRASO 
  RJMP PRINCIPAL 
dois: //Exibe numero 2
  CPI CONT,0x02 
  BRNE tres //Se CONT != 2, ent�o pule para tres 
  LDI TEMP,0b10010011 
  OUT PORTD,TEMP
  CBI PORTB,sgA 
  CBI PORTB,sgG 
  RCALL ATRASO 
  RJMP PRINCIPAL
tres: 
  CPI CONT,0x03 
  BRNE quatro //Se CONT != 3, ent�o pule para quatro 
  LDI TEMP,0b11000001 
  OUT PORTD,TEMP
  CBI PORTB,sgA
  CBI PORTB,sgG 
  RCALL ATRASO 
  RJMP PRINCIPAL 
quatro: 
  CPI CONT,0x04 
  BRNE cinco //Se CONT != 4, ent�o pule para cinco 
  LDI TEMP,0b01100101 
  OUT PORTD,TEMP 
  SBI PORTB,sgA
  CBI PORTB,sgG 
  RCALL ATRASO 
  RJMP PRINCIPAL 
cinco: 
  CPI CONT,0x05 
  BRNE seis //Se CONT != 5, ent�o pule para seis 
  LDI TEMP,0b01001001 
  OUT PORTD,TEMP
  CBI PORTB,sgA
  CBI PORTB,sgG 
  RCALL ATRASO
  RJMP PRINCIPAL 
seis: 
  CPI CONT,0x06 
  BRNE sete //Se CONT != 6, ent�o pule para sete
  LDI TEMP,0b00001001 
  OUT PORTD,TEMP 
  SBI PORTB,sgA
  CBI PORTB,sgG 
  RCALL ATRASO 
  RJMP PRINCIPAL 
sete: 
  CPI CONT,0x07 
  BRNE oito //Se CONT != 7, ent�o pule para oito 
  LDI TEMP,0b11100011 
  OUT PORTD,TEMP
  CBI PORTB,sgA
  SBI PORTB,sgG 
  RCALL ATRASO 
  RJMP PRINCIPAL 
oito: 
  CPI CONT,0x08 
  BRNE nove //Se CONT != 8, ent�o pule para nove 
  LDI TEMP,0b00000000 
  OUT PORTD,TEMP 
  CBI PORTB,sgA
  CBI PORTB,sgG
  RCALL ATRASO 
  RJMP PRINCIPAL 
nove:
  LDI TEMP,0b01100000 
  OUT PORTD,TEMP 
  CBI PORTB,sgA
  CBI PORTB,sgG 
  RCALL ATRASO
  LDI CONT,9
  LDI R28,1 //Coloca sistema em modo de decremento
  RJMP PRINCIPAL


ATRASO: //Rotina de ATRASO
  LDI R24,35
 volta:     
  DEC  R22      //decrementa R17, come�a com 0x00 
  BRNE volta       //enquanto R17 > 0 fica decrementando R17 
  DEC  R23     //decrementa R18, come�a com 0x00 
  BRNE volta      //enquanto R18 > 0 volta decrementar R18 
  DEC  R24      //decrementa R19 
  BRNE volta      //enquanto R19 > 0 vai para volta 
  RET

CONGELA: //congela por aproximadamente 3s
	DEC R25			//decrementa R4, come�a com 0x00
	BRNE CONGELA	//enquanto R4 > 0, fica decrementando R4
	DEC  R26			//decrementa R3, come�a com 0x00
	BRNE CONGELA 	//enquanto R3 > 0 fica decrementando R3
	DEC  R27
	BRNE CONGELA	//enquanto R2 > 0 volta decrementar R3
	RET

//Fun��es da RAM
ram_r:
	//X -> registrador especial para trabalhar com a mem�ria (16 bits)
	ld saida, X //carrega em saida o valor contido no endereco apontado por X
	ret
ram_w:  
    st X, TEMP //Armazena o byte contido em valor na posicao X da mem�ria RAM
	ret

//Fun�oes da EEPROM
grava_e2p: //Gravacao da EEPROM
		sbic eecr,eepe	//Salta se o bit eepe no registrador eecr estiver zerado.
						//eecr � o registrador de controle responsavel por setar o bit eepe.
						//eepe � o bit responsavel por acionar a escrita na eeprom
		rjmp grava_e2p		//Aguarda at� o uC estar pronto para gravar prox byte na e2pr
		out eearl,endereco	//eearl define o endereco a ser gravado na e2prom, 
							//eearl eh o registrador responsavel por guardar o endere�o de grava�ao
		out eedr,TEMP //define o dado a ser gravado (ver se ele eh sobescrito se o valor de r18 for alterado)
		sbi eecr,eempe //seta o bit MASTER de gravacao da e2prom (eempe);
		sbi eecr,eepe //seta o bit de gravacao da e2prom (eepe)
		nop
		nop
		ret //retorna pro lugar de chamada
le_e2p: //leitura da EEPROM
		out eearl,endereco //define o endereco a ser gravado na e2prom
		sbi eecr,eere  //seta o bit de leitura da e2prom (eere)
		nop
		nop
		in saida,eedr  //resgata os dados do registrador de dados da eeprom (eedr)	
		ret