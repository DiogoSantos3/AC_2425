#include <stdio.h>
#include <ctype.h>

int16_t which_vowel(char letter) {
    int16_t i;
    // Convert to lowercase to handle both uppercase and lowercase vowels
    letter = tolower(letter);
    switch (letter) {
        case 'a': i = 0; break;
        case 'e': i = 1; break;
        case 'i': i = 2; break;
        case 'o': i = 3; break;
        case 'u': i = 4; break;
        default: i = -1;
    }
    return i;
}

int main() {
    char letter;
    printf("Digite uma letra: ");
    scanf(" %c", &letter); // O espaço antes do %c é para consumir qualquer espaço em branco anterior.

    int16_t result = which_vowel(letter);
    if (result >= 0) {
        printf("A letra '%c' é uma vogal com índice %d.\n", letter, result);
    } else {
        printf("A letra '%c' não é uma vogal.\n", letter);
    }

    return 0;
}
