class AddUtf8EncodingToCslColumn < ActiveRecord::Migration
  UTF8_MEDIUMTEXT_PAIRS = [
    'alerts' , 'message'
  ]

  def self.up
    execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8mb4;"

    ActiveRecord::Base.connection.tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET = utf8mb4;"
    end

    UTF8_MEDIUMTEXT_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` MEDIUMTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    end
  end

  def self.down
    execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8;"

    ActiveRecord::Base.connection.tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET = utf8;"
    end

    UTF8_MEDIUMTEXT_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` MEDIUMTEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci;;"
    end
  end
end
