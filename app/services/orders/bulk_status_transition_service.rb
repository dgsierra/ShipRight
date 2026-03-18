# frozen_string_literal: true

module Orders
  class BulkStatusTransitionService
    Result = Struct.new(:processed_count, :failed_ids, keyword_init: true)

    def initialize(order_ids, new_status, user: nil)
      @order_ids = Array(order_ids)
      @new_status = new_status.to_s
      @user = user
    end

    def call
      processed_count = 0
      failed_ids = []

      Order.where(id: @order_ids).find_each do |order|
        result = StatusTransitionService.new(order, @new_status, user: @user).call

        if result.success?
          processed_count += 1
        else
          failed_ids << order.id
        end
      end

      Result.new(processed_count: processed_count, failed_ids: failed_ids)
    end
  end
end
