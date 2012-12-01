module CASinoCore
  class RakeTasks
    class << self
      def load_tasks
        %w(
          database
        ).each do |task|
          load "casino_core/tasks/#{task}.rake"
        end
      end
    end
  end
end
