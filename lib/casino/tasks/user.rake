require 'terminal-table'

namespace :casino do
  namespace :user do
    desc 'Search users by name.'
    task :search, [:query] => :environment do |task, args|
      users = CASino::User.where('username LIKE ?', "%#{args[:query]}%")
      if users.any?
        headers = ['User ID', 'Username', 'Authenticator', 'Two-factor authentication enabled?']
        table = Terminal::Table.new :headings => headers do |t|
          users.each do |user|
            two_factor_enabled = user.active_two_factor_authenticator ? 'yes' : 'no'
            t.add_row [user.id, user.username, user.authenticator, two_factor_enabled]
          end
        end
        puts table
      else
        puts "No users found matching your query \"#{args[:query]}\"."
      end
    end

    desc 'Deactivate two-factor authentication for a user.'
    task :deactivate_two_factor_authentication, [:user_id] => :environment do |task, args|
      if CASino::User.find(args[:user_id]).active_two_factor_authenticator
        CASino::User.find(args[:user_id]).active_two_factor_authenticator.destroy
        puts "Successfully deactivated two-factor authentication for user ##{args[:user_id]}."
      else
        puts "No two-factor authenticator found for user ##{args[:user_id]}."
      end
    end
  end
end
