.data
	msgInicial: .asciiz "\n ------------------------------ TRABALHO DE OAC 1 - UFOP -------------------------------\n O programa visa implementar um aumento de salario e realizar os descontos dos impostos \n Desconto INSS: 5% \n Desonto Sindicato: 8% \n Desconto do IRRF baseado na tabela e aliquota 2021 \n ------------------------------------------------------------------------------------------\n"
	msgUsr: .asciiz "\n -1 para o programa, qualquer outro caractere continua:  "
	msgPontilhado: .asciiz "\n------------------------------------------------------------------------------------------\n"
	msgSalarioInicial: .asciiz "\n O salario inicial é: "
	msgDesconto: .asciiz "\n O salario com desconto INSS e Sindicado é:  "
	msgNovamente: .asciiz "\n\n !!! O salario não pode ser negativo !!! \n\n"
	msgIsento: .asciiz "\n Você é isento de IRPF!! \n "
	msgIRRF: .asciiz "\n Salario com desconto IRPF:  "
	msgSalario: .asciiz " Forneça o salario:  "
	msgAumento: .asciiz "\n O salario com aumento é:  "
	msgLiquido: .asciiz "\n Seu salario liquido é:  "
	
	espaco: .byte ' '
	zero: .float 0.0
	
	#valor base para comparar salario 
	valor1: .float 1300.00
	valor2: .float 5000.00
	valor3: .float 10000.00
	
	#porcentagem para aumento de salario
	porcentos1: .float 1.2
	porcentos2: .float 1.15
	porcentos3: .float 1.10
	porcentos4: .float 1.05
	
	#desconto do Sindicato com INSS
	descontosSindicatoINSS: .float -0.13
	
	#valor do IRPF por SALARIO BASE
	valorIRRF1: .float 1903.98 
	valorIRRF2: .float 2826.65
	valorIRRF3: .float 3751.05
	valorIRRF4: .float 4664.68
	
	#faixa de dedução para aliquota IRPF
	faixaIRRF1: .float 142.80
	faixaIRRF2: .float 354.80
	faixaIRRF3: .float 636.13
	faixaIRRF4: .float 869.36
	
	#porcentagem para aliquota do IRPF
	porcentosIRRF1: .float -0.075
	porcentosIRRF2: .float -0.15
	porcentosIRRF3: .float -0.225
	porcentosIRRF4: .float -0.275
	
