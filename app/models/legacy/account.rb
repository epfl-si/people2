class Legacy::Account < Legacy::BaseDinfo
  self.table_name = 'accounts'
  self.primary_key = 'sciper'

  # We need a single column from another table. Don't want to add a model just for that
  default_scope do
    select("accounts.sciper as sciper, user, uid, gid, home, shell, numsap")
      .distinct
      .joins("left join Personnel on accounts.sciper = Personnel.sciper")
  end

  def sap_id
    numsap
  end
end
