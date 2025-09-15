# frozen_string_literal: true

# Make it so the SQL debug stream mentions the target database name

module SqlLogWithDbName
  def sql(event)
    db_name = ActiveRecord::Base.connection_db_config.database
    event.payload[:sql] = "[#{db_name}] #{event.payload[:sql]}"
    super
  end
end

ActiveRecord::LogSubscriber.prepend(SqlLogWithDbName)
