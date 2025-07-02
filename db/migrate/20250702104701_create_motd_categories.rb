# frozen_string_literal: true

class CreateMotdCategories < ActiveRecord::Migration[8.0]
  CATS = YAML.load <<-MOTDCATS
    -
      property: motd_category
      label: generic
      name_en: Generic message
      name_fr: Message generique
      name_it: Messaggio generico
      name_de: Allgemeine Nachricht
    -
      property: motd_category
      label: maintenance
      name_en: Maintenance annonce
      name_fr: Annonce de maintenance
      name_it: Avviso di manutenzione
      name_de: Ankündigung von Wartungsarbeiten
    -
      property: motd_category
      label: update
      name_en: New Version
      name_fr: Nouvelle versione
      name_it: Nuova versione
      name_de: Neue Version
    -
      property: motd_category
      label: health
      name_en: Health issues
      name_fr: Degradation
      name_it: Degradazione
      name_de: Degradierung
  MOTDCATS

  def up
    SelectableProperty.create(CATS)
  end

  def down
    labels = CATS.map { |c| c['label'] }
    SelectableProperty.where(property: 'motd_category', label: labels).destroy_all
  end
end
