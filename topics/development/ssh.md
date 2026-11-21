# SSH między prywatnymi maszynami

## Cel i zakres

Prywatne maszyny mają być dostępne między sobą przez zwykłe SSH, korzystające z [Tailscale jako sieci](../network/tailscale.md) i agenta SSH [Proton Pass](../security/proton-pass.md) do uwierzytelniania kluczem. Służbowy MacBook Air nie uczestniczy w tym rozwiązaniu. To oddzielne etapy: zalogowanie do Proton Pass nie loguje urządzenia do Tailscale.

Na początek planowany jest jeden osobisty klucz użytkownika w Proton Pass, dostępny po jego autoryzacji na prywatnych urządzeniach. Tylko klucz publiczny należy dodać do `authorized_keys` odpowiedniego konta na maszynach docelowych. Nie zapisuj klucza prywatnego ani poświadczeń w repozytorium, nie kopiuj ich na serwer docelowy i nie nadpisuj istniejących kluczy lub konfiguracji. Klucz `Personal devices SSH` został utworzony w Proton Pass dla Surface. Zasady dostępu awaryjnego pozostają do ustalenia.

Na maszynach docelowych potrzebny jest działający serwer OpenSSH i dostęp przez Tailscale. Skonfiguruj dostęp tak, aby nie wystawiać SSH publicznie tylko na potrzeby tego rozwiązania. Nie włączaj Tailscale SSH w miejsce zwykłego OpenSSH: jego uwierzytelnianie jest osobnym mechanizmem i nie korzysta z tego klucza Proton Pass.

## Przygotowanie i weryfikacja

Sprawdź zastany serwer, reguły sieciowe, ustawienia SSH i klucze publiczne bez ujawniania sekretów. Skonfiguruj agenta Proton Pass w używanych powłokach zgodnie z aktualną instrukcją producenta. Zweryfikuj tożsamość serwera przy pierwszym połączeniu i zachowaj jego klucz hosta; nie wyłączaj kontroli `known_hosts`.

Sprawdź, czy agent widzi odpowiedni klucz publiczny, a następnie połącz się z innej autoryzowanej prywatnej maszyny przez nazwę lub adres Tailscale i potwierdź docelowego użytkownika oraz host. Sprawdź również, że połączenie nie działa z nieuprawnionego źródła zgodnie z przyjętą polityką. Nie uznawaj obecności konfiguracji za dowód działania połączenia.

Na [Surface Go 2](../../machines/surface-go-2/README.md) zapisano szczegóły wdrożenia, w tym zależność konfiguracji serwera od adresów Tailscale.

## Źródła

- [Agent SSH Proton Pass](https://proton.me/support/ssh-agent)
- [Zwykłe SSH przez Tailscale](https://tailscale.com/docs/reference/ssh-over-tailscale)
