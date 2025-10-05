import SwiftUI

public struct BundleLoadingView: View {
  public let progress: Double?

  public init(progress: Double?) {
    self.progress = progress
  }

  public var body: some View {
    VStack(spacing: 16) {
      FreestyleLogo()
        .stroke(Color.secondary, style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
        .aspectRatio(347.0/280.0, contentMode: .fit)
        .frame(width: 100)
    }
    .opacity(progress == 1.0 ? 0 : 1)
    .animation(.easeOut(duration: 0.3), value: progress)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}