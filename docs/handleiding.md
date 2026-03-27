# Handleiding Ceder — Schoolcijferbeheer

**ICS De Ceder – Boskoop**  
Versie 1.0 · Maart 2026

---

## Inhoudsopgave

1. [Inleiding](#1-inleiding)
2. [Inloggen en uitloggen](#2-inloggen-en-uitloggen)
3. [Navigatie](#3-navigatie)
4. [Student Progress Chart (SPC)](#4-student-progress-chart-spc)
5. [Verslagen](#5-verslagen)
6. [Cursussen en PACEs](#6-cursussen-en-paces)
7. [Inschrijvingen](#7-inschrijvingen)
8. [Inventaris](#8-inventaris)
9. [Materialen bestellen](#9-materialen-bestellen)
10. [Personen](#10-personen)
11. [Importeren](#11-importeren)
12. [Exporteren](#12-exporteren)
13. [Beheer](#13-beheer)
14. [Screenshots toevoegen](#14-screenshots-toevoegen)

---

## 1. Inleiding

**Ceder** is de digitale leeromgeving voor het bijhouden van studievoortgang, rapportage en materiaalsbeheer op basis van het ACE/PACE-curriculum. Het systeem is beschikbaar voor:

- **Docenten** — volledige toegang: invoeren, bewerken en rapporteren
- **Ouders** — alleen lezen: inzien van de voortgang van hun kinderen

> **Let op:** Alle schermen in deze handleiding zijn gebaseerd op een leraarsaccount. Ouders zien een vereenvoudigde weergave.

---

## 2. Inloggen en uitloggen

### Inloggen

1. Ga naar de website van Ceder.
2. Klik op de knop **Log in with Replit**.
3. Je wordt doorgestuurd naar de Replit-loginpagina. Log in met je Replit-account.
4. Na een geslaagde login word je automatisch teruggestuurd naar de app.

> Als je voor het eerst inlogt, kan een beheerder je nog niet de juiste rol hebben toegewezen. Neem in dat geval contact op met de systeembeheerder.

<!-- SCREENSHOT: screenshots/login.png — Loginpagina met "Log in with Replit"-knop -->

### Uitloggen

Klik rechtsonder in de zijbalk op **Log out**. Je sessie wordt beëindigd en je keert terug naar de loginpagina.

---

## 3. Navigatie

Na het inloggen zie je de **zijbalk** aan de linkerkant van het scherm. Hiervanuit navigeer je naar alle onderdelen van de applicatie.

| Menupunt | Beschrijving |
|---|---|
| Dashboard | Startpagina |
| Student Progress Chart | Voortgang per student per PACE |
| Verslagen | Jaar- en termijnrapporten |
| Cursussen & PACEs | Beheer van vakken en PACE-boekjes |
| Inschrijvingen | Koppeling student–vak–PACE-nummer |
| Inventaris | Voorraad PACE-boekjes |
| Materialen bestellen | Bestellijsten aanmaken en verwerken |
| Personen | Studenten, personeel, ouders en families |
| Importeren | Excel-bestanden importeren |
| Exporteren | Gegevens downloaden als Excel |
| Beheer | Gebruikersbeheer en instellingen |

<!-- SCREENSHOT: screenshots/navigatie.png — Zijbalk met alle menupunten -->

---

## 4. Student Progress Chart (SPC)

De **Student Progress Chart** geeft een overzicht van alle PACE-boekjes die een student heeft voltooid of bezig is mee.

<!-- SCREENSHOT: screenshots/spc.png — SPC-pagina met sterrenoverzicht van een student -->

### Een student selecteren

Gebruik het uitklapmenu bovenaan de pagina om een student te kiezen. De weergave wordt direct bijgewerkt.

### Sterrensysteem

Elke PACE wordt weergegeven als een ster:

| Kleur | Betekenis |
|---|---|
| Gekleurde ster (vakkleur) | PACE behaald (voldoende score) |
| Grijze ster | PACE afgerond maar onvoldoende |
| Lege cirkel | PACE in uitvoering (nog geen einddatum) |

De kleuren per vak zijn:

| Vak | Kleur |
|---|---|
| Wiskunde | Geel |
| Taal | Rood |
| Spelling/Woordbouw | Paars |
| Literatuur | Donkerrood |
| Wetenschap | Blauw |
| Aardrijkskunde/Maatschappij | Groen |
| Bijbelkennis | Zandoranje |

### Slagingsdrempel

- De meeste vakken: **≥ 80%**
- Woordbouw (Word Building): **≥ 90%**
  - Uitzondering: dyslectische studenten krijgen **≥ 80%**

---

## 5. Verslagen

Op de pagina **Verslagen** kunnen officiële jaarsrapporten worden bekeken en afgedrukt.

<!-- SCREENSHOT: screenshots/reports.png — Verslagenpagina met jaarrapport -->

### Jaarrapport bekijken

1. Selecteer een student in het uitklapmenu.
2. Kies het schooljaar (bijv. `25–26`).
3. Het rapport verschijnt op het scherm in afdrukklaar formaat.

### Indeling van het jaarrapport

Het jaarrapport bevat:

- **Schoollogo en naam** bovenaan
- **Studentgegevens** (naam, groep, schooljaar)
- **Supervisor** (afkomstig uit de personeelstabel)
- **Drie blokken:**
  1. *Academische vakken* — alle ingeschreven cursussen (excl. Nederlands)
  2. *Nederlands* — Taal, Spelling, Lezen, etc.
  3. *Aanvullende activiteiten* — Muziek, Gym, Projecten
- **Gedragsbeoordelingen** (Werkhouding, Samenwerking)
- **Handtekeningvelden**

### Afdrukken

Klik op de knop **Afdrukken** (rechtsboven). Het rapport wordt geoptimaliseerd weergegeven voor de printer (navigatiebalk en knoppen worden verborgen).

---

## 6. Cursussen en PACEs

Op de pagina **Cursussen & PACEs** beheer je alle vakken, PACE-boekjes en hun onderlinge koppeling.

<!-- SCREENSHOT: screenshots/materials.png — Cursussenpagina met tabelweergave -->

### Tabbladen

| Tabblad | Inhoud |
|---|---|
| Cursussen | Alle vakken met alias, niveau, type en drempel |
| PACEs | Alle PACE-boekjes met nummer en editie |
| PACE–Cursus koppelingen | Welke PACE bij welk vak hoort |

### Een nieuwe cursus aanmaken

1. Klik op **+ Cursus toevoegen** (rechtsboven).
2. Vul in:
   - **ICCE Alias** — naam zoals op het PACE-boekje
   - **Vak** — kies uit de lijst
   - **Niveau** (optioneel)
   - **Type** — Core / CourseWork / Further Credit Option
   - **Slagingsdrempel** — standaard 80
   - **Aantal PACEs** in dit vak
3. Vul voor elke PACE een nummer in. Dit mag ook alfanumeriek zijn, bijv. `1–2` of `1001A`.
4. Klik op **Cursus aanmaken**.

### PACEs toevoegen aan een bestaande cursus

1. Ga naar het tabblad **Cursussen**.
2. Klik op de rij van de gewenste cursus om hem uit te klappen.
3. Klik op **Add/Edit PACEs**.
4. Vul het aantal toe te voegen PACEs in.
5. Vul de PACE-nummers in — ook alfanumerieke nummers zoals `1–2` zijn toegestaan.
6. Klik op **Add PACEs**.

<!-- SCREENSHOT: screenshots/materials-add-paces.png — Dialoogvenster voor het toevoegen van PACEs -->

### Importeren via Excel

Je kunt cursussen en PACE–cursus-koppelingen importeren via een Excel-bestand. Gebruik de knoppen **Importeer cursussen** of **Importeer PACE-koppelingen** en volg de stappen in het dialoogvenster.

---

## 7. Inschrijvingen

De pagina **Inschrijvingen** toont per student welke PACE-nummers zijn ingeschreven in welk schooljaar en trimester.

<!-- SCREENSHOT: screenshots/enrollments.png — Inschrijvingenpagina met overzichtstabel -->

### Inschrijving bekijken

1. Selecteer een student bovenaan.
2. Kies een of meerdere schooljaren via de filteropties.
3. De tabel toont alle inschrijvingen, inclusief startdatum, einddatum en cijfer.

### Nieuwe inschrijving toevoegen

1. Klik op **+ Inschrijving toevoegen**.
2. Selecteer de cursus en vul het PACE-nummer in.
3. Kies optioneel een startdatum.
4. Klik op **Opslaan**.

---

## 8. Inventaris

De **Inventaris** beheert de fysieke voorraad PACE-boekjes op school.

<!-- SCREENSHOT: screenshots/inventory.png — Inventarispagina met PACE-versies en aantallen -->

### Weergave

De inventaris is gegroepeerd per PACE-versie. Klik op een rij om de individuele voorraad per locatie of student te zien.

### Filteropties

| Filter | Functie |
|---|---|
| Type | Filter op PACE / Score Key / Materiaal |
| Cursus | Filter op vak |
| PACE-nummer | Filter op specifiek PACE-nummer |
| Alleen voorraadlocaties | Toont alleen de vaste locaties (KG / ABCs / Juniors / Seniors) |

### Voorraadlocaties

Vier vaste locaties zijn beschikbaar als "virtuele studenten":

| ID | Alias | Locatie |
|---|---|---|
| 9996 | INV-KG | Kleuterklas |
| 9997 | INV-ABC | ABCs-groep |
| 9998 | INV-JNR | Juniors-groep |
| 9999 | INV-SNR | Seniors-groep |

### Inventaris importeren

Gebruik **Importeer inventaris** om een Excel-bestand te uploaden met voorraadaantallen. Bij conflicten (bestaande waarden) verschijnt een dialoogvenster met de keuze om te overschrijven of overslaan.

---

## 9. Materialen bestellen

De pagina **Materialen bestellen** ondersteunt het volledige bestelproces voor PACE-boekjes.

<!-- SCREENSHOT: screenshots/order-materials.png — Bestellingspagina in conceptmodus -->

### Conceptmodus (nieuwe bestelling)

Wanneer je de pagina opent, zie je de **conceptmodus**. Hier worden automatisch de benodigde PACE-boekjes geladen op basis van de lopende inschrijvingen.

**Kolommen in de tabel:**

| Kolom | Beschrijving |
|---|---|
| ID | Intern PACE-ID |
| Cursus | Vaknaam |
| PACE # | PACE-nummer |
| Aantal | Hoeveelheid |
| Student | Naam van de student |
| Initieel te bestellen | Standaard 1 per student |
| Vanuit inventaris | Negatief getal als er voorraad is (bijv. −1) |
| Definitief te bestellen | Initieel + Vanuit inventaris |

### Studenten verbergen

Zet het vinkje **Studenten verbergen** aan om de tabel samen te vouwen tot een groepsweergave, waarbij aantallen per PACE worden opgeteld.

<!-- SCREENSHOT: screenshots/order-materials-grouped.png — Bestellingspagina in gegroepeerde weergave -->

### Handmatig een PACE toevoegen

1. Klik op **+ Bestelling toevoegen**.
2. Zoek in het zoekveld op PACE-nummer of vaknaam.
3. Klik op het gevonden PACE-boekje.
4. Selecteer de student.
5. Pas het aantal aan indien nodig.
6. Klik op **Toevoegen**.

### Bestellijst opslaan

Klik op **Bestellijst opslaan**. De bestellijst krijgt automatisch een naam op basis van datum en tijd, bijv. `Order list 2026-03-16 14:30`.

### Een opgeslagen bestellijst openen

1. Klik op **Bestellijst openen**.
2. Kies een bestellijst uit de lijst.
3. De pagina schakelt over naar de **opgeslagen-lijstmodus**.

### Opgeslagen-lijstmodus en levering verwerken

In de opgeslagen-lijstmodus zie je een extra kolom **Geleverd** met een selectievakje per rij.

1. Zet een vinkje bij elk PACE-boekje dat ontvangen is.
2. Klik op **Levering verwerken** om de geleverde items automatisch toe te voegen aan de inventaris.
3. Na het verwerken worden de vinkjes automatisch gereset (zodat dubbele verwerking onmogelijk is).

<!-- SCREENSHOT: screenshots/order-materials-saved.png — Bestellingspagina in opgeslagen-lijstmodus met leveringsvakjes -->

Klik op **← Terug naar nieuwe bestelling** om terug te gaan naar de conceptmodus.

---

## 10. Personen

Op de pagina **Personen** beheer je studenten, personeel, ouders en families.

<!-- SCREENSHOT: screenshots/students.png — Personenpagina met tabbladen -->

### Tabbladen

| Tabblad | Inhoud |
|---|---|
| Studenten | Alle ingeschreven studenten |
| Personeel | Docenten, supervisors en overig personeel |
| Ouders | Ouder-/verzorgersaccounts |
| Families | Gezinsverbanden |

### Een nieuwe student toevoegen

1. Ga naar het tabblad **Studenten**.
2. Klik op **+ Student toevoegen**.
3. Vul de verplichte velden in:
   - Achternaam, voornamen, roepnaam
   - Groep (Kleuterklas / ABCs / Juniors / Seniors)
4. Klik op **Opslaan**.

### Personeel beheren

Personeel heeft een **rang** (1 = supervisor van een groep). De supervisor met rang 1 wordt automatisch vermeld op het jaarrapport.

---

## 11. Importeren

Op de pagina **Importeren** kun je gegevens vanuit Excel-bestanden inladen.

<!-- SCREENSHOT: screenshots/import.png — Importeerpagina -->

### Wat kan worden geïmporteerd?

- Cursussen
- PACE–cursus-koppelingen
- Inventaris

### Werkwijze

1. Klik op **Bestand kiezen** en selecteer je Excel-bestand.
2. De applicatie toont een voorvertoning van de gegevens.
3. Zijn er conflicten met bestaande gegevens, dan verschijnt een dialoogvenster per conflict.
4. Kies per conflict **Overschrijven** of **Overslaan**.
5. Klik op **Importeren bevestigen**.

> Download een **sjabloonbestand** via de knop op de importpagina om het juiste format te gebruiken.

---

## 12. Exporteren

Op de pagina **Exporteren** kun je gegevens downloaden als Excel-bestand.

<!-- SCREENSHOT: screenshots/export.png — Exporteerpagina -->

### Beschikbare exports

- Studentenlijst
- Cursusoverzicht
- Inschrijvingen
- Inventaris

Klik op de gewenste exportknop om het bestand direct te downloaden.

---

## 13. Beheer

De pagina **Beheer** is alleen zichtbaar voor beheerders.

### Gebruikers uitnodigen

1. Ga naar **Beheer**.
2. Klik op **Uitnodiging aanmaken**.
3. Kies de rol: **Docent** of **Ouder**.
4. Kopieer de uitnodigingslink en stuur deze door.

De ontvanger kan via de link een account aanmaken en wordt automatisch aan de juiste rol gekoppeld.

---

## 14. Screenshots toevoegen

Screenshots ontbreken nog in dit document. Voeg ze als volgt toe:

### Stap 1 — Screenshots maken

1. Log in op de Ceder-app in je browser.
2. Navigeer naar de gewenste pagina.
3. Maak een screenshot:
   - **Mac:** `Cmd + Shift + 4` → selecteer het venster
   - **Windows:** `Win + Shift + S` → selecteer het venster
4. Sla het bestand op als `.png` in de map `docs/screenshots/`.

### Overzicht vereiste screenshots

| Bestandsnaam | Pagina | URL |
|---|---|---|
| `screenshots/login.png` | Loginpagina | `/` (uitgelogd) |
| `screenshots/navigatie.png` | Zijbalk | Willekeurig scherm |
| `screenshots/spc.png` | Student Progress Chart | `/spc` |
| `screenshots/reports.png` | Verslagen | `/reports` |
| `screenshots/materials.png` | Cursussen & PACEs | `/materials` |
| `screenshots/materials-add-paces.png` | PACE-toevoegdialoog | `/materials` → klik op een cursus |
| `screenshots/enrollments.png` | Inschrijvingen | `/enrollments` |
| `screenshots/inventory.png` | Inventaris | `/inventory` |
| `screenshots/order-materials.png` | Bestellingen (concept) | `/order-materials` |
| `screenshots/order-materials-grouped.png` | Bestellingen (gegroepeerd) | `/order-materials` + Studenten verbergen |
| `screenshots/order-materials-saved.png` | Bestellingen (opgeslagen lijst) | `/order-materials` → open een lijst |
| `screenshots/students.png` | Personen | `/students` |
| `screenshots/import.png` | Importeren | `/import` |
| `screenshots/export.png` | Exporteren | `/export` |

### Stap 2 — Screenshot invoegen in Markdown

Vervang de `<!-- SCREENSHOT: ... -->` opmerkingen door:

```markdown
![Beschrijving](screenshots/bestandsnaam.png)
```

Voorbeeld:

```markdown
![Student Progress Chart](screenshots/spc.png)
```

### Stap 3 — Exporteren naar PDF

Met [Pandoc](https://pandoc.org/) kun je dit document omzetten naar PDF:

```bash
pandoc handleiding.md -o handleiding.pdf --pdf-engine=xelatex \
  --variable mainfont="DejaVu Sans" \
  --variable geometry:margin=2.5cm
```

Of gebruik [Typora](https://typora.io/) of [Obsidian](https://obsidian.md/) voor een eenvoudige export.

---

*Handleiding Ceder · ICS De Ceder – Boskoop · Versie 1.0 · Maart 2026*
