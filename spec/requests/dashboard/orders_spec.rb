require 'rails_helper'

RSpec.describe "Dashboard::Orders", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /dashboard/orders" do
    it "returns http success" do
      create_list(:order, 3, user: user)
      get dashboard_orders_path
      expect(response).to have_http_status(:success)
    end

    it "filters by status" do
      create(:order, status: "pending", user: user)
      create(:order, :approved, user: user)
      get dashboard_orders_path, params: { status: "pending" }
      expect(response.body).to include("pending")
    end
  end

  describe "GET /dashboard/orders/:id" do
    let(:order) { create(:order, user: user) }

    it "returns http success" do
      get dashboard_order_path(order)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/orders/:id/approve" do
    let(:order) { create(:order, status: "pending", user: user) }

    it "approves the order and redirects" do
      post approve_dashboard_order_path(order)
      expect(response).to redirect_to(dashboard_order_path(order))
      expect(order.reload.status).to eq("approved")
    end
  end

  describe "POST /dashboard/orders/:id/cancel" do
    let(:order) { create(:order, status: "pending", user: user) }

    it "cancels the order and redirects" do
      post cancel_dashboard_order_path(order)
      expect(response).to redirect_to(dashboard_order_path(order))
      expect(order.reload.status).to eq("cancelled")
    end
  end

  describe "POST /dashboard/orders/bulk_update" do
    let!(:orders) { create_list(:order, 2, status: "pending", user: user) }

    it "approves selected orders" do
      post bulk_update_dashboard_orders_path, params: { order_ids: orders.map(&:id), bulk_action: "approved" }
      expect(response).to redirect_to(dashboard_orders_path)
      orders.each { |o| expect(o.reload.status).to eq("approved") }
    end

    it "redirects with alert when no orders selected" do
      post bulk_update_dashboard_orders_path, params: { bulk_action: "approved" }
      expect(response).to redirect_to(dashboard_orders_path)
    end

    it "cancels selected orders" do
      post bulk_update_dashboard_orders_path, params: { order_ids: orders.map(&:id), bulk_action: "cancelled" }
      expect(response).to redirect_to(dashboard_orders_path)
      orders.each { |o| expect(o.reload.status).to eq("cancelled") }
    end

    it "redirects with alert when no orders selected" do
      post bulk_update_dashboard_orders_path, params: { bulk_action: "cancelled" }
      expect(response).to redirect_to(dashboard_orders_path)
    end

    it "redirects with alert when bulk action is invalid" do
      post bulk_update_dashboard_orders_path, params: { order_ids: orders.map(&:id), bulk_action: "shipped" }
      expect(response).to redirect_to(dashboard_orders_path)
    end
  end

  context "when not authenticated" do
    before { sign_out user }

    it "redirects to login" do
      get dashboard_orders_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
