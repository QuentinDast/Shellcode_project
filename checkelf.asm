section .data
    chemin_fichier db "/home/cytech/Shellcode_project/hello_world", 0 ; chemin statique du fichier elf (vraiment pas super mais j'ai pas réussi pour faire mieux)
    msg_valide db "bravo, fichier elf.", 0xA, 0 
    msg_invalide db "eh non c'est pas un fichier elf ou peut être une erreur d'ouverture.", 0xA, 0 
    signature_attendue db 0x7F, 'E', 'L', 'F' ; signature elf attendue

section .bss
    buffer resb 4 ; buffer pour lire les 4 premiers octets du fichier

section .text
global _start

_start:
    call ouvre_fichier 
    test rax, rax
    js erreur 
    mov rdi, rax ; sauvegarde le descripteur de fichier

    call verif_signature ; appelle de la fonction qui vérifie la signature elf
    test rax, rax
    js message_invalide 

    call message_valide 
    jmp fin_programme

ouvre_fichier:
    mov rax, 2 ; open
    lea rdi, [chemin_fichier] 
    mov rsi, 0 ; lecture seule
    xor rdx, rdx 
    syscall
    ret

verif_signature:
    mov rax, 0 ; read
    mov rsi, buffer ; buffer pour lire les octets
    mov rdx, 4 ; lit 4 octets
    syscall
    test rax, rax
    js signature_invalide ; échec

    lea rsi, [signature_attendue] 
    lea rdi, [buffer] ; buffer qui contient les octets 
    mov rcx, 4 ; compare 4 octets
    repe cmpsb ; comparaison automatique des chaînes
    jne signature_invalide ; si différent, signature invalide
    xor rax, rax ; succès
    ret

signature_invalide:
    mov rax, -1 ; code d'erreur
    ret

message_valide:
    lea rsi, [msg_valide] 
    mov rax, 1 ; syscall: write
    mov rdi, 1 ; stdout
    mov rdx, 20 ; taille du message
    syscall
    ret

message_invalide:
    lea rsi, [msg_invalide] 
    mov rax, 1 
    mov rdi, 1 
    mov rdx, 69 
    syscall
    ret

erreur:
    lea rsi, [msg_invalide] 
    mov rax, 1 
    mov rdi, 1 
    mov rdx, 69 
    syscall
    jmp fin_programme

fin_programme:
    mov rax, 60 ; syscall: exit
    xor rdi, rdi
    syscall

