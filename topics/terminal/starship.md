# Starship

## Zakres i stan docelowy

Instaluj Starship na wszystkich komputerach i konfiguruj go w używanych powłokach, w tym Bash, Zsh i Nushell, zależnie od systemu. Zachowaj wygląd i działanie wcześniejszej osobistej konfiguracji jako punkt odniesienia, uwzględniając możliwości aktualnych wersji i poszczególnych powłok.

## Zasoby i odtworzenie

- [starship.toml](resources/starship/starship.toml) — poprzednia konfiguracja promptu, zachowana z dawnego repozytorium. Wskaźnik powłoki, katalog oraz informacje o Git, czasie polecenia i środowisku stanowią punkt odniesienia.
- [nushell-prompt.nu](resources/starship/nushell-prompt.nu) i [bash-prompt.bash](resources/starship/bash-prompt.bash) — historyczne przykłady integracji i prawego promptu. Traktuj je jako materiał pomocniczy, nie bezwarunkowe zamienniki obecnej konfiguracji powłoki. W szczególności przykład Bash ingeruje w `PROMPT_COMMAND`: sprawdź zgodność z mise i innymi istniejącymi hookami.

Zainstaluj Starship metodą właściwą dla systemu, dostosuj jego konfigurację i inicjalizację do aktualnych wersji oraz scal je z istniejącymi ustawieniami. Nushell i Zsh obsługują prawy prompt inaczej niż Bash; sprawdź efekt w każdej wymaganej powłoce, zamiast zakładać identyczne zachowanie.

## Weryfikacja

Uruchom nowe interaktywne sesje wymaganych powłok. Sprawdź czytelność katalogu i informacji Git w repozytorium, prawy prompt, wynik po wykonaniu polecenia oraz działanie integracji mise. Zwróć uwagę na ucinanie promptu i błędy po zmianie katalogu.
Zastosuj [zasady instalacji](../../constitution/installation.md) i uwzględnij [motyw Nord](../appearance/theme.md).
