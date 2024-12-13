#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define PT_LOAD 1
#define PT_NOTE 4

// structure représentant un header elf (def basique trouvé sur internet)
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

// structure représentant un header de programme elf (pareil)
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

void modify_specific_pt_note_to_pt_load(const char *filename) {
    // ouvre le fichier elf en mode lecture/écriture binaire
    FILE *file = fopen(filename, "r+b");
    if (!file) {
        perror("erreur lors de l'ouverture du fichier");
        exit(EXIT_FAILURE);
    }

    // lit l'header elf pour localiser les headers de programme
    Elf64_Ehdr elf_header;
    fread(&elf_header, sizeof(Elf64_Ehdr), 1, file);

    // vérifie que le fichier est bien un elf valide
    if (memcmp(elf_header.e_ident, "\x7f" "ELF", 4) != 0) {
        fprintf(stderr, "fichier elf invalide \n");
        fclose(file);
        exit(EXIT_FAILURE);
    }

    // offset exact du segment pt_note (0x358)
    uint64_t target_offset = 0x358; 

    // se déplace à l'offset du pt_note 
    fseek(file, target_offset, SEEK_SET);

    Elf64_Phdr phdr;
    fread(&phdr, sizeof(Elf64_Phdr), 1, file);

    // vérifie si le segment est de type pt_note
    if (phdr.p_type == PT_NOTE) {
        printf("pt_note trouvé à l'offset 0x%lx\n", target_offset);

        // modifie le type du segment en pt_load
        phdr.p_type = PT_LOAD;
        // modifie les permissions pour lecture, écriture et exécution
        phdr.p_flags = 7;

        // met à jour les tailles 
        uint64_t payload_size = 64; // taille de la charge utile
        phdr.p_filesz = payload_size;
        phdr.p_memsz = payload_size;

        // revient à la position de l'entrée pour écrire les modifications
        fseek(file, target_offset, SEEK_SET);
        fwrite(&phdr, sizeof(Elf64_Phdr), 1, file);

        printf("pt_note modifié en pt_load avec permissions RWE\n");
    } else {
        printf("le segment à l'offset 0x%lx n'est pas de type pt_note\n", target_offset);
    }

    fclose(file); 
}

int main(int argc, char *argv[]) {
    // vérifie qu'un fichier a été spécifié en argument
    if (argc < 2) {
        fprintf(stderr, "usage: %s <fichier elf>\n", argv[0]);
        return EXIT_FAILURE;
    }

    // appele fonction
    modify_specific_pt_note_to_pt_load(argv[1]);

    printf("modification terminée\n");
    return EXIT_SUCCESS;
}

