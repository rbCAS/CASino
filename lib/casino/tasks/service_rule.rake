require 'terminal-table'

namespace :casino do
  namespace :service_rule do

    desc 'Add a service rule (prefix the url parameter with "regex:" to add a regular expression)'
    task :add, [:name, :url] => :environment do |task, args|
      include CASino::ServiceTicketProcessor
      service_rule = CASino::ServiceRule.new name: args[:name]
      match = /^regex:(.*)/.match(args[:url])
      if match.nil?
        service_rule.url = clean_service_url(args[:url])
      else
        service_rule.url = match[1]
        service_rule.regex = true
      end
      if !service_rule.save
        fail service_rule.errors.full_messages.join("\n")
      elsif service_rule.regex && service_rule.url[0] != '^'
        puts 'Warning: Potentially unsafe regex! Use ^ to match the beginning of the URL. Example: ^https://'
      end
    end

    desc 'Remove a servcice rule.'
    task :delete, [:id] => :environment do |task, args|
      CASino::ServiceRule.find(args[:id]).delete
      puts "Successfully deleted service rule ##{args[:id]}."
    end

    desc 'Delete all servcice rules.'
    task :flush => :environment do |task, args|
      CASino::ServiceRule.delete_all
      puts 'Successfully deleted all service rules.'
    end

    desc 'List all service rules.'
    task list: :environment do
      table = Terminal::Table.new :headings => ['Enabled', 'ID', 'Name', 'URL'] do |t|
        CASino::ServiceRule.all.each do |service_rule|
          url = service_rule.url
          if service_rule.regex?
            url += " (Regex)"
          end
          t.add_row [service_rule.enabled, service_rule.id, service_rule.name, url]
        end
      end
      puts table
    end
  end
end
