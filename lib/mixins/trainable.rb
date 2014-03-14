class Dicot
  module Trainable
    def training_queue
      @training_queue ||= []
    end

    def feedback_queue
      @feedback_queue ||= []
    end

    def feedback_queue=(queue)
      @feedback_queue = queue
    end

    def add_training_seq(data)
      training_queue << data
    end
  end
end
