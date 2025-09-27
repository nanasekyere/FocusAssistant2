//
//  OTPKit.swift
//  FocusAssistant2
//
//  Created by Nana Sekyere on 27/09/2025.
//

import SwiftUI
import FirebaseAuth

struct OTPKit<Content: View>: View {
    init(_ appstorageID: String, @ViewBuilder content: @escaping () -> Content) {
        self._isLogged =  .init(wrappedValue: false, appstorageID)
        
        self.content = content()
    }
    
    private var content: Content
    @AppStorage private var isLogged: Bool
    var body: some View {
        ZStack {
            if isLogged {
                content
            } else {
                LoginView {
                    isLogged = true
                }
            }
        }
    }
}

struct LoginView: View {
    var onComplete: () -> ()
    @State private var mobileNumber: String = ""
    @State private var countryCode: CountryCodePicker.Country?
    @State private var showVeificationView: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome Back")
                    .font(.largeTitle)
                
                Text("Please Verify your Mobile Number to continue.")
                    .font(.callout)
            }
            .fontWeight(.medium)
            .padding(.top, 5)
            
            HStack(spacing: 8) {
                Group {
                    CountryCodePicker(selection: $countryCode)
                    
                    HStack(spacing: 5) {
                        Image(systemName: "phone.fill")
                            .font(.callout)
                            .foregroundStyle(.gray)
                            .frame(width: 30)
                        
                        TextField("Mobile Number", text: $mobileNumber)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                    }
                    .padding(.horizontal, 12)
                }
                .frame(height: 50)
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
            }
            .padding(.top, 10)
            
            Button {
                isFocused = false
                showVeificationView = true
            } label: {
                Text("Get OTP")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .foregroundStyle(.background)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.primary)
            .disabled(mobileNumber.isEmpty)
            
            Spacer(minLength: 0)
            
            HStack(spacing: 4) {
                Link("Terms of Service", destination: URL(string: "https://apple.com")!)
                    .underline()
                
                Text("&")
                
                Link("Privacy Policy", destination: URL(string: "https://apple.com")!)
                    .underline()
            }
            .font(.callout)
            .fontWeight(.medium)
            .foregroundStyle(Color.primary.secondary)
            .frame(maxWidth: .infinity)
            
        }
        .padding([.horizontal, .top], 20)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            Color.clear
                .contentShape(.rect)
                .onTapGesture {
                    isFocused = false
                }
        }
        .focused($isFocused)
        .sheet(isPresented: $showVeificationView) {
            OTPVerificationView(fullNumber: fullMobileNumber, onComplete: onComplete)
        }
    }
    
    var fullMobileNumber: String {
        if let dialCode = countryCode?.dialCode {
            return dialCode+mobileNumber
        }
        return ""
    }
}

struct OTPVerificationView: View {
    var fullNumber: String
    var onComplete: () -> ()
    @Environment(\.dismiss) var dismiss
    @State private var isOTPSent: Bool = false
    @State private var isOTPTaskTriggered: Bool = false
    @State private var authID: String = ""
    @State private var otpCode: String = ""
    @FocusState private var isFocused: Bool
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            if isOTPSent {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verification")
                            .font(.largeTitle)
                        
                        HStack(spacing: 4) {
                            Text("Enter the 6-digit code")
                                .font(.callout)
                                
                        }
                    }
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .trailing) {
                        Button("", systemImage: "xmark.circle.fill") {
                            dismiss()
                        }
                        .font(.title)
                        .tint(.gray)
                        .offset(x: 10, y: -15)
                    }
                    .padding(.top, 10)
                    
                    VerificationField(type: .six, value: $otpCode) { code in
                        if code.count == 6 {
                            isFocused = false
                            do {
                                let credential = PhoneAuthProvider.provider().credential(
                                    withVerificationID: authID,
                                    verificationCode: code
                                )
                                let _ = try await Auth.auth().signIn(with: credential)
                                dismiss()
                                try? await Task.sleep(for: .seconds(0.25))
                                onComplete()
                                return .valid
                            } catch {
                                isFocused = true
                                return .invalid
                            }
                        }
                        return .typing
                    }
                    .allowsHitTesting(false)
                    .padding(.top, 12)
                }
                .padding(20)
                .geometryGroup()
                .transition(.blurReplace)
            } else {
                VStack(spacing: 12) {
                    let symbols = ["iphone", "ellipsis.message.fill", "paperplane.fill"]
                    PhaseAnimator(symbols) { symbol in
                        Image(systemName: symbol)
                            .font(.system(size: 100))
                            .contentTransition(.symbolEffect)
                            .frame(width: 150, height: 150)
                        
                    } animation: { _ in
                            .linear(duration: 1.2)
                    }
                    .frame(height: 150)
                    
                    Text("Sending Verification Code...")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .geometryGroup()
                .transition(.blurReplace)
            }
        }
        .presentationDetents([.height(190)])
        .presentationBackground(.background)
        .presentationCornerRadius(isiOS26 ? nil : 30)
        .interactiveDismissDisabled()
        .task {
            guard !isOTPTaskTriggered else { return }
            isOTPTaskTriggered = true
            do {
                try await Task.sleep(for: .seconds(3))
                try await sendOTP()
                isOTPSent = true
                isFocused = true
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
        .animation(.snappy(duration: 0.25, extraBounce: 0), value: isOTPSent)
        .focused($isFocused)
        .alert("Something Went Wrong", isPresented: $showAlert) {
            Button("Dismiss", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }

    }
    
    private func sendOTP() async throws {
        let provider = PhoneAuthProvider.provider()
        let authID = try await provider.verifyPhoneNumber(fullNumber)
        self.authID = authID
        
        print("OTP Sent: \(otpCode)")
    }
}

struct CountryCodePicker: View {
    @Binding var selection: Country?
    @State private var countries: [Country] = []
    @Environment(\.locale) var locale
    
    var body: some View {
        Picker("", selection: $selection) {
            ForEach(countries) { country in
                if let dialCode = country.dialCode {
                    Text("\(dialCode) (\(country.code))")
                        .tag(country)
                }
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .onAppear(perform: getLocales)
        .tint(.primary)
    }
    
    fileprivate func getLocales() {
        guard countries.isEmpty else { return }

        guard let url = Bundle.main.url(forResource: "CountryCodes", withExtension: "json") else {
            assertionFailure("CountryCodes.json not found in bundle. Add it to Copy Bundle Resources.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let decoded = try decoder.decode([Country].self, from: data)
            let filtered = decoded.filter { $0.dialCode != nil }
            self.countries = filtered

            if let regionCode = locale.region?.identifier,
               let selected = filtered.first(where: { $0.code == regionCode }) {
                selection = selected
            }
        } catch {
            print("Failed to load CountryCodes.json: \(error)")
            assertionFailure("Decoding error: \(error)")
        }
    }
    
    struct Country: Identifiable, Codable, Hashable {
        var id: String = UUID().uuidString
        var name: String
        var dialCode: String?
        var code: String
        
        enum CodingKeys: CodingKey {
            case name
            case dialCode
            case code
        }
        
    }
}

#Preview {
    TabBar()
}
