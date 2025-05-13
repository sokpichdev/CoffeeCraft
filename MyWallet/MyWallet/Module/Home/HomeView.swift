//
//  HomeView.swift
//  MyWallet
//
//  Created by Sok Pich on 5/13/25.
//
import SwiftUI

struct HomeView: View {
    @State private var expandedItems: Set<String> = []
    @State private var additionalButtons: [PaymentItem] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                balanceView
                actionButtonsView
                paymentListView
                promoAndDiscountView
                specialOffersViewScroll
            }
            .background(Color(.white))
        }
        .padding(.top, 0.1)
        .padding(.bottom, 0.1)
    }
    // MARK: - Header View
    var headerView: some View {
        HStack(spacing: 0){
            MyLogo()
            Spacer()
            VStack(alignment: .center, spacing: 0) {
                MyIcon()
                    .frame(width: 24, height: 24)
            }
            .frame(width : 40, height: 40)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Color(hex: "#030319"), lineWidth: 2))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom,24)
        .padding(.horizontal,16)
    }
    // MARK: - Balance View
    private var balanceView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Hello Pich,")
                    .foregroundColor(Color(hex: "#030319"))
                    .font(.system(size: 18, design: .default))
                    .fontWeight(.bold)
                    .padding(.bottom, 4)
                Text("Your available balance")
                    .foregroundColor(Color(hex: "#8F92A1"))
                    .font(.system(size: 14, design: .default))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 12)
            Text("$15,901")
                .foregroundColor(Color(hex: "#030319"))
                .font(.system(size: 28, design: .default))
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
        .padding(.horizontal, 16)
    }
    // MARK: - Divider
    var divider: some View {
        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 1, height: 57)
          .background(
            LinearGradient(
              stops: [
                Gradient.Stop(color: .white.opacity(0), location: 0.00),
                Gradient.Stop(color: .white, location: 0.49),
                Gradient.Stop(color: .white.opacity(0), location: 1.00),
              ],
              startPoint: UnitPoint(x: 0.5, y: 0),
              endPoint: UnitPoint(x: 0.5, y: 1)
            )
          )
          .opacity(0.3)
    }
    // MARK: - Action Buttons View
    private var actionButtonsView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                actionButton(title: "Transfer", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/622bfc4d-42d9-4f0a-a1c9-41f38e7f342d")
                divider
                actionButton(title: "Top Up", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/cc99258e-9586-4033-9bbc-2e59ceca7b4d")
                divider
                actionButton(title: "History", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/4634f2e8-3584-423e-84ca-e4b7ea0df423")
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#4CD080"))
            .cornerRadius(16)
            .padding(.bottom, 24)
            .padding(.horizontal, 16)
        }
    }
    // MARK: - Action Button
    private func actionButton(title: String, imageUrl: String) -> some View {
        VStack(alignment: .center, spacing: 0) {
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 32)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 8)
            .padding(.horizontal, 12)
            Text(title)
                .foregroundColor(Color(hex: "#FFFFFF"))
                .font(.system(size: 14, design: .default))
                .fontWeight(.bold)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 21)
        .frame(maxWidth: .infinity)
        .padding(.trailing, 12)
    }
    // MARK: - Payment List View
    private var paymentListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Payment List")
                .foregroundColor(Color(hex: "#030319"))
                .font(.system(size: 18, design: .default))
                .fontWeight(.bold)
                .padding(.bottom, 16)

            // Define the grid layout
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]

            LazyVGrid(columns: columns, spacing: 8) { // Adjust spacing as needed
                ForEach(paymentItems, id: \.id) { item in  // Use id
                    paymentItemView(item: item)
                        .onTapGesture {
                            withAnimation {
                                if expandedItems.contains(item.title) {
                                    expandedItems.remove(item.title)
                                    additionalButtons.removeAll { $0.title.contains(item.title) }
                                } else {
                                    expandedItems.insert(item.title)
                                    addAdditionalButtons(for: item)
                                }
                            }
                        }
                    if expandedItems.contains(item.title) {
                        ForEach(additionalButtons.filter { $0.title.contains(item.title) }) { button in
                            paymentItemView(item: button)
                        }
                    }
                }
            }
            .padding(.horizontal, 8) // Add horizontal padding to the grid
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    // MARK: - Payment Item View
    private func paymentItemView(item: PaymentItem) -> some View {
        VStack(spacing: 0) {
            VStack {
                AsyncImage(url: URL(string: item.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 24)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
            .frame(width: 56, height: 56)
            .background(Color(hex: "#F6FAFD"))
            .cornerRadius(16)
            .padding(.bottom, 8)
            Text(item.title)
                .foregroundColor(Color(hex: "#030319"))
                .font(.system(size: 14, design: .default))
        }
    }

    private func addAdditionalButtons(for item: PaymentItem) {
        switch item.title {
        case "Electricity":
            additionalButtons.append(PaymentItem(title: "Electricity Bill 1", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/d0ebb2d9-944f-4954-92b0-9346c6b5e671"))
            additionalButtons.append(PaymentItem(title: "Electricity Bill 2", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/d0ebb2d9-944f-4954-92b0-9346c6b5e671"))
        case "Internet":
            additionalButtons.append(PaymentItem(title: "Internet Provider A", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/e4cd622e-f11e-44e1-9ac0-d5323cefecde"))
            additionalButtons.append(PaymentItem(title: "Internet Provider B", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/e4cd622e-f11e-44e1-9ac0-d5323cefecde"))
        case "Voucher":
            additionalButtons.append(PaymentItem(title: "Voucher 1", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/684fab2a-b24d-4e49-a28c-00d98c2fb62b"))
            additionalButtons.append(PaymentItem(title: "Voucher 2", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/684fab2a-b24d-4e49-a28c-00d98c2fb62b"))
        case "Assurance":
            additionalButtons.append(PaymentItem(title: "Assurance 1", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/d61e3242-745b-4625-bb35-8887f967c401"))
            additionalButtons.append(PaymentItem(title: "Assurance 2", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/d61e3242-745b-4625-bb35-8887f967c401"))
        case "Merchant":
            additionalButtons.append(PaymentItem(title: "Merchant 1", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/952d0269-28cf-4b08-9925-2d7896eac0b2"))
            additionalButtons.append(PaymentItem(title: "Merchant 2", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/952d0269-28cf-4b08-9925-2d7896eac0b2"))
        case "Mobile Credit":
            additionalButtons.append(PaymentItem(title: "Mobile Credit 1", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/14e2fe0f-d51a-4bfa-ad12-5da052f32474"))
            additionalButtons.append(PaymentItem(title: "Mobile Credit 2", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/14e2fe0f-d51a-4bfa-ad12-5da052f32474"))
        case "Bill":
            additionalButtons.append(PaymentItem(title: "Bill 1", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/81126ea4-8cda-44f8-b215-dc3d96df1238"))
            additionalButtons.append(PaymentItem(title: "Bill 2", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/81126ea4-8cda-44f8-b215-dc3d96df1238"))
        case "More":
            additionalButtons.append(PaymentItem(title: "More 1", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/8ead2ce8-5d7e-4f55-90b7-177cab0a1172"))
            additionalButtons.append(PaymentItem(title: "More 2", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/8ead2ce8-5d7e-4f55-90b7-177cab0a1172"))
        default:
            break
        }
    }

    // MARK: - Promo and Discount View
    private var promoAndDiscountView: some View {
        HStack(spacing: 0) {
            Text("Promo & Discount")
                .foregroundColor(Color(hex: "#030319"))
                .font(.system(size: 18, design: .default))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 4)
            Text("See More")
                .foregroundColor(Color(hex: "#4CD080"))
                .font(.system(size: 14, design: .default))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 16)
        .padding(.horizontal, 16)
    }
    // MARK: - Special Offer View
    private var blackFridayView: some View {
        ZStack {
            // Base card with rounded corners and background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#00373E"))
                .frame(width: 320, height: 170)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hex: "#4CD080"))
                        .frame(width: 100, height: 120)
                        .rotationEffect(.degrees(25))
                        .offset(x: 110, y: 50) // Adjusted offset to position at bottom right
                )
                .clipped()

            // Text content
            VStack(alignment: .leading, spacing: 16) {
                Text("30% OFF")
                    .foregroundColor(Color(hex: "#FFFFFF"))
                    .font(.system(size: 14, design: .default))
                    .fontWeight(.bold)
                Text("Black Friday deal")
                    .foregroundColor(Color(hex: "#FFFFFF"))
                    .font(.system(size: 20, design: .default))
                    .fontWeight(.bold)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Get discount for every ")
                        .foregroundColor(Color(hex: "#BDBDBD"))
                        .font(.system(size: 12, design: .default))
                    Text("top up, transfer and payment")
                        .foregroundColor(Color(hex: "#BDBDBD"))
                        .font(.system(size: 12, design: .default))
                }
            }
            .padding(16)
            .frame(width: 320, height: 170, alignment: .leading)
        }
    }
    private var specialOfferView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#FFD2A6"))
                .frame(width: 320, height: 170)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hex: "#00373E"))
                        .frame(width: 100, height: 120)
                        .rotationEffect(.degrees(25))
                        .offset(x: 110, y: 50) // Adjusted offset to position at bottom right
                )
                .clipped()
            // Text content
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Special Offer for")
                        .foregroundColor(Color(hex: "#030319"))
                        .font(.system(size: 20, design: .default))
                        .fontWeight(.bold)
                    Text("Today's Top Up")
                        .foregroundColor(Color(hex: "#030319"))
                        .font(.system(size: 20, design: .default))
                        .fontWeight(.bold)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Get discount for every top up,")
                        .foregroundColor(Color(hex: "#030319"))
                        .font(.system(size: 12, design: .default))
                    Text("transfer and payment")
                        .foregroundColor(Color(hex: "#030319"))
                        .font(.system(size: 12, design: .default))
                }
            }
            .padding(16)
            .frame(width: 320, height: 170, alignment: .leading)
        }
    }
    // MARK: - Special Oferr Scroll
    private var specialOffersViewScroll: some View {
           ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 16) {
                   blackFridayView
                   specialOfferView
               }
               .padding(.horizontal, 16)
           }
       }
    
    // MARK: - Footer View
    private var footerView: some View {
        ZStack {
            AsyncImage(url: URL(string: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/5b45ac83-854a-4b2a-b364-da24c8db6ac0")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    footerIcon(url: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/f3faa96d-200a-4e01-983b-afe9a83768da")
                    footerIcon(url: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/14da7eb5-1189-449a-95e8-0ebd4d2f780f")
                    Spacer()
                    footerIcon(url: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/3aa1ce4c-f8c5-4ee8-a7eb-82e896f2ce4e")
                    footerIcon(url: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/d91bac45-4d31-4829-8cb7-e15fcd9ba75b")
                }
                .frame(height: 24)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 17)
                .padding(.bottom, 29)
                Divider()
                    .background(Color(hex: "#E0E0E0"))
                    .cornerRadius(100)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
        }
    }
    // MARK: - Footer Icon
    private func footerIcon(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }
        .frame(width: 24, height: 24)
        .padding(.trailing, 52)
    }

    // Sample payment items
    private var paymentItems: [PaymentItem] {
        [
            PaymentItem(title: "Electricity", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/d0ebb2d9-944f-4954-92b0-9346c6b5e671"),
            PaymentItem(title: "Internet", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/e4cd622e-f11e-44e1-9ac0-d5323cefecde"),
            PaymentItem(title: "Voucher", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/684fab2a-b24d-4e49-a28c-00d98c2fb62b"),
            PaymentItem(title: "Assurance", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/d61e3242-745b-4625-bb35-8887f967c401"),
            PaymentItem(title: "Merchant", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/952d0269-28cf-4b08-9925-2d7896eac0b2"),
            PaymentItem(title: "Mobile Credit", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/14e2fe0f-d51a-4bfa-ad12-5da052f32474"),
            PaymentItem(title: "Bill", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/81126ea4-8cda-44f8-b215-dc3d96df1238"),
            PaymentItem(title: "More", imageUrl: "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/8ead2ce8-5d7e-4f55-90b7-177cab0a1172")
        ]
    }
}
