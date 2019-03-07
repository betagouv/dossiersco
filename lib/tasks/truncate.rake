namespace :db do
  desc "Vide toutes les tables (sauf meta data et schema de activerecord)"
  task :vide => :environment do
    conn = ActiveRecord::Base.connection
    tables = conn.execute("select tablename from pg_tables where schemaname = 'public' ;").map { |r| r["tablename"] }
    tables.delete("schema_migrations")
    tables.delete("ar_internal_metadata")
    tables.each { |t| puts "table : #{t}"; conn.execute("TRUNCATE #{t} CASCADE;") }
  end
end

