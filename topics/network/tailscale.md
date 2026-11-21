# Tailscale

## Cel i zakres

Na maszynach prywatnych używaj Tailscale jako prywatnej sieci łączącej urządzenia także poza domem. Docelowo urządzenia mają być dostępne między sobą przez [zwykłe SSH z kluczem w Proton Pass](../development/ssh.md). Służbowy MacBook Air jest całkowicie poza tym planem: nie dołączaj go do prywatnej sieci w ramach tej konfiguracji.

Zainstaluj Tailscale zgodnie z [zasadami instalacji](../../constitution/installation.md), zaloguj urządzenie do właściwej sieci i zapewnij jego połączenie po uruchomieniu. MagicDNS może zapewniać wygodne nazwy urządzeń. Dostawca tożsamości do logowania Tailscale nie został jeszcze wybrany; GitHub jest jedną z rozważanych możliwości. Przed tworzeniem sieci lub zmianą dostawcy uzgodnij wybór z właścicielem.

Dostęp wymaga uprawnionego urządzenia źródłowego oraz uruchomionej, podłączonej i dostępnej maszyny docelowej. Uśpiona lub wyłączona maszyna nie jest automatycznie osiągalna. Tailscale zapewnia sieć, a serwer SSH trzeba przygotować osobno.

## Weryfikacja

Sprawdź stan zalogowania i połączenia obu prywatnych urządzeń oraz rozpoznawanie nazwy docelowej. Następnie sprawdź rzeczywiste połączenie SSH zgodnie z [instrukcją SSH](../development/ssh.md), najlepiej także z innej sieci. Nie zmieniaj polityk istniejącej sieci bez ich wcześniejszego sprawdzenia i uzgodnienia.

## Źródła

- [Łączenie urządzeń w Tailscale](https://tailscale.com/docs/how-to/connect-to-devices)
- [Obsługiwani dostawcy tożsamości](https://tailscale.com/docs/integrations/identity)
