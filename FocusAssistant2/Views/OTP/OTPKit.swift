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
#Preview {
    TabBar()
}
