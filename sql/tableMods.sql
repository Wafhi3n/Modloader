.headers on
.mode csv

select m1.ModRowId,mp2.Value as Name , mp1.Value as Autor , m1.ModId ,m1.Version, sf.Path, mgi.Disabled from ModProperties mp1
JOIN
Mods m1 ON m1.ModRowId = mp1.ModRowId
JOIN 
ModProperties mp2 ON mp2.ModRowId = mp1.ModRowId
JOIN
ScannedFiles sf ON sf.ScannedFileRowId = m1.ScannedFileRowId
JOIN
ModGroupItems mgi On mgi.ModRowId = m1.ModRowId
where  mp1.Name like "Authors" and   mp1.Value not like 'LOC_MOD_AUTHORS_FIRAXIS'
And mp2.Name like 'Name';