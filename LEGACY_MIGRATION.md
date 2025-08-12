# Legacy migration

### The problem

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

### The migration procedure

The migration from legacy is prepared as follows:

 0. (dev only) the latest legacy database is copied locally (`make force_restore`);
 1. starting from the LDAP listing, the `Work::Sciper` model is populated with
    the list of all people currently accredited at EPFL (`make scipers`).
    The records are divided in 3 categories:
    * people that are not allowed to have a personalized profile because they
      are missing the `botweb` accreditation property;
    * people that do have the right to edit their profile but never actually
      bothered to do so and hence can be considered as already migrated;
    * people with a legacy profile to be migrated _migranda profiles_;
 2. all the text entries from the various legacy models for the _migranda profiles_
    are imported into the `Work::Text` model.
