# Legacy migration

## The problem

This application need to import the data from its legacy counterpart. This task
is not trivial due to the following facts:
 * the legacy database still include data that is no longer relevant (profiles
   of people who left EPFL);
 * the legacy database is not completely multilingual: it includes various
   models that include content in an unspecified language (_e.g._, `edu`,
   `parcours`, `publications`);
 * the character encoding of strings in the legacy database is not unique and
   not explicitly defined. Therefore, a source char encoding cannot be assumed
   and have to be _guessed_ foreach string.

## The goal
We would like to have an application where
 * crap content is minimized;
 * each future text have a defined language or, better, where each future text
   have a (possibly wrong) language defined by its owner;

## Approach
The migration from the old application is planned as follows:
 1. The migration is announced to all concerned people: those who have edited their
   profile at least once in the past.
 2. The new application is deployed with clean data (see below) and adoption
  mode enabled (`ENABLE_ADOPTION` set to true)
 3. DNS is switched so that the domain is served by the new application;
 4. Latest version of all texts is fetched and language detections pre-computed;
 5. _Adoption phase_ starts. In this phase, the new application will
    * proxy the public profile pages from the old server;
    * proxy all the webservices from the old server;
    * intercept the requests of editing the profiles. Legacy profiles are
      imported into the new app the first time the profile is edited. Therefore
      the importation process must be quick.
    * User can _preview_ their new profile and _adopt_ it as their new official
      profile. At that point the new applicatoin will start serving it instead
      of proxying the one from the lagacy application.
 6. _Steady production_: adoption mode is switched off and the new application
   will start serving only internal content. Actually, there still be some
   proxying of web services from the legacy app but only if we need more time
   to fix the internal equivalents.
 7. Yet **to be decided** what we do with _orphan_ (imported but
   not adopted) and never edited profiles. In order to satisfy the «_crap content
   is minimized_» wish, I am in favor of discard everything and start with fresh
   new profiles. To be discussed.

Texts imported from legacy need to be assigned a language automatically when
not well defined. This is a potentially heavy task and, in order to speed-up,
the profile importation, as we prefetch all the texts and detect their language
in advance. Language detection for legacy text is responsibility of
the `Work::Text` model.

For preparing the applicaiton to adoption mode, we also prefetch the sciper/name
of everybody in the `Work::Sciper` model. People are divided in 3 categories:
 * people that are not allowed to have a personalized profile because they
   are missing the `botweb` accreditation property;
 * people that do have the right to edit their profile but never actually
   bothered to do so and hence can be considered as already migrated;
 * people with a legacy profile to be migrated _migranda profiles_.
   A record for the `Adoption` model is created for each migranda profile.

### The migration procedure (technical part)

#### Development

In development mode, the migration from legacy is prepared with `make legacy`:

 0. the latest legacy database is copied locally (`make force_restore`);
 1. starting from the LDAP listing, the `Work::Sciper` model is populated with
    the list of all people currently accredited at EPFL (`make scipers`);
 2. for each migranda profile, an `Adoption` record is created and the text
    contents are loaded into `Work::Text`

#### Production

In production, we would like to save the the work done by the admin during the
testing phase which is not trivial to export. The easiest is to nuke all
the user-related data by running the `data:hiroshima_and_nagasaki` rake task.

We don't need to copy the legacy data as it will be available from the official
production database.

The following tasks need to be executed in order to get the latest work data:

```bash
	./bin/rails legacy:reload_scipers
	./bin/rails legacy:load_texts
	./bin/rails legacy:txt_lang_detect
	./bin/rails legacy:refresh_adoptions
```
