# frozen_string_literal: true

module Orders
  class StatusTransitionService
    Result = Struct.new(:success?, :order, :error, keyword_init: true)

    def initialize(order, new_status, user: nil)
      @order = order
      @new_status = new_status.to_s
      @user = user
    end

    def call
      unless Order::STATUSES.include?(@new_status)
        return failure("'#{@new_status}' is not a valid order status.")
      end

      unless @order.can_transition_to?(@new_status)
        return failure(
          "Cannot transition order from '#{@order.status}' to '#{@new_status}'."
        )
      end

      previous_status = @order.status

      ActiveRecord::Base.transaction do
        @order.update!(status: @new_status)

        AuditEntry.log(
          auditable: @order,
          event: "status_changed",
          user: @user,
          changes: { status: [ previous_status, @new_status ] }
        )
      end

      Result.new(success?: true, order: @order, error: nil)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end

    private

    def failure(message)
      Result.new(success?: false, order: @order, error: message)
    end
  end
end
