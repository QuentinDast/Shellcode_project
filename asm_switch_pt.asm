section .data
    chemin_fichier db '/home/cytech/Shellcode_project/hello_world', 0
    position_debut equ 0xB0        ; début des segments
    taille_segment equ 56          ; taille d'un segment elf64
    position_flags_offset equ 4    ; décalage pour accéder aux flags
    nouveau_type_pt db 1           ; valeur pour pt_load
    nouveaux_flags dd 0x00000007   ; nouveaux flags RWX

section .bss
    descrip_fichier resq 1
    buffer_segment resb 56         ; buffer pour lire un segment

section .text
global _start

_start:
    ; ouvre le fichier elf
    mov rax, 2
    lea rdi, [chemin_fichier]
    mov rsi, 2
    xor rdx, rdx
    syscall
    test rax, rax
    js erreur
    mov [descrip_fichier], rax

    ; initialise la position de lecture au début
    mov r12, position_debut

cherche_pt_note:
    ; se positionne à l'offset actuel
    mov rax, 8
    mov rdi, [descrip_fichier]
    mov rsi, r12
    xor rdx, rdx
    syscall
    test rax, rax
    js erreur

    ; lit un segment dans le buffer
    mov rax, 0
    mov rdi, [descrip_fichier]
    lea rsi, [buffer_segment]
    mov rdx, taille_segment
    syscall
    test rax, rax
    js erreur

    ; vérifie si le type est pt_note 
    cmp dword [buffer_segment], 0x04
    je modifie_segment

    ; passe au segment suivant (avance de 56 octets)
    add r12, taille_segment
    cmp r12, 0x400 ; limite arbitraire pour éviter une boucle infinie
    jl cherche_pt_note

    jmp fin_programme

modifie_segment:
    ; se repositionne pour écrire le type PT_LOAD
    mov rax, 8
    mov rdi, [descrip_fichier]
    mov rsi, r12
    xor rdx, rdx
    syscall

    ; remplace pt_note par pt_load
    mov rax, 1
    mov rdi, [descrip_fichier]
    lea rsi, [nouveau_type_pt]
    mov rdx, 1
    syscall

    ; modifie les flags
    mov rax, 8
    mov rsi, r12
    add rsi, position_flags_offset
    xor rdx, rdx
    syscall

    mov rax, 1
    lea rsi, [nouveaux_flags]
    mov rdx, 4
    syscall
    jmp fin_programme

erreur:
    mov rax, 60
    mov rdi, -1
    syscall

fin_programme:
    mov rax, 60
    xor rdi, rdi
    syscall

