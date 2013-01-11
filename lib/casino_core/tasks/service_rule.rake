require 'terminal-table'
require 'casino_core/model'
require 'casino_core/helper/service_tickets'

namespace :casino_core do
  namespace :service_rule do
    include CASinoCore::Helper::ServiceTickets

    desc 'Add a service rule (prefix the url parameter with "regex:" to add a regular expression)'
    task :add, [:name, :url] => 'casino_core:db:configure_connection' do |task, args|
      match = /^regex:(.*)/.match(args[:url])
      if match.nil?
        url = clean_service_url(args[:url])
        regex = false
      else
        url = match[1]
        regex = true
      end
      CASinoCore::Model::ServiceRule.create! name: args[:name], url: url, regex: regex
    end

    desc 'Remove a servcice rule.'
    task :delete, [:id] => 'casino_core:db:configure_connection' do |task, args|
      CASinoCore::Model::ServiceRule.find(args[:id]).destroy
    end

    desc 'Delete all servcice rules.'
    task :flush => 'casino_core:db:configure_connection' do |task, args|
      CASinoCore::Model::ServiceRule.delete_all
    end

    desc 'List all service rules.'
    task list: 'casino_core:db:configure_connection' do
      table = Terminal::Table.new :headings => ['ID', 'Name', 'URL'] do |t|
        CASinoCore::Model::ServiceRule.all.each do |service_rule|
          url = service_rule.url
          if service_rule.regex?
            url += " (Regex)"
          end
          t.add_row [service_rule.id, service_rule.name, url]
        end
      end
      puts table
    end
  end
end
