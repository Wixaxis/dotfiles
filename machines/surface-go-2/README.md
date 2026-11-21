# Surface Go 2

## Tożsamość

Microsoft Surface Go 2, nazwa hosta `surface-go`. W chwili inwentaryzacji działa na nim Omarchy 4.5.0. Ten opis identyfikuje maszynę i jej obecne środowisko; nie wymaga instalacji Omarchy na innych komputerach. Jest to maszyna prywatna.

## Ekran

Na wbudowanym ekranie `eDP-1` zachowaj skalowanie Hyprland **1,6**. Rozdzielczość zaobserwowana podczas inwentaryzacji to 1920 × 1280 przy 60 Hz. Skalowanie innych ekranów i maszyn wymaga osobnego dopasowania.

## Okna w Omarchy

Obowiązują [ustawienia okien Omarchy](../../topics/omarchy/window-management.md). Na tym urządzeniu nowe kolumny układu przewijanego mają domyślną szerokość **0,85** dostępnego obszaru. Szerokość na innych maszynach należy dobrać osobno.

## Wygląd

Obowiązują [motyw Nord](../../topics/appearance/theme.md) i [pasek Omarchy](../../topics/omarchy/bar.md). Konfiguracja paska tej maszyny stanowi wzorzec dla innych instalacji Omarchy.

## Klawiatura i touchpad

Obowiązują preferencje dotyczące [klawiatury](../../topics/input/keyboard.md) i [touchpada](../../topics/input/touchpad.md). Polski układ `pl`, naturalne przewijanie i gesty trzema palcami są ustawione w `~/.config/hypr/input.lua`.

## Przeglądarki

Obowiązują [zasady wyboru przeglądarek](../../topics/browsers/README.md). Na tej maszynie przeglądarką podstawową ma być Zen. Dodatkową przeglądarką do treści DRM ma być Chrome.

Na Surface zachowaj skalę Zen `layout.css.devPixelsPerPx = 1.25` oraz lokalne stylowanie Nord. Wzorzec stylowania znajduje się w [userChrome.css](resources/zen/userChrome.css). Umieść go w `chrome/userChrome.css` właściwego profilu Zen i włącz `toolkit.legacyUserProfileCustomizations.stylesheets = true` w ustawieniach profilu; zachowaj inne istniejące ustawienia i style użytkownika. Uruchom ponownie Zen i sprawdź wygląd. Stylowanie nie synchronizuje się automatycznie ze zmianą motywu Omarchy; jego przydatność na innych maszynach nie została ustalona.

## Druk 3D

Obowiązuje [Creality Print](../../topics/3d-printing/creality-print.md). Podczas inwentaryzacji był zainstalowany ręcznie jako AppImage; sposób docelowej instalacji należy ocenić według zasad dla Omarchy.

## Narzędzia programistyczne

Obowiązują ustalenia dla [Neovim](../../topics/development/neovim.md), [GitHub CLI](../../topics/development/github-cli.md), [narzędzi AI CLI](../../topics/development/ai-cli.md) i [aplikacji desktopowych do pracy z agentami](../../topics/development/t3-code.md). Neovim jest powiązany z checkoutem `~/Work/neovim-config` na gałęzi `nvim-12`; podczas inwentaryzacji zawierał niezacommitowane poprawki kompatybilności Treesitter i motywu. Zachowaj je przed zmianą checkoutu.

## Dostęp zdalny

Docelowo obowiązuje plan [Tailscale](../../topics/network/tailscale.md) i [SSH z Proton Pass](../../topics/development/ssh.md) dla maszyn prywatnych. 21 listopada 2026 zainstalowano Tailscale i Proton Pass, zalogowano je i uruchomiono usługi Tailscale oraz OpenSSH. Klucz `Personal devices SSH` utworzono w Proton Pass; jego klucz publiczny dodano do `~/.ssh/authorized_keys`. Agent używa gniazda `~/.ssh/proton-pass-ssh-agent.sock`; adres skonfigurowano dla sesji użytkownika i interaktywnego Bash. Proton Pass musi być uruchomiony i odblokowany na maszynie, z której inicjowane jest połączenie.

OpenSSH nasłuchuje tylko na adresach Tailscale tej maszyny, `100.106.178.72` oraz `fd7a:115c:a1e0::e837:b249`; dopuszcza konto `wixaxis`, autoryzację kluczem, bez logowania hasłem i na root. UFW dopuszcza port 22 na `tailscale0`. Jednostka SSH startuje po usłudze Tailscale i ponawia start, gdy adresy nie są jeszcze dostępne. Jeśli urządzenie zostanie usunięte z tailnetu i otrzyma nowe adresy, konfigurację nasłuchu trzeba zaktualizować.

Lokalnie zweryfikowano logowanie do adresu Tailscale przez agenta Proton Pass i porównano klucz hosta z lokalnym plikiem serwera. Połączenie z innego urządzenia i z innej sieci nadal wymaga sprawdzenia.

## Terminale

Obowiązują [ustalenia dotyczące terminali](../../topics/terminal/README.md). Podczas inwentaryzacji domyślny był Herdr desktop, a polecenia uruchamiane w terminalu kierowano do Foot. Docelowym prostszym terminalem ma być Ghostty; zmiana nie została jeszcze wykonana.

## Obserwacje

15 listopada 2026: skalę `1,6` i szerokość kolumn `0,85` potwierdzono w działającym Hyprlandzie. Odpowiednie ustawienia znajdują się w `~/.config/hypr/monitors.lua` i `~/.config/hypr/looknfeel.lua`.
