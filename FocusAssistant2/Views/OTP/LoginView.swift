//
//  LoginView.swift
//  FocusAssistant2
//
//  Created by Nana Sekyere on 28/09/2025.
//

import SwiftUI

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

