section .data
    fichier db "/home/cytech/Shellcode_project/hello_world", 0 ; chemin statique du fichier elf (vraiment pas super mais j'ai pas réussi pour faire mieux)
    message_valide db "bravo, fichier elf.", 0xA, 0
    message_invalide db "eh non c'est pas un fichier elf ou peut être une erreur d'ouverture.", 0xA, 0
    signature_elf db 0x7F, 'E', 'L', 'F' ; signature elf attendue

section .bss
    tampon resb 4 ; tampon pour stocker les 4 premiers octets du fichier

section .text
    global _start

_start:
    ; ouvre le fichier spécifié dans le chemin statique
    mov rax, 2 ; syscall: open
    lea rdi, [fichier] ; charge le chemin du fichier
    mov rsi, 0 ; ouverture en lecture seule
    mov rdx, 0 ; aucun mode spécifique
    syscall
    test rax, rax ; vérifie si l'ouverture est réussie
    js erreur_fichier ; saute à erreur_fichier si échec
    mov rdi, rax ; sauvegarde le descripteur de fichier

    ; lit les 4 premiers octets du fichier
    mov rax, 0 ; syscall: read
    mov rsi, tampon ; charge l'adresse du tampon
    mov rdx, 4 ; lit 4 octets
    syscall
    test rax, rax ; vérifie si la lecture est réussie
    js erreur_fichier ; saute à erreur_fichier si échec

    ; compare les octets lus avec la signature elf attendue
    lea rsi, [signature_elf] ; charge la signature elf
    lea rdi, [tampon] ; charge le tampon contenant les octets lus
    mov rcx, 4 ; initialise le compteur pour comparer 4 octets
boucle_comparaison:
    mov al, byte [rsi] ; charge un octet de la signature
    cmp al, byte [rdi] ; compare avec l'octet correspondant du tampon
    jne non_elf ; saute à non_elf si différence
    inc rsi ; passe à l'octet suivant dans la signature
    inc rdi ; passe à l'octet suivant dans le tampon
    loop boucle_comparaison ; répète jusqu'à ce que rcx atteigne 0

    ; affiche un message confirmant que le fichier est un elf valide
    lea rsi, [message_valide]
    mov rax, 1 ; syscall: write
    mov rdi, 1 ; stdout
    mov rdx, 20 ; taille du message
    syscall
    jmp fin_programme 

non_elf:
    ; affiche un message si le fichier n'est pas un elf
    lea rsi, [message_invalide] 
    mov rax, 1 
    mov rdi, 1 
    mov rdx, 69
    syscall
    jmp fin_programme 

erreur_fichier:
    ; affiche un message en cas d'erreur d'ouverture ou de lecture
    lea rsi, [message_invalide] 
    mov rax, 1 
    mov rdi, 1 
    mov rdx, 69 
    syscall

fin_programme:
    ; quitte le programme
    mov rax, 60 ; syscall: exit
    xor rdi, rdi ; code de retour 0
    syscall

