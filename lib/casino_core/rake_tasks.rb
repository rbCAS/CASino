module CASinoCore
  class RakeTasks
    class << self
      def load_tasks
        %w(
          datebase
        ).each do |task|
          load "casino_core/tasks/#{task}.rake"
        end
      end
    end
  end
end
