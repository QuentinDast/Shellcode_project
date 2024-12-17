# Shellcode_project

Y'a eu un problème avec mon push, en fait j'ai push un asm_switch_pt sans le .asm. J'ai annuler le push mais dès que j'ai push à nouveau avec le bon nom de fichier ça a changé la date de push pour checkelf.asm et ça a rajouté un asm_switch_pt avec rien dedans. Le checkelf est là depuis plusieurs jours et j'ai juste update le code de asm_switch_pt.asm. 17/12/2024 14:55 

# Pour lancer le code : 

Pour checkelf.asm et asm_switch_pt.asm il faut mettre le chemin absolu où se trouve le fichier elf. Il faut le faire directement dans le code. Pour tester checkelf, vous pouvez changer le nom du fichier elf en un fichier qui n'existe pas. Vu que je n'ai réussi qu'à faire en statique il faut recompiler le code pour tester. Par exemple dans le terminal :
nasm -f elf64 -g checkelf.asm -o checkelf.o
ld -o checkelf checkelf.o
./checkelf




