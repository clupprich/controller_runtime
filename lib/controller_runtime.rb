# frozen_string_literal: true

require_relative "controller_runtime/version"
require_relative "controller_runtime/runtime_registry"

module ControllerRuntime
  def self.register(name, event:, label: name.to_s.titelize)
    runtime_class = make_controller_runtime(name, label)

    ActiveSupport.on_load(:action_controller) do
      include runtime_class
    end

    ActiveSupport::Notifications.monotonic_subscribe(event) do |_name, start, finish, _id, _payload|
      ControllerRuntime::RuntimeRegistry.increment_runtime(name, (finish - start) * 1_000.0)
    end
  end

  def self.make_controller_runtime(name, label)
    runtime_attr = "#{name.to_s.underscore}_runtime".to_sym
    runtime_attr_setter = "#{name.to_s.underscore}_runtime=".to_sym

    Module.new do
      extend ActiveSupport::Concern

      const_set(:ClassMethods, Module.new do
        define_method :log_process_action do |payload|
          messages = super(payload)
          runtime = payload["#{name}_runtime".to_sym]
          messages << ("#{label}: %.1fms" % runtime.to_f) if runtime
          messages
        end
      end)

      define_method :initialize do |*args|
        super(*args)
        send(runtime_attr_setter, nil)
      end

      private

      attr_internal runtime_attr

      define_method :process_action do |action, *args|
        RuntimeRegistry.reset(name)
        super(action, *args)
      end

      define_method :cleanup_view_runtime do |&block|
        runtime_before_render = RuntimeRegistry.reset(name)
        send(runtime_attr_setter, (send(runtime_attr) || 0.0) + runtime_before_render)
        runtime = super(&block)
        runtime_after_render = RuntimeRegistry.reset(name)
        send(runtime_attr_setter, send(runtime_attr) + runtime_after_render)
        runtime - runtime_after_render
      end

      define_method :append_info_to_payload do |payload|
        super(payload)

        payload["#{name}_runtime".to_sym] = (send(runtime_attr) || 0.0) + RuntimeRegistry.reset(name)
      end
    end
  end
end
