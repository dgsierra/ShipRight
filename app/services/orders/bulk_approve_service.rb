# frozen_string_literal: true

module Orders
  class BulkApproveService
    def initialize(order_ids, user: nil)
      @order_ids = Array(order_ids)
      @user = user
    end

    def call
      result = BulkStatusTransitionService.new(@order_ids, "approved", user: @user).call
      Result.new(approved_count: result.processed_count, failed_ids: result.failed_ids)
    end

    Result = Struct.new(:approved_count, :failed_ids, keyword_init: true)
  end
end