.text 
	.main:
	la $a0, msgInicial
	jal imprimeString
	
	move $t0, $zero
	#laço principal que roda o programa ate receber -1 
	while: 
		
		beq $t0, -1, encerrarPrograma
			li $v0, 4
			la $a0, msgSalario #pede o salario ao usuario 
			syscall
			jal leSalario #le o salario e retorna para $f12
			
			c.le.s $f1,$f12
			bc1f novamente
			
			la $a0, msgSalarioInicial
			jal imprimeString
			jal imprimeFloat
			jal aumentoSalario
			
			# chama funcao para calcular descontos 
			descontos:
				la $a0, msgAumento
				jal imprimeString 
				jal imprimeFloat 
				jal aplicaDescontos
	 		
	 		# caso não seja isento executa mensagem 
	 		mensagem:
	 			la $a0, msgIRRF
				jal imprimeString
				jal imprimeFloat
					
	 		# mantem o laço enquanto a entrada for diferente de -1 
			condicaoPrincipal:
				
				la $a0, msgLiquido # Mostrar salario Liquido 
				jal imprimeString
				jal imprimeFloat
				
				# condição para parar o programa	
				la $a0, msgPontilhado
				jal imprimeString	
				la $a0, msgUsr 
				jal imprimeString
				jal leInteiro
				move $t0, $v0
		
		la $a0, msgPontilhado
		jal imprimeString		
		j while 
		
	.funcoes:
	
	# emite alerta caso salario fornecido for negativo 
	novamente:
		la $a0, msgNovamente
		jal imprimeString
		la $a0, msgPontilhado 
		jal imprimeString
		jal while
		
	# aumenta o salario diacordo com a base 
	aumentoSalario:
		lwc1 $f20, valor1
		lwc1 $f21, valor2
		lwc1 $f22, valor3
	
		c.le.s $f12,$f20 #compara <= 1300 
		bc1t condicao1 #atribui o aumento  
		c.le.s $f12,$f21 #compara <= 5000
		bc1t condicao2 #atribui o aumento 
		c.le.s $f12,$f22 #compara <= 10000
		bc1t condicao3 #atribui o aumento 
		jal condicao4 #atribui o aumento caso a condicao 3 for falsa 
		
	# aplica aumento de 20%	
	condicao1: 
		lwc1 $f31, porcentos1 
		mul.s $f12,$f12,$f31 
		jal descontos 
		
	# aplica aumento de 15%	
	condicao2: 
		lwc1 $f31, porcentos2 
		mul.s $f12,$f12,$f31 
		jal descontos 
		
	# aplica aumento de 10%	
	condicao3: 
		lwc1 $f31, porcentos3 
		mul.s $f12,$f12,$f31 
		jal descontos 
		
	# aplica aumento de 5%	
	condicao4: 
		lwc1 $f31, porcentos4 
		mul.s $f12,$f12,$f31
		jal descontos 
	
	#aplica desconto IRPF, INSS e Sindicado 
        aplicaDescontos:
		
		#carrega valores de IRPF e descontos
		lwc1 $f31, descontosSindicatoINSS  # 13% -> 5% + 8%
		lwc1 $f23, valorIRRF1
		lwc1 $f24, valorIRRF2 
		lwc1 $f25, valorIRRF3 
		lwc1 $f26, valorIRRF4 
				
		add.s $f14,$f1,$f12 # Salario salario com aumento 
		mul.s $f30,$f12,$f31 # Calcula desconto INSS e SINDICATO 
		add.s $f12,$f12,$f30 # Atribui soma salario com desconto INSS e Sindicato 
		
		la $a0, msgDesconto 
		jal imprimeString	 
		jal imprimeFloat 
		
		#Comparaçoes para saber se o salario X <= Y
		c.le.s $f14,$f23 
		bc1t desconto1
		c.le.s $f14,$f24
		bc1t desconto2
		c.le.s $f14,$f25
		bc1t desconto3
		c.le.s $f14,$f26
		bc1t desconto4
		jal desconto5
		
		# Desconto com Isemção IRRF
		desconto1: 
			la $a0, msgIsento #salario Isento 
			jal imprimeString
			jal condicaoPrincipal
			
		# Desconto com aliquota 7.5% 
		desconto2: 
			lwc1 $f31, porcentosIRRF1 
			lwc1 $f30, faixaIRRF1 #aliquota 142.80
			mul.s $f29,$f12,$f31 # calcula valor da multiplicas Salario * (- Aliquota) 
			add.s $f30,$f30,$f29
			add.s $f12,$f12,$f30 # Salario com alicota deduzida 
			jal mensagem 
			
		# Desconto com aliquota 15%
		desconto3: 
			lwc1 $f31, porcentosIRRF2
			lwc1 $f30, faixaIRRF2 #aliquota 354.80
			mul.s $f29,$f12,$f31  # calcula valor da multiplicas Salario * (- Aliquota) 
			add.s $f30,$f30,$f29
			add.s $f12,$f12,$f30  # Salario com alicota deduzida 
			jal mensagem 
		
		# Desconto com aliquota 22.5%
		desconto4: 
			lwc1 $f31, porcentosIRRF3
			lwc1 $f30, faixaIRRF3 #aliquota 636,13
			mul.s $f29,$f12,$f31 # calcula valor da multiplicas Salario * (- Aliquota) 
			add.s $f30,$f30,$f29
			add.s $f12,$f12,$f30 # Salario com alicota deduzida 
			jal mensagem 
		
		# Desconto com aliquota 27.5%	
		desconto5: 
			lwc1 $f31, porcentosIRRF4
			lwc1 $f30, faixaIRRF4 #aliquota 869,36
			mul.s $f29,$f12,$f31  # calcula valor da multiplicas Salario * (- Aliquota) 
			add.s $f30,$f30,$f29
			add.s $f12,$f12,$f30 # Salario com alicota deduzida 	
			jal mensagem 
		
	#Le salario em float
	leSalario:
		li $v0, 6
		syscall #valor lido estara em $f0
		lwc1 $f1, zero
		add.s $f12, $f1, $f0 # registrador $f12 para facilitar os seguintes calculos 
		jr $ra
		
	#le inteiro e retorna $v0 
	leInteiro:
		li $v0, 5
		syscall
		jr $ra
		
	#imprime qualquer valor float utilizando $f12 como parametro 
	imprimeFloat: 
		li $v0, 2
		syscall
		jr $ra
	#imprime qualquer valor inteiro 
	imprimeInteiro:
		li $v0, 1
		syscall
		jr $ra 
		
	#imprime uma string passada em $a0 
	imprimeString:
		li $v0, 4
		syscall
		jr $ra
	
	#encerrar programa
	encerrarPrograma:
		li $v0, 10
		syscall
