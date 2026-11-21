# Pasek Omarchy

## Zakres i stan docelowy

Na maszynach z Omarchy używaj obecnej konfiguracji paska z [Surface Go 2](../../machines/surface-go-2/README.md). Ta decyzja nie narzuca paska innym systemom ani środowiskom.

- Pozycja: lewa krawędź; tło `glassy`.
- `left`: menu, przestrzenie robocze.
- `centerBegin`: wskaźniki.
- `center`: zegar, format `dddd HH:mm`, alternatywny `d MMMM 'W'ww yyyy`, pionowy `HH\nmm`.
- `centerEnd`: zegary miast, pogoda, aktualizacje systemu. Miasta i strefy: Warszawa (`Europe/Warsaw`), Dubaj (`Asia/Dubai`), Tokio (`Asia/Tokyo`), Los Angeles (`America/Los_Angeles`), Nowy Jork (`America/New_York`).
- `right`: zasobnik, układ klawiatury, agenci, Bluetooth, sieć, dźwięk, monitor, zasilanie.
- Osobna lista `tray` jest pusta.

## Przygotowanie i weryfikacja

Wzorzec wyłącznie sekcji paska jest w [bar.json](resources/bar.json), na podstawie stanu Surface z 15 listopada 2026. Porównaj go z sekcją `bar` w `~/.config/omarchy/shell.json` i scal odpowiednie ustawienia, uwzględniając możliwości zainstalowanej wersji Omarchy. Nie zastępuj całego pliku tym fragmentem; zachowaj pozostałe ustawienia i dane maszyny. Sprawdź wizualnie układ i działanie elementów po zastosowaniu zmian. Pozostałe ustawienia powłoki, np. blokada i wygaszanie, nie są częścią tej decyzji.
