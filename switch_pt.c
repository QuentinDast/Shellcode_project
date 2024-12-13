#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define PT_LOAD 1
#define PT_NOTE 4

// def de la structure de l'en-tête ELF (def basique trouvé sur internet)
typedef struct {
    unsigned char e_ident[16]; 
    uint16_t e_type;           
    uint16_t e_machine;        
    uint32_t e_version;        
    uint64_t e_entry;          
    uint64_t e_phoff;          
    uint64_t e_shoff;          
    uint32_t e_flags;          
    uint16_t e_ehsize;        
    uint16_t e_phentsize;      
    uint16_t e_phnum;          
    uint16_t e_shentsize;     
    uint16_t e_shnum;          
    uint16_t e_shstrndx;       
} Elf64_Ehdr;

// def struct d'une entrée dans la table des headers de programme (pareil)
typedef struct {
    uint32_t p_type;   
    uint32_t p_flags;  
    uint64_t p_offset; 
    uint64_t p_vaddr;  
    uint64_t p_paddr;  
    uint64_t p_filesz; 
    uint64_t p_memsz;  
    uint64_t p_align;  
} Elf64_Phdr;

// fonction 
void modify_pt_note_to_pt_load(const char *filename) {
    // ouvre le fichier elf en mode lecture/écriture binaire
    FILE *file = fopen(filename, "r+b");
    if (!file) {
        perror("erreur pendant l'ouverture du fichier");
        exit(EXIT_FAILURE);
    }

    // lit l'header elf pour localiser les headers de programme
    Elf64_Ehdr elf_header;
    fread(&elf_header, sizeof(Elf64_Ehdr), 1, file);

    // vérifie que le fichier est bien un elf valide
    if (memcmp(elf_header.e_ident, "\x7f" "ELF", 4) != 0) {
        fprintf(stderr, "fichier elf invalide !\n");
        fclose(file);
        exit(EXIT_FAILURE);
    }

    // on se déplace au début de la table des headers de programme
    fseek(file, elf_header.e_phoff, SEEK_SET);

    // parcours chaque entrée de la table des headers de programme
    for (int i = 0; i < elf_header.e_phnum; i++) {
        Elf64_Phdr phdr;
        fread(&phdr, sizeof(Elf64_Phdr), 1, file);

        // vérifie si le segment est de type pt_note
        if (phdr.p_type == PT_NOTE) {
            printf("pt_note trouvé à l'index %d\n", i);

            // modif le type du segment en pt_load
            phdr.p_type = PT_LOAD;
            // modif les permissions pour lecture, écriture et exécution
            phdr.p_flags = 7;

            // on met à jour les tailles
            uint64_t payload_size = 64; // taille de la charge utile 
            phdr.p_filesz = payload_size;
            phdr.p_memsz = payload_size;

            // revient à la position de l'entrée pour écrire les modifications
            fseek(file, -(long)sizeof(Elf64_Phdr), SEEK_CUR);
            fwrite(&phdr, sizeof(Elf64_Phdr), 1, file);

            printf("pt_note modif en pt_load avec permissions RWE.\n");
            break;
        }
    }

    fclose(file); 
}

int main(int argc, char *argv[]) {
    // rapide vérif qu'un fichier a été spécifié en argument.
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <fichier ELF>\n", argv[0]);
        return EXIT_FAILURE;
    }

    // appelle de la fonction
    modify_pt_note_to_pt_load(argv[1]);

    printf("modif terminée.\n");
    return EXIT_SUCCESS;
}
