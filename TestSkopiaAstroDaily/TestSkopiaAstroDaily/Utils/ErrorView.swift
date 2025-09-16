import SwiftUI

struct ErrorView: View {
    let error: AppError
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text(error.errorDescription ?? Strings.errorTryAgain)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
            
            if error.isRecoverable {
                Button(Strings.errorTryAgain, action: retry)
                    .buttonStyle(.borderedProminent)
                    .accentColor(.white)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}