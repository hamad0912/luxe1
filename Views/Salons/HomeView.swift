import SwiftUI

struct HomeView: View {
    @StateObject private var salonVM = SalonViewModel()
    @StateObject private var bookingVM = BookingViewModel()

    var body: some View {
        TabView {
            SalonListView()
                .tabItem { Label("الرئيسية", systemImage: "house.fill") }
                .environmentObject(salonVM)

            MyBookingsView()
                .tabItem { Label("حجوزاتي", systemImage: "calendar.badge.clock") }
                .environmentObject(bookingVM)

            ProfileView()
                .tabItem { Label("ملفي", systemImage: "person.circle.fill") }
        }
        .accentColor(Color.luxePrimary)
    }
}

struct SalonListView: View {
    @EnvironmentObject var salonVM: SalonViewModel
    @State private var searchText = ""

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var filteredSalons: [Salon] {
        if searchText.isEmpty { return salonVM.salons }
        return salonVM.salons.filter { $0.name.contains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.luxeBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search
                    HStack {
                        TextField("ابحثي عن صالون...", text: $searchText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.luxePrimary)
                            .padding(.trailing, 14)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.luxePrimary.opacity(0.07), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    // Cities filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(salonVM.cities, id: \.self) { city in
                                CityChip(city: city, isSelected: salonVM.selectedCity == city) {
                                    salonVM.selectedCity = city
                                    Task { await salonVM.fetchSalons() }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 8)

                    // Salons grid
                    if salonVM.isLoading {
                        Spacer()
                        ProgressView().tint(Color.luxePrimary)
                        Spacer()
                    } else if filteredSalons.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(Color.luxePrimary.opacity(0.4))
                            Text("لا توجد صالونات")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(filteredSalons) { salon in
                                    NavigationLink(destination: SalonDetailView(salonId: salon.id)) {
                                        SalonCard(salon: salon)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("لوكس ✨")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await salonVM.fetchCities()
            await salonVM.fetchSalons()
        }
    }
}

struct CityChip: View {
    let city: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(city)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : Color.luxeText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.luxePrimary : Color.white)
                .cornerRadius(20)
                .shadow(color: Color.luxePrimary.opacity(0.1), radius: 4, x: 0, y: 1)
        }
    }
}

struct SalonCard: View {
    let salon: Salon

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // Logo
            AsyncImage(url: salon.fullLogoURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Color.luxePrimary.opacity(0.15)
                        .overlay(Image(systemName: "scissors").foregroundColor(Color.luxePrimary))
                }
            }
            .frame(height: 110)
            .clipped()
            .cornerRadius(12)

            // Info
            VStack(alignment: .trailing, spacing: 4) {
                Text(salon.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.luxeText)
                    .lineLimit(1)

                HStack(spacing: 3) {
                    Text("(\(salon.reviewsCount))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if let rating = salon.averageRating {
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.luxeGold)
                    }
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(Color.luxeGold)
                }

                if let city = salon.city {
                    HStack(spacing: 3) {
                        Text(city)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image(systemName: "mappin.circle")
                            .font(.caption2)
                            .foregroundColor(Color.luxePrimary)
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 8)
        }
        .luxeCard()
    }
}
