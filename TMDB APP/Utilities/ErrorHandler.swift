//
//  ErrorHandler.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import SwiftUI

// MARK: - App Error
enum AppError: Error, LocalizedError {
    case networkError(String)
    case invalidData
    case noInternetConnection
    case apiKeyMissing
    case rateLimitExceeded
    case movieNotFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .invalidData:
            return "Invalid data received from server"
        case .noInternetConnection:
            return "No internet connection available"
        case .apiKeyMissing:
            return "API key is missing or invalid"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later"
        case .movieNotFound:
            return "Movie not found"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .noInternetConnection, .rateLimitExceeded, .unknown:
            return true
        case .invalidData, .apiKeyMissing, .movieNotFound:
            return false
        }
    }
}

// MARK: - Error Alert Modifier
struct ErrorAlert: ViewModifier {
    @Binding var error: AppError?
    let onRetry: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: Binding(
                get: { error != nil },
                set: { _ in error = nil }
            )) {
                if let error = error, error.isRetryable, let onRetry = onRetry {
                    Button("Retry", action: onRetry)
                }
                Button("OK", role: .cancel) { }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
    }
}

extension View {
    func errorAlert(_ error: Binding<AppError?>, onRetry: (() -> Void)? = nil) -> some View {
        modifier(ErrorAlert(error: error, onRetry: onRetry))
    }
}