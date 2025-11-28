# frozen_string_literal: true

class AarUpdateJob < ApplicationJob
  queue_as :default

  # TODO: the update does not work because it does not take into account
  #   accreds that are deleted and re-created. For the moment I keep the
  #   useless code but I don't think it's worth digging this any further
  #   because copy from scratch is very fast (~4s).
  def perform(refresh: true)
    if refresh
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE accreds_aar")
      copy_accreds
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE awards_aar")
      copy_awards
    else
      if Aar::Accred.count.zero?
        copy_accreds
      else
        update_accreds
      end
      if Aar::Award.count.zero?
        copy_awards
      else
        update_awards
      end
    end
    nil
  end

  # rubocop:disable Rails/SkipsModelValidations
  def copy_accreds(scope = Accred)
    recs = scope.in_batches(of: 500).pluck(:id, :sciper, :unit_id, :visibility, :position).map do |v|
      {
        accred_id: v[0],
        sciper: v[1],
        unit: v[2],
        accred_show: (v[3].zero? ? 1 : 0),
        ordre: v[4]
      }
    end
    Aar::Accred.insert_all(recs)
  end

  def copy_awards(scope = Award)
    recs = scope.in_batches(of: 200).includes(:profile).map do |a|
      {
        award_id: a.id,
        ordre: a.position,
        sciper: a.sciper,
        title: a.t_title('en'),
        grantedby: a.issuer,
        year: a.year,
        category: a.t_category('en'),
        origin: a.t_origin("en"),
        url: a.url
      }
    end
    Aar::Award.insert_all(recs)
  end
  # rubocop:enable Rails/SkipsModelValidations

  # this will update only the changes appened after the last update in AAR::Accred
  def update_accreds
    last_update = Aar::Accred.order(:updated_at).pluck(:updated_at).last
    copy_accreds(Accred.where('created_at > ?', last_update))
    # TODO: we should first extract all the ids and then make a single request to the DB
    recs = Accred.where('created_at <= ? and updated_at > ?', last_update, last_update).map do |a|
      Aar::Accred.for_accred(a)
    end
    Aar::Accred.transaction do
      recs.each(&:save)
    end
  end

  def update_awards
    last_update = Aar::Award.order(:updated_at).pluck(:updated_at).last
    copy_awards(Award.where('created_at > ?', last_update))
    # TODO: we should first extract all the ids and then make a single request to the DB
    recs = Award.where('created_at <= ? and updated_at > ?', last_update, last_update).map do |a|
      Aar::Award.for_award(a)
    end
    Aar::Award.transaction do
      recs.each(&:save)
    end
  end
end
