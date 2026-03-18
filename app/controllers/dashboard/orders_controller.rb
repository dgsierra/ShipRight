module Dashboard
  class OrdersController < ApplicationController
    before_action :require_staff!
    before_action :set_order, only: %i[show approve ship deliver cancel]

    include Pagy::Backend

    def index
      scope = Order.includes(:user, :line_items).recent
      scope = scope.by_status(params[:status]) if params[:status].present?
      scope = scope.where("customer_name ILIKE :q OR reference ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

      @pagy, @orders = pagy(scope, limit: 25)
      @status_counts = Order.group(:status).count
    end

    def show
      @audit_entries = @order.audit_entries.recent.includes(:user)
      @tracking_events = @order.tracking_events.recent
    end

    def approve
      transition_order("approved")
    end

    def ship
      @order.update(tracking_number: params[:tracking_number], carrier: params[:carrier]) if params[:tracking_number].present?
      transition_order("shipped")
    end

    def deliver
      transition_order("delivered")
    end

    def cancel
      transition_order("cancelled")
    end

    def bulk_update
      status = params[:bulk_action].to_s

      unless %w[approved cancelled].include?(status)
        redirect_to dashboard_orders_path, alert: "Invalid bulk action."
        return
      end

      bulk_transition(status)
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def transition_order(new_status)
      result = Orders::StatusTransitionService.new(@order, new_status, user: current_user).call

      if result.success?
        TrackingSyncJob.perform_later(@order.id) if new_status == "shipped"
        redirect_to dashboard_order_path(@order), notice: "Order #{new_status}."
      else
        redirect_to dashboard_order_path(@order), alert: result.error
      end
    end

    def bulk_transition(new_status)
      order_ids = params[:order_ids]&.map(&:to_i) || []

      if order_ids.empty?
        redirect_to dashboard_orders_path, alert: "No orders selected."
        return
      end

      result = Orders::BulkStatusTransitionService.new(order_ids, new_status, user: current_user).call

      msg = "#{result.processed_count} order(s) #{new_status}."
      msg += " #{result.failed_ids.length} could not be #{new_status}." if result.failed_ids.any?

      redirect_to dashboard_orders_path, notice: msg
    end
  end
end
