# Modloader

Prérequis
---------------
- Autoriser les scripts si nécessaire :
    - lancer une console powershell en admin
    - exécuter `set-executionpolicy remotesigned`

C'est quoi ?
---------------
Ce script installe les mods BBG/BBS/MPH/BSM dans vos Documents au lieu du steam workshop, vous pouvez donc les unsubs.
Conserver ce script quelque part et lancer le, il va télécharger les mods dans \Documents\My Games\Sid Meier's Civilization VI\Mods.
Comme les scripts Powershell ne peuvent pas être exécuté par clic, il va créer son raccourci sur votre Bureau pour pouvoir le faire.
À chaque lancement, il compare le tag actuel avec celui du dépôt du mod et le met à jour si nécessaire.

N'oubliez pas de débloquer le script après l'avoir lu, car sinon il sera bloqué au lancement !


Crée le raccourci 
-----------------

C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "[.....Lien vers le fichier ps1....]"

Pour l'ajouter sur Steam :
---------------
- Ajouter un raccourci non-steam
- Parcourir : chercher le raccourci sur le bureau.


