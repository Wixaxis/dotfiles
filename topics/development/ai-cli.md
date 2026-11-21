# Narzędzia AI w wierszu poleceń

## Zakres i stan docelowy

- **Maszyny prywatne:** instaluj Codex CLI, OpenCode CLI i Cursor CLI. OpenCode i Cursor należy zalogować i autoryzować możliwie wcześnie po instalacji.
- **Maszyna służbowa:** instaluj Codex CLI. Nie instaluj tam OpenCode CLI ani Cursor CLI w ramach tej konstytucji.
- **Wszystkie maszyny:** nie instaluj Claude ani Claude Code.

Stosuj [zasady instalacji](../../constitution/installation.md). Jeśli nie wiadomo, czy maszyna jest prywatna czy służbowa, zapytaj właściciela przed instalacją narzędzi zależnych od tego podziału.

Codex właściciel autoryzuje samodzielnie tam, gdzie będzie to potrzebne; agent nie powinien sam rozpoczynać jego autoryzacji. Logowanie pozostałych narzędzi może wymagać udziału właściciela. Sprawdź wynik bez ujawniania tokenów i kodów; nie zapisuj poświadczeń w repozytorium. Sposób autoryzacji i konto dobierz zgodnie z aktualnym wyborem właściciela.
