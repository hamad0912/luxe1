import SwiftUI
import GoogleSignIn

@main
struct LuxeApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        // Configure Google Sign-In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: "379347883608-eqmgptoncponjeqnubih9agedjfp868q.apps.googleusercontent.com"
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.layoutDirection, .rightToLeft)
                .environmentObject(authViewModel)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authViewModel.isLoggedIn)
    }
}
