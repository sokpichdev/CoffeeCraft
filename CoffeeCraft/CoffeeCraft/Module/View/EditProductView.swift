struct EditProductView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var productVM: ProductViewModel
    @Binding var product: Product

    var isEditing: Bool {
        productVM.products.contains(product)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Image Preview
                    VStack {
                        if let url = URL(string: product.imageURL), !product.imageURL.isEmpty {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(14)
                            .shadow(radius: 5)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 180)
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("No Image")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }

                        TextField("Image URL", text: $product.imageURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }

                    // MARK: - Product Info
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Basic Info", systemImage: "info.circle")
                            .font(.headline)
                            .foregroundColor(.brown)

                        Group {
                            CustomProductTextField(title: "Name", text: $product.name, icon: "cup.and.saucer.fill")
                            CustomProductTextField(title: "Description", text: $product.description, icon: "text.justify")
                            CustomNumberField(title: "Price ($)", value: $product.price, icon: "dollarsign.circle.fill")
                            CustomProductTextField(title: "Category", text: $product.category, icon: "folder.fill")
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))

                    // MARK: - Availability Toggle
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Status", systemImage: "checkmark.circle")
                            .font(.headline)
                            .foregroundColor(.brown)
                        Toggle("Available for order", isOn: $product.available)
                            .toggleStyle(SwitchToggleStyle(tint: .brown))
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))

                    // MARK: - Save Button
                    Button(action: {
                        Task {
                            await productVM.saveProduct(product)
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text(isEditing ? "Save Changes" : "Add Product")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(isEditing ? "Edit Product" : "Add Product")
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}