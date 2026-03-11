# frozen_string_literal: true

module Orders
  class BulkApproveService
    Result = Struct.new(:approved_count, :failed_ids, keyword_init: true)

    def initialize(order_ids, user: nil)
      @order_ids = Array(order_ids)
      @user = user
    end

    def call
      approved_count = 0
      failed_ids = []

      Order.where(id: @order_ids).find_each do |order|
        result = StatusTransitionService.new(order, "approved", user: @user).call
        if result.success?
          approved_count += 1
        else
          failed_ids << order.id
        end
      end

      Result.new(approved_count: approved_count, failed_ids: failed_ids)
    end
  end
end
