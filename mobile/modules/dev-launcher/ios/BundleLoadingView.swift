
import SwiftUI

public struct BundleLoadingView: View {
  // Progress in 0.0 ... 1.0. If nil, show indeterminate spinner.
  public let progress: Double?
  public let statusText: String

  public init(progress: Double?, statusText: String = "Downloading…") {
    self.progress = progress
    self.statusText = statusText
  }

  public var body: some View {
    VStack(spacing: 16) {
      if let p = progress {
        // Determinate gauge
        Gauge(value: p) {
          Text("")
        } currentValueLabel: {
          Text("\(Int(p * 100))%")
            .foregroundColor(.primary)
            .font(.system(size: 18, weight: .semibold))
        }
        .gaugeStyle(.accessoryCircular)
        .scaleEffect(2.0)
        .tint(.blue)
      } else {
        // Indeterminate spinner
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .blue))
          .scaleEffect(1.5)
      }

      Text("Loading")
        .foregroundColor(.primary)
        .font(.system(size: 16, weight: .medium))
    }
    .opacity(progress == 1.0 ? 0 : 1)
    .animation(.easeOut(duration: 0.3), value: progress)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}