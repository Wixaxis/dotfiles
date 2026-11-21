# Neovim

## Zakres i stan docelowy

Na każdym komputerze zainstaluj i skonfiguruj Neovim zgodnie z osobnym repozytorium [Wixaxis/neovim-config](https://github.com/Wixaxis/neovim-config). Stosuj [zasady instalacji](../../constitution/installation.md). Ustaw Neovim jako domyślny edytor dla poleceń i narzędzi, które korzystają ze zmiennych środowiskowych edytora (np. `EDITOR` i `VISUAL`), z uwzględnieniem sposobu konfiguracji danego systemu i powłoki.

Obecnie używaj gałęzi `nvim-12`. Właściciel planuje później zmienić domyślną gałąź repozytorium i uczynić `main` docelową. Po tej zmianie należy zaktualizować tę decyzję; nie przełączaj się na `main` przed jej potwierdzeniem.

## Weryfikacja

W nowej sesji powłoki sprawdź, czy zmienne wskazują na Neovim i czy narzędzie korzystające z edytora go uruchamia. Sprawdź źródło i gałąź konfiguracji, uruchom Neovim bez interfejsu w celu wykrycia błędów startowych, a następnie sprawdź jego działanie interaktywnie. Nie nadpisuj istniejących lokalnych zmian.

## Maszyny

- [Surface Go 2](../../machines/surface-go-2/README.md): istniejący checkout zawiera lokalne poprawki, których nie należy nadpisywać.
