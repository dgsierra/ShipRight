# frozen_string_literal: true
# Seeds are idempotent – safe to run multiple times.

puts "Seeding staff users..."

admin = User.find_or_create_by!(email: "admin@shipright.io") do |u|
  u.name     = "Admin User"
  u.password = "password123"
  u.staff    = true
end

ops = User.find_or_create_by!(email: "ops@shipright.io") do |u|
  u.name     = "Ops User"
  u.password = "password123"
  u.staff    = true
end

puts "  Created: #{admin.email}, #{ops.email}"

puts "Seeding products..."

products = [
  { name: "Laptop Stand",        sku: "LPTS-001", unit_price_cents: 4999,  description: "Aluminum adjustable laptop stand" },
  { name: "USB-C Hub",           sku: "USBC-002", unit_price_cents: 3999,  description: "7-in-1 USB-C hub" },
  { name: "Mechanical Keyboard", sku: "MKEY-003", unit_price_cents: 12999, description: "TKL mechanical keyboard, brown switches" },
  { name: "Wireless Mouse",      sku: "WMSE-004", unit_price_cents: 4499,  description: "Ergonomic wireless mouse" },
  { name: "Monitor Arm",         sku: "MARM-005", unit_price_cents: 8999,  description: "Single monitor arm, gas spring" },
  { name: "Webcam 1080p",        sku: "WCAM-006", unit_price_cents: 6999,  description: "Full HD webcam with autofocus" },
  { name: "Desk Mat",            sku: "DMAT-007", unit_price_cents: 2499,  description: "Extra large desk pad, black" },
  { name: "Cable Management Kit", sku: "CBMG-008", unit_price_cents: 1499, description: "Velcro cable ties and clips" }
].map do |attrs|
  Product.find_or_create_by!(sku: attrs[:sku]) do |p|
    p.name              = attrs[:name]
    p.description       = attrs[:description]
    p.unit_price_cents  = attrs[:unit_price_cents]
    p.active            = true
  end
end

puts "  Created #{products.length} products"

puts "Seeding orders..."

customers = [
  { name: "Alice Johnson",  email: "alice@example.com" },
  { name: "Bob Martinez",   email: "bob@example.com" },
  { name: "Carol Williams", email: "carol@example.com" },
  { name: "David Chen",     email: "david@example.com" },
  { name: "Eva Rodriguez",  email: "eva@example.com" }
]

statuses = %w[pending pending approved approved shipped shipped delivered cancelled]

created_orders = 0

15.times do |i|
  customer = customers[i % customers.length]
  status   = statuses[i % statuses.length]
  staff    = i.even? ? admin : ops

  reference = "SR-SEED#{(i + 1).to_s.rjust(3, '0')}"
  next if Order.exists?(reference: reference)

  selected_products = products.sample(rand(1..3))

  total_cents = selected_products.sum { |p| p.unit_price_cents * rand(1..3) }

  order = Order.create!(
    reference:      reference,
    status:         status,
    customer_name:  customer[:name],
    customer_email: customer[:email],
    total_cents:    total_cents,
    user:           staff,
    notes:          i.odd? ? "Priority delivery requested" : nil,
    tracking_number: %w[shipped delivered].include?(status) ? "TRK#{SecureRandom.alphanumeric(10).upcase}" : nil,
    carrier:        %w[shipped delivered].include?(status) ? "FakeCarrier" : nil
  )

  selected_products.each_with_index do |product, idx|
    qty = rand(1..3)
    order.line_items.create!(
      product:         product,
      quantity:        qty,
      unit_price_cents: product.unit_price_cents
    )
  end

  # Add audit entries for status transitions
  if status != "pending"
    AuditEntry.log(
      auditable: order,
      event: "status_changed",
      user: staff,
      changes: { status: ["pending", status] }
    )
  end

  created_orders += 1
end

puts "  Created #{created_orders} orders"
puts "\nSeed complete!"
puts "\nLogin credentials:"
puts "  admin@shipright.io / password123"
puts "  ops@shipright.io   / password123"
