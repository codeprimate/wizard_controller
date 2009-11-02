module Codeprimate
	VERSION = "0.1.6"
  
  module Wizard

    class Base < ApplicationController
      before_filter :restrict_access, :init_wizard_session

      ### CLASS METHODS
      class << self
        @wizard_steps = []
        @finish_path = '/'
        @wizard_default_error = 'There was a problem processing the last step.'
        attr_accessor :wizard_steps, :finish_path, :abort_path, :wizard_default_error

        # Define steps of the wizard.
        #
        # Should be an array of symbols.
        def define_steps(*args)
          self.wizard_steps = args
        end

        # Set the URL that a user is redirected to after finishing the Wizard.
        #
        # Should be a string
        def set_finish_path(p)
          self.finish_path = p
        end

        # Set the URL that a user is redirected to after aborting the Wizard.
        def set_abort_path(p)
          self.abort_path = p
        end

        # Set the flash message a user sees when a process_action method returns false
        def set_default_error(e)
          self.wizard_default_error = e
        end
      end

      ### PUBLIC ACTIONS

      # Internal.
      def index
        if finished
          handle_finished_wizard
        else
          handle_unfinished_wizard
        end
      end
      
      # Internal.
      def next_step
        if step_completed
          incr_step
        else
          flash[:error] ||= self.class.wizard_default_error
        end
        self.finish_path = params[:redirect] unless params[:redirect].blank?
        redirect_to :action => :index
      end

      # Internal.
      def previous_step
        decr_step
        redirect_to :action => :index
      end

      # Public action to reset the wizard
      def reset
        reset_wizard
        redirect_to :action => :index
      end

      # Assign finish path.
      #
      # Accepts a string.
      def finish_path=(p)
        unless p.blank?
          session[:finish_path] = p
        end
        finish_path
      end

      private

      ### PRIVATE CONTROLLER METHODS

      def handle_finished_wizard
        redirect_to finish_path
        reset_wizard
      end

      def handle_unfinished_wizard
        if request.get?
          handle_get_action
        else
          handle_post_action
        end
      end

      def handle_get_action
        execute_method
        render_step_view
      end

      def handle_post_action
        if (self.wizard_step_completion = execute_process_method)
          next_step
        else
          flash[:error] ||= self.class.wizard_default_error
          render_step_view
        end
      end

      def restrict_access
        ['index', 'next_step', 'previous_step', 'reset'].include?(params[:action])
      end

      def execute_method(m=current_wizard_step_method)
        return send(m)
      end

      def execute_process_method
        return execute_method("process_#{current_wizard_step_method}".to_sym)
      end

      def render_step_view
        render :action => current_wizard_step_method
      end

      helper_method :step_number
      def step_number
        current_wizard_step
      end

      helper_method :total_steps
      def total_steps
        self.class.wizard_steps.size
      end

      helper_method :next_step_path
      def next_step_path(options={})
        url_for(({:controller => self.controller_name, :action => :next_step}).merge(options))
      end

      helper_method :previous_step_path
      def previous_step_path
        url_for(:controller => self.controller_name, :action => :previous_step)
      end

      helper_method :step_completed
      def step_completed
        session[:wizard][self.class.to_s][:completed][current_wizard_step] == true
      end

      helper_method :wizard_path
      def wizard_path
        url_for(:controller => self.controller_name)
      end

      helper_method :reset_wizard_path
      def reset_wizard_path
        url_for(:controller => self.controller_name, :action => :reset)
      end


      helper_method :abort_wizard_path
      def abort_wizard_path
        abort_path
      end

      #### SESSION MANAGEMENT

      def current_wizard_step
        @wizard_step ||= session[:wizard][self.class.to_s][:step].to_i
      end

      def set_current_wizard_step(step)
        session[:wizard][self.class.to_s][:step] = step
        @wizard_step = step
      end

      def incr_step
        set_current_wizard_step(current_wizard_step + 1)
      end

      def decr_step
        set_current_wizard_step([1, (current_wizard_step - 1)].max)
      end

      def current_wizard_step_method
        self.class.wizard_steps[(current_wizard_step - 1)]
      end

      def finished
        self.class.wizard_steps.size < current_wizard_step
      end

      def finish_path
        # should be set to self.class.finish_path but that comes out to nil here somehow. --Dallas
        fp = session[:finish_path] ||= self.class.finish_path ||= '/'
        return fp
      end

      def abort_path=(p)
        unless p.blank?
          session[:abort_return_to] = p
        end
        abort_path
      end

      def abort_path
        session[:abort_return_to] ||= self.class.abort_path ||= '/'
      end

      def no_processing
        self.wizard_step_completion = true
      end

      def set_as_not_completed
        self.wizard_step_completion = false
      end

      def wizard_step_completion=(completed)
        session[:wizard][self.class.to_s][:completed][current_wizard_step] = completed
      end

      def reset_wizard
        session[:wizard][self.class.to_s] = nil
        init_wizard_session
      end

      def init_wizard_session
        session[:wizard] ||= {}
        session[:wizard][self.class.to_s] ||= {}
        session[:wizard][self.class.to_s][:step] ||= 1
        session[:wizard][self.class.to_s][:completed] ||= {}
        session[:finish_path] ||= self.class.finish_path
        @wizard_step = session[:wizard][self.class.to_s][:step].to_i
      end

    end
  end

end
