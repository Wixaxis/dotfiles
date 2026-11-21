# Instrukcje dla agentów

To repozytorium dokumentuje intencje właściciela i może zawierać zasoby pomocne w odtworzeniu konfiguracji. Zacznij od [README.md](README.md), [zasad konstytucji](constitution/README.md), profilu odpowiedniej maszyny i dokumentów związanych z zadaniem.

- Najpierw rozpoznaj maszynę i jej bieżący stan. Nie zakładaj, że dokumentacja jest już zastosowana albo że ustawienia innej maszyny pasują do tej. Przy przygotowaniu komputera stosuj [kolejność prac](constitution/README.md#kolejność-przygotowania-komputera): wcześnie ustal programy, zależności i potrzebny udział właściciela, aby później móc samodzielnie skonfigurować resztę.
- Odróżniaj stan docelowy, fakty zaobserwowane na konkretnej maszynie i kwestie do ustalenia. Nie przedstawiaj przypuszczeń jako faktów.
- Stosuj zasady ogólne i właściwy profil maszyny; zakres oraz wyjątki zapisuj jawnie. Jeśli dokumenty są sprzeczne lub brakuje decyzji potrzebnej do bezpiecznej zmiany, zapytaj właściciela.
- Dostosuj sposób realizacji do systemu i zastanego środowiska. Szanuj istniejące dane i lokalne zmiany; przed operacją destrukcyjną lub trudną do odwrócenia wyjaśnij skutki i uzyskaj zgodę.
- Nie zapisuj w repozytorium sekretów, kluczy prywatnych, tokenów ani danych osobistych, które nie muszą być publiczne. Opisuj sposób ich bezpiecznego dostarczenia bez podawania wartości.
- Po uzgodnionej zmianie aktualizuj właściwe dokumenty, kiedy zmienia się zamierzony stan lub wiedza o maszynie. Zapisuj źródło i datę obserwacji, jeśli jej aktualność ma znaczenie.
- Skupiaj się na uzgodnionych wymaganiach i zmianach względem zastanego środowiska. Nie opisuj ani nie zmieniaj jego domyślnych elementów tylko dlatego, że istnieją.
- Można przechowywać niewrażliwe zasoby i pliki konfiguracyjne, jeśli ułatwiają odtworzenie uzgodnionych ustawień; opisuj ich przeznaczenie, zakres i sposób użycia. Nie dodawaj automatyzacji ani konfiguracji tylko dlatego, że poprzednia wersja repozytorium je miała.

Szablony są pomocą, nie źródłem wymagań dla żadnej maszyny. Puste sekcje i przykłady nie oznaczają podjętych decyzji.
