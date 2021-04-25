# Projektplan

## 1. Projektbeskrivning (Beskriv vad sidan ska kunna göra).
På sidan ska man kunna registrera sig som en användare och kunna logga in. Sidan ska vara säker med en krypterad lösenord som gör det svårare för hackare att få tag på ett konto. När man har loggat in, om man har skrivit fel inloggning eller fel password_confirm, ska sidan ge ett felmeddelande som är sparad via session så att man sparar utrymme. När man är inloggad ska man kunna göra specifikt två funktioner. Antingen sparar man recept som redan är i databasen till sin receptlista. Eller så kan man skapa recept och publicera det till sidan. Receptet sparas på databasen och kommer vara ute för alla att se på hemsidan. 

Avancerade funktioner som jag har i huvudet som jag inte vet är möjligt eller inte är att man ska kunna uppdatera och radera sina recept. Recepten kommer då också försvinna från den publika databasen. Men, man ska inte kunna radera eller uppdatera recept som man inte har skapat (alltså som har blivit skapade av andra användare). 
## 2. Vyer (visa bildskisser på dina sidor).
Kolla img

## 3. Databas med ER-diagram (Bild på ER-diagram).
Kolla img
## 4. Arkitektur (Beskriv filer och mappar - vad gör/innehåller de?).
Denna hemsidan har 11 slimfiler. 7 av dem är i recipes mappen, vilket är mappen som är primärt om recepten. Detta gör det enklare för mig att veta vilka slimfiler som handlar om recepter och vilka andra slimfiler handlar om det generella. edit.slim är en vy som visar en formulär där man kan skriva in inputs för att uppdatera sitt recept. När man trycker "uppdatera recept" knappen förs man vidare till en 
'/update' route som ändrar på databasen och styr om användaren tillbaks till receptsidan. På index.slim visas det alla bokmarkerade recept som man har bokmarkerat, alla skapade recept som man har skapat som användare och även alternativ för att uppdatera sina recept och kolla på alla andra publika recept. Det är alltså huvudsidan när man är inloggad. new.slim är en vy med en formulär där man kan skriva in inputs som senare skapar ett recept åt användaren. När man trycker på "Skapa ett recept" skickas formulären till en annan route där sidan skapar en ny rad i databasen för att lägga till användarens nya recept.
public_show_categories.slim är också en vy som visar all recept som tillhör en specific kategori. Detta gör det enklare för användaren att hitta ett recept som de söker efter med hjälp av kategorisystemet som är implementerad i denna hemsidan. show_edit.slim är en sida som visar alla användarens skapade recept, men ger även två alternativ på varje recept: att radera eller uppdatera receptet. Om man trycker på "uppdatera" knappen skickas man vidare till en annan vy, nämligen edit.slim. Public_show är en slim vy som visar all recept som finns i databasen, men den visar även alla kategorier som finns i databasen. Om man trycker på en kategori skickas man vidare till public_show_categories.slim där man kan se all recept som tillhör den kategorin. show.slim är också en vy som visar alla små detaljer om själva receptet. Vyn visar vem som skapade receptet, vilka kategorier den tillhör, titeln på receptet och instruktioner på hur man ska tillaga maträtten.

error.slim är också en vy som endast visar ett felmeddelande. Felmeddelandet kan variera beroende på vad för sträng session[:em] har sparat. Layout.slim är endast en vy som finns på alla andra vyer. Där är en css länkad och en navbar är även kodad så att det finns på alla delsidor. login.slim är en vy med en formulär som skickas vidare för att kunna logga in. Register.slim är också en vy med en formulär som skickas in för att kunna registreras som en ny användare. 

app.rb är hjärtat av det hela. Där kodas alla routes så att allt ska fungera som det ska både back-end och front-end. I model mappen finns det en model.rb fil. Där är alla viktiga funktioner kodade som senare används i app.rb med hjälp av require_relative.

I publicmappen finns det endast en css fil. Den är väldigt enkelt skriven, då utseendet på hemsidan inte är fokuset på denna kursen. 

I img mappen finns alla skisser som skissades så att man kunde få en bättre bild på hemsidan. Dessutom är ER-diagrammet där som visar relationerna mellan alla tabeller i databasen. 

doc mappen är en dokumenteringssida som berättar om allt specifikt om koden. Vilka params varje funktion använder sig av, osv. 


