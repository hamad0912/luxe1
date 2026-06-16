import SwiftUI

struct SalonDetailView: View {
    let salonId: Int
    @StateObject private var salonVM = SalonViewModel()
    @State private var selectedServiceIndex = 0
    @State private var selectedStaffId: Int? = nil
    @State private var showBooking = false

    var salon: Salon? { salonVM.selectedSalon }

    var body: some View {
        ZStack {
            Color.luxeBackground.ignoresSafeArea()

            if salonVM.isLoading {
                ProgressView().tint(Color.luxePrimary)
            } else if let salon = salon {
                ScrollView {
                    VStack(alignment: .trailing, spacing: 20) {
                        // Header card
                        VStack(alignment: .trailing, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    if let phone = salon.phone {
                                        HStack(spacing: 4) {
                                            Text(phone)
                                                .font(.subheadline)
                                                .foregroundColor(Color.luxeText)
                                            Image(systemName: "phone.fill")
                                                .foregroundColor(Color.luxePrimary)
                                                .font(.subheadline)
                                        }
                                    }
                                    if let address = salon.address {
                                        HStack(spacing: 4) {
                                            Text(address)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Image(systemName: "mappin")
                                                .foregroundColor(Color.luxePrimary)
                                                .font(.caption)
                                        }
                                    }
                                }
                                Spacer()
                                AsyncImage(url: salon.fullLogoURL) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().scaledToFill()
                                    default:
                                        Color.luxePrimary.opacity(0.2)
                                            .overlay(Image(systemName: "scissors").foregroundColor(Color.luxePrimary).font(.title))
                                    }
                                }
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            HStack(spacing: 6) {
                                Text("(\(salon.reviewsCount) تقييم)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if let rating = salon.averageRating {
                                    ReadonlyStarRating(rating: rating)
                                    Text(String(format: "%.1f", rating))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.luxeGold)
                                }
                            }

                            if let desc = salon.description {
                                Text(desc)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .padding(16)
                        .luxeCard()

                        // Services Picker
                        if !salon.services.isEmpty {
                            VStack(alignment: .trailing, spacing: 12) {
                                SectionHeader(title: "الخدمات")
                                Picker("الخدمة", selection: $selectedServiceIndex) {
                                    ForEach(salon.services.indices, id: \.self) { i in
                                        Text(salon.services[i].name).tag(i)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color.luxePrimary)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                                let service = salon.services[selectedServiceIndex]
                                HStack {
                                    Text("\(service.duration) دقيقة")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(String(format: "%.0f", service.price)) ر.س")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.luxePrimary)
                                }
                            }
                            .padding(16)
                            .luxeCard()
                        }

                        // Staff
                        if !salon.staff.isEmpty {
                            VStack(alignment: .trailing, spacing: 12) {
                                SectionHeader(title: "فريق العمل")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        // None option
                                        StaffCard(
                                            name: "أي موظفة",
                                            specialty: nil,
                                            rating: nil,
                                            isSelected: selectedStaffId == nil
                                        ) { selectedStaffId = nil }

                                        ForEach(salon.staff) { member in
                                            StaffCard(
                                                name: member.name,
                                                specialty: member.specialty,
                                                rating: member.averageRating,
                                                isSelected: selectedStaffId == member.id
                                            ) { selectedStaffId = member.id }
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }
                            .padding(16)
                            .luxeCard()
                        }

                        // Active Coupons
                        if !salon.activeCoupons.isEmpty {
                            VStack(alignment: .trailing, spacing: 10) {
                                SectionHeader(title: "كوبونات الخصم 🏷️")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(salon.activeCoupons) { coupon in
                                            CouponBadge(coupon: coupon)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .luxeCard()
                        }

                        // Reviews
                        if !salon.reviews.isEmpty {
                            VStack(alignment: .trailing, spacing: 12) {
                                SectionHeader(title: "آخر التقييمات")
                                ForEach(salon.reviews) { review in
                                    ReviewCell(review: review)
                                }
                            }
                            .padding(16)
                            .luxeCard()
                        }

                        // Book button
                        if !salon.services.isEmpty {
                            LuxeButton(title: "احجزي الآن 💅") {
                                showBooking = true
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle(salon?.name ?? "الصالون")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBooking) {
            if let salon = salon, !salon.services.isEmpty {
                BookingView(
                    salon: salon,
                    service: salon.services[selectedServiceIndex],
                    staffId: selectedStaffId
                )
            }
        }
        .task { await salonVM.fetchSalon(id: salonId) }
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(Color.luxeText)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct StaffCard: View {
    let name: String
    let specialty: String?
    let rating: Double?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(isSelected ? Color.luxePrimary : Color.gray.opacity(0.4))

                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.luxeText)
                    .multilineTextAlignment(.center)

                if let specialty = specialty {
                    Text(specialty)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                if let rating = rating {
                    HStack(spacing: 2) {
                        Text(String(format: "%.1f", rating))
                            .font(.caption2)
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                    }
                    .foregroundColor(Color.luxeGold)
                }
            }
            .frame(width: 80)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(isSelected ? Color.luxePrimary.opacity(0.1) : Color.luxeBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.luxePrimary : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

struct CouponBadge: View {
    let coupon: Coupon
    var body: some View {
        HStack(spacing: 6) {
            Text(coupon.displayText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.luxeGold)
            Text(coupon.code)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color.luxeText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.luxeGold.opacity(0.12))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.luxeGold.opacity(0.3), lineWidth: 1))
    }
}

struct ReviewCell: View {
    let review: Review
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack {
                ReadonlyStarRating(rating: Double(review.rating))
                Spacer()
                if let name = review.userName {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.luxeText)
                }
            }
            if let comment = review.comment {
                Text(comment)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
            if let date = review.createdAt {
                Text(date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        Divider()
    }
}
