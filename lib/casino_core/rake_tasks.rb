module CASinoCore
  class RakeTasks
    class << self
      def load_tasks
        %w(
          database
          cleanup
        ).each do |task|
          load "casino_core/tasks/#{task}.rake"
        end
      end
    end
  end
end
