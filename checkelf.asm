section .bss
    filename resb 256             ; tampon pour stocker le nom du fichier (max 256 caractères)
    buffer resb 4                ; tampon pour lire les 4 premiers octets

section .data
    elf_magic db 0x7F, 'E', 'L', 'F'    ; signature elf
    valid_elf_msg db "c'est un elf valide.", 10, 0
    invalid_elf_msg db "ce n'est pas un elf valide.", 10, 0
    usage_msg db "usage: ./program <elf_file>", 10, 0
    debug_msg db "argument fourni: ", 0

section .text
    global _start

_start:
    ; vérifie que l'argument est fourni
    cmp rdi, 2                   ; vérifie que le nombre d'arguments est 2 (programme + fichier)
    jne usage                    ; si ce n'est pas le cas, affiche le message d'utilisation

    ; charge le nom du fichier donné en argument
    mov rsi, [rsp + 16]          ; adresse du deuxième argument (nom du fichier elf)
    lea rdi, [filename]          ; tampon pour stocker le nom
    xor rcx, rcx                 ; réinitialise rcx pour boucle
copy_filename:
    lodsb                        ; charge le prochain octet (byte) depuis rsi
    stosb                        ; stocke cet octet dans rdi
    test al, al                  ; vérifie si l'octet est nul (fin de la chaîne)
    jnz copy_filename            ; continue jusqu'à la fin de la chaîne

    ; affiche le nom du fichier pour débogage
    lea rsi, [debug_msg]         ; message de débogage
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; stdout
    mov rdx, 17                  ; taille du message
    syscall

    lea rsi, [filename]          ; affiche le fichier passé en argument
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; stdout
    mov rdx, 256                 ; taille maximale supposée
    syscall

    ; ouvrir le fichier
    mov rax, 2                   ; syscall: open
    lea rdi, [filename]          ; nom du fichier
    mov rsi, 0                   ; o_rdonly
    mov rdx, 0                   ; aucun mode (permission non spécifiée)
    syscall
    test rax, rax                ; vérifie si l'ouverture a réussi
    js invalid_file              ; si erreur, affiche un message et sort
    mov rdi, rax                 ; stocke le descripteur de fichier

    ; lire les 4 premiers octets
    mov rax, 0                   ; syscall: read
    mov rsi, buffer              ; adresse du tampon
    mov rdx, 4                   ; taille de lecture
    syscall
    test rax, rax                ; vérifie si la lecture a réussi
    js invalid_file              ; si erreur, affiche un message et sort

    ; comparer avec le magic number elf
    lea rsi, [elf_magic]         ; charge la signature elf
    lea rdi, [buffer]            ; charge le tampon lu
    mov rcx, 4                   ; nombre d'octets à comparer
    repe cmpsb                   ; compare les octets
    jne not_elf                  ; si différent, affiche un message et sort

    ; message de confirmation si elf valide
    lea rsi, [valid_elf_msg]
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; stdout
    mov rdx, 20                  ; taille du message
    syscall
    jmp exit_program

not_elf:
    ; affiche un message si ce n'est pas un elf
    lea rsi, [invalid_elf_msg]
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; stdout
    mov rdx, 22                  ; taille du message
    syscall
    jmp exit_program

invalid_file:
    ; afficher un message en cas d'erreur d'ouverture
    lea rsi, [invalid_elf_msg]
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; stdout
    mov rdx, 22                  ; taille du message
    syscall

usage:
    ; affiche le message d'utilisation
    lea rsi, [usage_msg]
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; stdout
    mov rdx, 28                  ; taille du message
    syscall
    jmp exit_program

exit_program:
    ; sortir proprement
    mov rax, 60                  ; syscall: exit
    xor rdi, rdi                 ; code de retour 0
    syscall

