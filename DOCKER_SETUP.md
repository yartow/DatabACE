# Ceder — Lokaal draaien met Docker

Met deze instructies draai je de volledige Ceder-applicatie lokaal op je Mac, inclusief de database met alle bestaande schooldata.

## Vereisten

- [Docker Desktop voor Mac](https://www.docker.com/products/docker-desktop/) (gratis)
- Git

## Stap 1 — Repository clonen

```bash
git clone <jouw-repo-url> ceder
cd ceder
```

## Stap 2 — Docker Desktop starten

Open Docker Desktop en wacht tot het groene lampje aangeeft dat Docker actief is.

## Stap 3 — App starten

```bash
docker compose up --build
```

De eerste keer duurt dit 2–5 minuten omdat Docker:
1. De Node.js-image downloadt
2. De PostgreSQL-image downloadt
3. De app bouwt (`npm install` + `npm run build`)
4. De database initialiseert met alle bestaande data

## Stap 4 — App openen

Ga naar **http://localhost:5000**

Je bent direct ingelogd als beheerder (Local Admin) — je hoeft niet in te loggen via Replit.

---

## Inloggen / accounts

Lokaal is de Replit-authenticatie vervangen door een automatische bypass:
- Je bent altijd ingelogd als **Local Admin** (teacher + admin)
- Het account heeft toegang tot alle functies inclusief Admin-pagina

Om een tweede gebruiker te testen (bijv. als parent), kun je de `LOCAL_DEV_USER_ID` aanpassen in `docker-compose.yml` en de stack herstarten.

---

## Data

De database bevat een export van de live schooldata:
- Alle leerlingen, cursussen, PACEs, inschrijvingen
- Inventory en bestellijsten
- Families, ouders, personeel

De data staat in `docker/init.sql` en wordt automatisch geladen bij de eerste start.

> **Let op:** Als je `docker compose down -v` gebruikt, verwijder je ook de database. Bij `docker compose down` (zonder `-v`) blijft de data bewaard.

---

## Handige commando's

| Commando | Omschrijving |
|---|---|
| `docker compose up` | App starten (op de achtergrond: voeg `-d` toe) |
| `docker compose up --build` | App opnieuw bouwen en starten |
| `docker compose down` | App stoppen (data bewaard) |
| `docker compose down -v` | App stoppen + database verwijderen |
| `docker compose logs app` | App-logs bekijken |
| `docker compose logs db` | Database-logs bekijken |
| `docker compose ps` | Status van de containers |

## Database direct benaderen

```bash
docker compose exec db psql -U ceder -d ceder
```

---

## Wijzigingen in de code

Wanneer je code aanpast, moet je de app opnieuw bouwen:

```bash
docker compose up --build
```

Voor snellere ontwikkeling kun je ook de app lokaal draaien (zonder Docker voor de app zelf, maar wel Docker voor de database):

```bash
# Alleen de database in Docker draaien
docker compose up db -d

# App lokaal starten (in een apart terminal)
DATABASE_URL=postgres://ceder:ceder_local@localhost:5432/ceder \
SESSION_SECRET=local-dev-secret \
LOCAL_DEV=true \
npm run dev
```

Ga dan naar **http://localhost:5000** — je bent direct ingelogd.

---

## Problemen oplossen

**Port 5000 al in gebruik?**
Pas in `docker-compose.yml` `"5000:5000"` aan naar bijv. `"5001:5000"` en ga naar http://localhost:5001.

**Port 5432 al in gebruik?**
Pas `"5432:5432"` aan naar `"5433:5432"` in `docker-compose.yml`.

**Database is leeg / app start niet?**
```bash
docker compose down -v
docker compose up --build
```

**App-fout bekijken?**
```bash
docker compose logs app --tail=50
```
