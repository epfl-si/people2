# Oasis (a.k.a. new IS-A)
## Base url and authentication
The base URLs for the service are `https://oasis-t.epfl.ch:8484/`, and `https://oasis.epfl.ch:8484/` for test and prod respectively.

Authentication is done with a Bearer token (see `bin/oasis.sh`).

## Available routes
### Courses
All the courses of a given academic year: `cours/2024-2025`. Not very interesting
for our purpose. It returns a list of record like the following:

```json
  {
    "coursCode": "CH-310",
    "coursNomFr": "Dynamics and kinetics",
    "matiereUnite": "CGC",
    "curriculumAnneeAcademique": "2025-2026",
    "curriculumNiveau": "Master",
    "curriculumSemestre": "Semestre automne"
  },
```

### Courses by teacher
Url: `enseignant-cours/2025-2026?sciper-enseignant=SCIPER` returns a list of
records like the following:

```json
{
  "enseignantSciper": "XXXXXX",
  "enseignantRole": "Enseignement",
  "coursSeanceCode": "LIP_EXERCICE",
  "coursCode": "CS-526",
  "coursNomFr": "Learning theory",
  "curriculumAnneeAcademique": "2025-2026"
}
```

### Course details
Url: `cours/fiche/resume/2024-2025/ME-343`. Returns a detailed record about the
course with give code (`ME-343` in the example).

```json
{
  "nomCoursEn": "Learning theory",
  "nomCoursFr": "Learning theory",
  "codeCours": "CS-526",
  "curriculumAnneeAcademique": "2025-2026",
  "langueEnseignement": "AN",
  "contenuResumeEn": "Machine learning and data analysis are becoming increasingly central in many sciences and applications. This course concentrates on the theoretical underpinnings of machine learning.",
  "contenuResumeFr": "L'analyse des données et l'apprentiassage automatique (ou machine)  jouent un role central dans plusieurs disciplines scientifiques et applications. Ce cours se concentre sur les sous-jacents théoriques de l'apprentissage automatique."
}
```

`langueEnseignement` can be `AN`, or `FR`...

### Currently enrolled PhD students
Url: `/etudiants/phd`. This returns the list of ALL currently enrolled doctoral
students with records of the following form:

```json
{
  "titreDiplome": "Docteur ès Sciences",
  "sciper": "XXXXXX",
  "programmeDoctoral": "Science et génie des matériaux (edoc)",
  "section": "Science et génie des matériaux",
  "cursus": "EDMX",
  "numeroThese": "11675",
  "titreThese": "First-principles simulations of plasma-facing materials: identification of the best candidates and their interaction with the plasma under divertor conditions",
  "directeurThese": "YYYYYY",
  "codirecteurThese": "ZZZZZZ"
}
```
We can use this to get the list of "Current PhD students for a given professor" but
it is not possible to pass the `directeurThese` as filter param. Therefore we
will have to prefetch and store on a local table possibly including the name of
the student which is not present in the record.

### Currently enrolled bachelor/master students
Similarly, it is possible to get the list of currently enrolled master
students with `/etudiants/master/2023-2024` and bachelor student per
academic semester with `/etudiants/bachelor/2023-2024?semestre-academique=BA3`

### Alumni
The list of former PhD students can be obtained by graduation year as follows:
`/alumni/doctors/2023`. This returns records of the following form:

```json
{
  "titreDiplome": "Docteur ès Sciences",
  "sciper": "XXXXXX",
  "dateRemiseDiplome": "09.06.2023",
  "dateExmatriculation": "10.06.2023",
  "programmeDoctoral": "Chimie et génie chimique (edoc)",
  "section": "Chimie et génie chimique",
  "cursus": "EDCH",
  "numeroThese": "10235",
  "titreThese": "Towards Uncovering the Mechanisms of Electrophile Sensing and Signaling",
  "directeurThese": "XXXXXX",
  "codirecteurThese": null
}
```

Again we will have to prefetch the list to have a quick the relation with professors.

### Alumni (bachelor & master)
Similarly, on can obtain the list of master AND bachelor graduates with `alumni/bama/2023`

```json
{
  "niveau":"Master",
  "dateSession":"03.2020",
  "sciper":"XXXXXX",
  "section":"Informatique",
  "orientation":"Master IN",
  "cursus":"IN - Master 2017",
  "cursusUniteAcademique":"Science et ingénierie computationnelles"
},
{
  "niveau":"Bachelor",
  "dateSession":"07.2018",
  "sciper":"XXXXXX",
  "section":"Informatique",
  "orientation":"Bachelor",
  "cursus":"IN - Bachelor 2014",
  "cursusUniteAcademique":"Physique"
}
```

### Student Awards
There is an endpoints for all awards givent to students: `alumni/prizes`

```json
{
  "prix": "Prix SIA Vaud (meilleure moyenne atelier)",
  "sciper": "296024",
  "nom": "Gregoire",
  "prenom": "Pénélope",
  "annee": "2022",
  "niveau": "Bachelor",
  "section": "Architecture"
}
```
