# Skróty powłoki

## Zakres

Zachowuj poniższe skróty w używanych interaktywnie powłokach, odpowiednio do ich składni i systemu. Wymagane powłoki określa dokument [powłok](shells.md). Skróty uruchamiające konkretne programy konfiguruj tam, gdzie te programy są dostępne i obowiązują dla danej maszyny.

## Skróty

- `vim` → `nvim`.
- `..`, `...`, `....` → przejście odpowiednio o jeden, dwa lub trzy katalogi wyżej.
- `ca` → `cursor-agent`, `oc` → `opencode`, `co` → `codex`; zakres instalacji określają [narzędzia AI CLI](../development/ai-cli.md).
- `lg` → `lazygit`; zobacz [Lazygit](../development/lazygit.md).
- `ls` → czytelna lista plików; `lsa` → również pliki ukryte, posortowane według czasu modyfikacji; `lst` → drzewo katalogów o głębokości dwóch poziomów; `lsta` → takie drzewo również z plikami ukrytymi. W Bash i Zsh można używać `eza`, chyba że dostępne jest lepsze rozwiązanie. W Nushell używaj możliwości tej powłoki; `eza` nie jest w niej wymagane. Niezależnie od realizacji zachowaj działanie tych skrótów.
- `ff` → interaktywny wybór pliku w bieżącym katalogu; `ffn` → interaktywne wyszukiwanie pliku po nazwie; `ffc` → interaktywne wyszukiwanie plików po zawartości. Wykorzystuj [narzędzia wyszukiwania](search.md), dostosowując realizację do powłoki.
- `mr` → `mise run`.
- `reload` → ponowne wczytanie konfiguracji bieżącej powłoki, tam gdzie jest to obsługiwane.

## Weryfikacja

W nowych interaktywnych sesjach wymaganych powłok sprawdź rozpoznawanie skrótów, przechodzenie między katalogami oraz widoki listy i drzewa na katalogu testowym z ukrytym plikiem. Przetestuj `ff`, `ffn` i `ffc` na plikach testowych, a skróty narzędzi sprawdź tylko tam, gdzie odpowiedni program jest wymagany. Potwierdź, że `reload` rzeczywiście odnawia ustawienia bieżącej powłoki.

Tmux i tmuxinator nie są już używane, więc nie odtwarzaj skrótu `mux`.
