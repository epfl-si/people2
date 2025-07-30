## Translations
The translation files are grouped in various folders:
  - `attributes`
  - `errors`
  - `flash`
  - `help`
  - `placeholders`
  - `views`
  - `visibility`
The main folder contains all mostly generic and general-purpose translations. It should contain also the keys that are in the `visibility` folder but they have been separated as it was quite large.

The _logic_ for where to place a translation is as follows:

### attributes
In the `attributes` group contains translations that are mostly used by helpers
and contains two branches:
 1. the [standard](https://guides.rubyonrails.org/i18n.html#translations-for-active-record-models)
    `activerecord.attributs` that are used for form labels and are used by the
    `Model.model_name.human` and `Model.human_attribute_name(attribute)` so that
    it works for standard error messages too.
    ```
    activerecord:
      attributes:
        MODEL_NAME:
          ATTRIBUTE_NAME:
    ```
 2. the more specific labels for forms where a long description is needed:
  ```
    attr_labels:
      MODEL_NAME:
        ATTRIBUTE_NAME:
  ```

### errors
Contain the [standard](https://guides.rubyonrails.org/i18n.html#error-message-scopes)
ruby hierarchy for error messages.

### flash
Flash messages set by controllers

### placeholders
As the name indicates, contains all the placeholders in the standard rails
hierarchy `helpers.placeholder.MODEL_NAME.ATTRIBUTE_NAME`. Since we provide
translated attributes the files are essentially identical.

### views
Contains translations that are meant to be used with
["lazy" lookup](https://guides.rubyonrails.org/i18n.html#lazy-lookup).
Therefore they need to respect the exact path hierarcy of the view files and the translation are usually called with max one or two keys relative to the containing file path.
