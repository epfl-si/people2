# Multilanguage support

## Current implementation status
Current version only support two languages: french and english. We start by doing the same with the idea of adding more languages in the future. The problem is how to make the UI usable.

For two languages we decided to have each field repeated (e.g. instead of `title`, we have `title_en`, and `title_fr`) and statically visible in editing forms. Forms grow fat but the user gets immediate feedback about missing translations. This approach could be extended to 3, possibly 4 languages but for sure not more than 4. 

I have tried to put most of the language-related functions in the `Translatable` concern.

In case we will have to rething the UI. An option would be to leverage JS and create fields with name that changes depending on the language selected from a dropdown menu. While making the forms possibly lighter, it would rely on the user chosing the correct language which is not ideal.

In the legacy version, the user can force his profile to be displayed only in a given language even when a translation exists in the language of the reader. PO asked for this feature to be kept. 

Here is how the content translation is chosen (in index/show views):

```mermaid
flowchart TD
    A{"A. Profile have forced locale?"}
    B{"B. Profile have default locale?"}
    G{"G. Item have content in primary_locale ?"}
    H{"H. Item have content in fallback_locale ?"}

    C("C. Set both primary_locale AND fallback locale to profile's forced locale")
    D("D. Set primary_locale to browser locale")
    E("E. Set fallback_locale to profile's default locale")
    F("F. Set fallback_locale to global default locale")
    X("X. Content in primary_locale")
    Y("Y. Content in fallback_locale")
    Z("Z. No Content")

    A -->|yes| C --> G
    A -->|no| D 

    D --> B

    B -->|yes| E --> G
    B -->|no| F --> G

    G --> |yes| X
    G --> |no| H
    H --> |yes| Y 
    H --> |no| Z
```
