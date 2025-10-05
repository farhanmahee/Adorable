
import SwiftUI

public struct BundleLoadingView: View {
  // Progress in 0.0 ... 1.0
  public let progress: Double?
  public let statusText: String

  public init(progress: Double?, statusText: String = "Downloading…") {
    self.progress = progress
    self.statusText = statusText
  }

  public var body: some View {
    VStack(spacing: 16) {
      let p = progress ?? 0.0
      if p > 0 {

      Gauge(value: p) {
        Text("Loading")
      } currentValueLabel: {
          Text("\(Int(p * 100))%")
            .animation(nil, value: progress)
        
      }
      .gaugeStyle(.accessoryCircularCapacity)
      .scaleEffect(2.0)
      .animation(.easeOut(duration: 0.3), value: progress)
      }
    }
    .opacity(progress == 1.0 ? 0 : 1)
    .animation(.easeOut(duration: 0.3), value: progress)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}