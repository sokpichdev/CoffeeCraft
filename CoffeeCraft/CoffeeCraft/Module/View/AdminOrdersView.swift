struct AdminOrdersView: View {
    @StateObject var vm = AdminOrdersViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.orders) { order in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Order: \(order.id?.prefix(6) ?? "")")
                                .font(.headline)
                            Spacer()
                            Text(order.status.capitalized)
                                .foregroundColor(color(for: order.status))
                                .fontWeight(.semibold)
                        }

                        ForEach(order.items) { item in
                            HStack {
                                Text("\(item.name) \(item.size ?? "")")
                                Spacer()
                                Text("$\(item.price, specifier: "%.2f")")
                            }
                            .font(.subheadline)
                        }

                        Text("Total: $\(order.totalPrice, specifier: "%.2f")")
                            .fontWeight(.semibold)

                        HStack {
                            Button("Start") {
                                vm.updateOrderStatus(order: order, status: "inProgress")
                            }
                            .disabled(order.status != "pending")

                            Button("Ready") {
                                vm.updateOrderStatus(order: order, status: "ready")
                            }
                            .disabled(order.status != "inProgress")

                            Button("Complete") {
                                vm.updateOrderStatus(order: order, status: "completed")
                            }
                            .disabled(order.status != "ready")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.brown)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
            }
            .navigationTitle("Orders")
        }
    }

    func color(for status: String) -> Color {
        switch status {
        case "pending": return .orange
        case "inProgress": return .blue
        case "ready": return .green
        case "completed": return .gray
        default: return .black
        }
    }
}
