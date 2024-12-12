#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// def d'une structure ELF header qui se trouve sur internet
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

void parse_elf_header(const char *filename) {
    // on ouvre le fichier en mode lecture binaire pour lire le contenu brut du fichier ELF.
    FILE *file = fopen(filename, "rb");
    if (!file) {
        perror("Erreur d'ouverture du fichier");
        exit(EXIT_FAILURE);
    }

    Elf64_Ehdr elf_header;
    // on lit l'en-tête ELF et on le stocke dans une structure dédiée.
    fread(&elf_header, sizeof(Elf64_Ehdr), 1, file);

    // on vérifie que les 4 premiers octets correspondent au 'magic number' ELF pour vérifier que c'est bien un fichier ELF valide.
    if (memcmp(elf_header.e_ident, "\x7f" "ELF", 4) != 0) {
        fprintf(stderr, "Pas un fichier ELF valide!\n");
        fclose(file);
        exit(EXIT_FAILURE);
    }

    // si le fichier est valide, on affiche des informations.
    printf("Fichier ELF valide detecté.\n");
    printf("Entry Point: 0x%lx\n", elf_header.e_entry); 
    printf("Program Header Offset: %lu\n", elf_header.e_phoff); 
    fclose(file);
}

int main(int argc, char *argv[]) {
    // vérification des arguments pour s'assurer qu'un fichier est spécifié.
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <ELF file>\n", argv[0]);
        return EXIT_FAILURE;
    }

    parse_elf_header(argv[1]);
    return EXIT_SUCCESS;
}
