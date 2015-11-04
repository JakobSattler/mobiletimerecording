namespace :zz5 do
	namespace :db do
		task :seed => :environment do
			file=File.join(Rails.root, 'plugins','redmine_zz5','db', 'seeds.rb')
			puts "Loading default data for ZZ5 plugin from file " + file
			load(file) if File.exist?(file)
			puts "Loading finished"
		end
	end
end

