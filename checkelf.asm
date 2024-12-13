section .data
    filename db "/home/cytech/Shellcode_project/hello_world", 0  ; nom du fichier pour l'instant
    elf_magic db 0x7F, 'E', 'L', 'F'    ; signature ELF
    valid_elf_msg db "c'est un elf valide.", 10, 0
    invalid_elf_msg db "ce n'est pas un elf valide.", 10, 0

section .bss
    buffer resb 4     ; tampon pour lire les 4 premiers octets

section .text
    global _start

_start:
    ; Ouvrir le fichier
    mov rax, 2                  ; syscall: open
    lea rdi, [filename]         ; le nom du fichier
    mov rsi, 0                  ; O_RDONLY
    mov rdx, 0                  ; aucun mode (permission non spécifiée)
    syscall
    test rax, rax               ; on vérifie si l'ouverture a réussi
    js invalid_file             ; si y'a erreur, on affiche un message et on sort
    mov rdi, rax                ; stock le descripteur de fichier

    ; Lire les 4 premiers octets
    mov rax, 0                  ; syscall: read
    mov rsi, buffer             ; adresse du tampon
    mov rdx, 4                  ; taille de lecture
    syscall
    test rax, rax               ; vérifie si la lecture a réussi
    js invalid_file             ; si y'a erreur, affiche un message et sortir

    ; Comparer avec le magic number elf
    lea rsi, [elf_magic]        ; charge la signature elf
    lea rdi, [buffer]           ; charge le tampon lu
    mov rcx, 4                  ; nombre d'octets à comparer
    repe cmpsb                  ; comparer les octets
    jne not_elf                 ; si différent, affiche un message et sortir

    ; message de confirmation si elf valide
    lea rsi, [valid_elf_msg]
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; stdout
    mov rdx, 20                 ; taille du message
    syscall
    jmp exit_program

not_elf:
    ; affiche un message si ce n'est pas un elf
    lea rsi, [invalid_elf_msg]
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; stdout
    mov rdx, 22                 ; taille du message
    syscall
    jmp exit_program

invalid_file:
    ; Afficher un message en cas d'erreur d'ouverture
    lea rsi, [invalid_elf_msg]
    mov rax, 1                  ; pareil
    mov rdi, 1                 
    mov rdx, 22                
    syscall

exit_program:
    ; Sortir proprement
    mov rax, 60                 ; syscall: exit
    xor rdi, rdi                ; code de retour 0
    syscall

