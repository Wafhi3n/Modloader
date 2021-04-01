# UpdateGitModCiv

C'est quoi ?
---------------	
Ce script installe les mods BBG/BBS/MPH/BSM dans vos Documents au lieu du steam workshop, vous pouvez donc les unsubs.
Conserver ce script quelque part et lancer le, il va télécharger les mods dans \Documents\My Games\Sid Meier's Civilization VI\Mods.
Comme les scripts Powershell ne peuvent pas être exécuté par clic, il va créer son raccourci sur votre Bureau pour pouvoir le faire.
A chaque lancement il compare le tag actuel avec celui du depot du mod et le met à jour si necessaire

N'oublier pas de débloquer le script après l'avoir lu, car sinon il sera bloqué au lancement!


Pour l'ajouter sur Steam : 
---------------
- Ajouter un raccourci non-steam
- Parcourir: powershell.exe ( moi il est dans    C:\Windows\System32\WindowsPowerShell\v1.0 )
- Ensuite vous allez dans ses proprietés, puis mettez dans les options de lancement :  
    `-ExecutionPolicy Bypass -File [[CHEMIN VERS LE SCRIPT]]`
  


