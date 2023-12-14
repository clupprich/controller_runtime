# frozen_string_literal: true

module ControllerRuntime
  # Keeps track of the runtime for a given config/event.
  module RuntimeRegistry
    module_function

    def runtime(name)
      ActiveSupport::IsolatedExecutionState["#{name}_runtime".to_sym] ||= 0.0
    end

    def set_runtime(name, runtime)
      ActiveSupport::IsolatedExecutionState["#{name}_runtime".to_sym] = runtime
    end

    def increment_runtime(name, runtime)
      ActiveSupport::IsolatedExecutionState["#{name}_runtime".to_sym] = self.runtime(name) + runtime
    end

    def reset(name)
      rt = runtime(name)
      set_runtime(name, 0.0)
      rt
    end
  end
end
