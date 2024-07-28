.intel_syntax noprefix

.section .text

.global main

main:
    
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    
    ///////////////
    
    //# Ponteiro para argv[1]
    mov [rbp - 32], rsi
    add rsi, 8
    mov rdi, rsi
    
    //# Abrindo arquivo para leitura
    mov rdi, [rdi]
    lea rsi, [rip + leitura]
    call fopen@plt
    
    
    //# Salvando ponteiro para o arquivo de leitura
    mov [rip + ptr_leitura], rax
    
    //// escrita
    
    mov rsi, [rbp - 32]
	add rsi, 16
    
    //# Abrindo arquivo para escrita
    mov rdi, rsi
	mov rdi, [rdi]
    lea rsi, [rip + escrita]
    call fopen@plt
    
    //# Salvando ponteiro para o arquivo de escrita
    mov [rip + ptr_escrita], rax
    
    
    // int fscanf(FILE *stream, const char *format, &variavel...);
    // Leitura do tamanho do vetor de hexa
    mov rdi, [rip + ptr_leitura]
    lea rsi, [rip + inteiro]
    lea rdx, [rip + vetor_len]
    call fscanf@plt
    
    
    /////// ALOCAR ARRAY ///////
    
    mov rdi, [rip + vetor_len]
    call malloc@plt
    mov [rip + vetor], rax
    
    
    ///////// For para ler paleta /////////
    
    //////// for(i = 0, i < vetor_len, i++) //////
    
    ler_paleta_init:
        // i = 0
        mov rcx, 0
        
    ler_paleta:
        // i < vetor_len?
        cmp rcx, [rip + vetor_len] 
        je ler_paleta_fim
        
        // Salvando rcx
        mov [rbp - 8], rcx
        
        ////// ####LENDO VETOR##### //////
        
        mov rdi, [rip + ptr_leitura]
        lea rsi, [rip + hexa]
        lea rdx, [rip + vetor]
        add rdx, rcx
        call fscanf@plt
        
        // Restaurando rcx
		mov rcx, [rbp - 8]
		
		
        
        
        
        //////////###############////////////
        
        // Restaurando rcx
		mov rcx, [rbp - 8]
		inc rcx
		
		jmp ler_paleta
        
    ler_paleta_fim:    
    
    /////////////////########FIM PALETA######///////
    
     //////// leitura das quantidade de imagens //////
    mov rdi, [rip + ptr_leitura]
    lea rsi, [rip + inteiro]
    lea rdx, [rip + imagens]
    call fscanf@plt
    
    //////// salvando em rbx a quantidade de imagens /////////
    // int i = imagens
    mov rbx, [rip + imagens]
    mov ecx, [rip + imagens]
    
    .ler_img:
        /// salvando rcx
        mov [rbp - 8], ecx
        // leitura das quantidade de linhas
        mov rdi, [rip + ptr_leitura]
        lea rsi, [rip + inteiro]
        lea rdx, [rip + linhas]
        call fscanf@plt
        
        //restaurando ecx 
        mov ecx, [rbp - 8]
        
        // teste linhas
        //lea rdi, [rip + teste]
        //mov rsi, [rip + linhas]
        //call printf@plt
        
        //restaurando ecx 
        mov ecx, [rbp - 8]
        
        // leitura das quantidade de colunas
        mov rdi, [rip + ptr_leitura]
        lea rsi, [rip + inteiro]
        lea rdx, [rip + colunas]
        call fscanf@plt
        
        //restaurando ecx 
        mov ecx, [rbp - 8]
        
        //restaurando ecx 
        mov ecx, [rbp - 8]
        
        ///////// Escrevendo no arquivo o numero da imagem //////
        mov rdi, [rip + ptr_escrita]
        lea rsi, [rip + posicao_img]
        mov rdx, rbx
        dec rdx
        call fprintf@plt
        
        //restaurando ecx 
        mov ecx, [rbp - 8]
        
        ///// quantidade de linhas
        mov ecx, [rip + linhas]
        .ler_linha:
            /// salvando ecx
            mov [rbp - 24], ecx
            //// loop de linhas
            
            mov ecx, [rip + colunas]
            imul ecx, ecx, 2
                .ler_coluna:
                    /// salvando ecx
                    mov [rbp - 32], ecx
                    //// loop de colunas
                    
                    mov rdi, [rip + ptr_leitura]
                    lea rsi, [rip + hexa_unitario]
                    lea rdx, [rip + pixel]
                    call fscanf@plt
                     
                    // restaurando ecx           
                    mov ecx, [rbp - 32]
                    mov r12, [rip + pixel]
                 
                    mov rdi, [rip + ptr_escrita]
                    lea rsi, [rip + char]
                    lea rdx, [rip + vetor]
                    mov rdx, [rdx + r12]
                
                    call fprintf@plt
                    
                    
                    
                    //// restaurando ecx
                    mov ecx, [rbp - 32]
                    dec ecx
                    jnz .ler_coluna
                .ler_coluna_fim:
                
            
            mov rdi, [rip + ptr_escrita]
            lea rsi, [rip + quebra_linha]
            call fprintf@plt
            
            //// restaurando ecx
            mov ecx, [rbp - 24]
            dec ecx
            jnz .ler_linha
            
        .ler_linha_fim:
        
        
        
        /////// pulando para leitura da proxima imagem caso exista //////
        dec rbx
        ///// restaurando ecx
        mov ecx, [rbp - 8]
        dec ecx
        
        jnz .ler_img
        
    .ler_img_fim:
    
    
    
        //////////////
        mov rdi, [rip + ptr_leitura]
        call fclose@plt
        mov rdi, [rip + ptr_escrita]
        call fclose@plt
        
        mov rsp, rbp
        pop rbp
        ret

.section .rodata

quebra_linha:
    .string "\n"

teste_inteiro:
    .string "%d\n"
hexa_unitario:
    .string "%01X"
hexa:
    .string "%02X"

posicao_img:
    .string "[%d]\n"
    
teste_hexa:
    .string "Hexa lido: %02X\n"
teste_hexa_unitario:
    .string "Hexa lido: %01X\n"

teste_char:
    .string "Caracteres lidos: %s\n"

teste:
    .string "Passei aqui %d\n"
    
string:
    .string "%s"

char:
    .string "%c"

inteiro:
    .string "%d"

saida:
    .string "image2ascii.output"

leitura:
    .string "r"
    
escrita:
    .string "w"
    
.section .data

vetor_len:
    .8byte 0
    
vetor:
    .8byte 0
    
imagens:
    .8byte 0
    
linhas:
    .8byte 0
    
colunas:
    .8byte 0
    
ptr_leitura:
    .8byte 0
    
ptr_escrita:
    .8byte 0
    
pixel:
    .8byte 0