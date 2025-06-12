# Uruchamianie Aplikacji StwoTheEnd

Poniżej opisano proces uruchomienia aplikacji składającej się z komponentów opartych na **Dojo** (dla warstwy blockchainowej) oraz **Rust TUI** (tekstowego interfejsu użytkownika). Wymagane jest wcześniejsze zainstalowanie środowisk:  
- **Rust**  
- **Dojo (z CLI `sozo`, `katana`, `torii`)**  
- **Starknet CLI (`sncast`)**

## Krok 1: Uruchomienie sieci lokalnej

Na początku należy wystartować lokalny blockchain przy pomocy `katana` — to narzędzie symuluje środowisko Starknet.

```bash
katana --dev --dev.no-fee --http.cors-origins '*'
```

Parametry `--dev` i `--dev.no-fee` pozwalają na pracę w środowisku deweloperskim bez kosztów transakcji. Flaga `--http.cors-origins '*'` umożliwia komunikację z innymi narzędziami (np. interfejsem webowym).

## Krok 2: Budowanie i migracja świata gry

Następnie przechodzimy do folderu `dojo` i wykonujemy polecenia budujące oraz migrujące kontrakty:

```bash
cd dojo
sozo build
sozo migrate
```

Po migracji otrzymamy adres kontraktu "świata" (World Contract) — warto go zapisać, będzie potrzebny w dalszych krokach.

Dodatkowo, za pomocą komendy:

```bash
sozo inspect
```

możemy sprawdzić adresy poszczególnych kontraktów, w tym kontraktu akcji (`actions contract`). Zanotuj ten adres — przyda się podczas deployowania tokena.

## Krok 3: Uruchomienie indeksera `torii`

Narzędzie `torii` służy do monitorowania wydarzeń i interakcji w świecie Dojo. Uruchamiamy je z adresem świata z poprzedniego kroku:

```bash
torii -v <adres_świata_z_migracji> --http.cors-origins '*'
```

## Krok 4: Deklaracja kontraktu tokenu

Przechodzimy do folderu z kontraktem tokenu i deklarujemy jego klasę:

```bash
cd stwo_the_end_token
sncast declare --contract-name StwoTheEndToken --fee-token eth
```

Po wykonaniu tej komendy otrzymujemy `class_hash`, który reprezentuje wersję kontraktu. Zapisz go — będzie potrzebny przy deploymencie.

## Krok 5: Deploy kontraktu tokenu

Używając `class_hash` z poprzedniego kroku oraz adresu kontraktu akcji (z `sozo inspect`), deployujemy kontrakt tokenu:

```bash
sncast deploy --class-hash <class_hash> --fee-token eth -c <adres_kontraktu_akcji> <adres_kontraktu_akcji>
```

Adres kontraktu akcji podajemy dwukrotnie jako parametr konstrukcyjny.

## Krok 6: Uruchomienie interfejsu użytkownika

Przechodzimy do katalogu z interfejsem tekstowym i go uruchamiamy:

```bash
cd rust_tui
cargo build
cargo run
```

W interfejsie TUI możemy:
- Przełączać tryb `Developer Mode` / `Story Mode` klawiszem `t`
- Wyjść z aplikacji przyciskiem `q`

## Krok 7: Inicjalizacja stanu świata

Aby rozpocząć grę, musimy zainicjalizować świat poleceniem:

```bash
cd dojo
sozo execute StwoTheEnd-actions start_new_game <adres_tokenu>
```

Przekazujemy tutaj adres wcześniej zdeployowanego kontraktu tokenu.

## Krok 8: Podejmowanie decyzji w grze

Na tym etapie można wchodzić w interakcję ze światem gry poprzez podejmowanie decyzji. Aktualne dostępne opcje można podejrzeć w interfejsie TUI. Następnie, by wykonać wybraną akcję:

```bash
sozo execute StwoTheEnd-actions make_decision <ID_decyzji>
```

`<ID_decyzji>` należy dobrać na podstawie tego, co oferuje aktualny stan w TUI.

---

## Podsumowanie

Cały proces obejmuje:
- konfigurację lokalnego środowiska
- kompilację i deploy kontraktów
- uruchomienie interfejsu użytkownika
- interakcję z grą poprzez świat Dojo

To podejście pozwala testować i rozwijać aplikację w bezpiecznym środowisku lokalnym bez kosztów transakcyjnych.