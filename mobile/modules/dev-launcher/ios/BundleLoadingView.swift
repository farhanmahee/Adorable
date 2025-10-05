import SwiftUI

public struct BundleLoadingView: View {
  public let progress: Double?

  public init(progress: Double?) {
    self.progress = progress
  }

  public var body: some View {
    VStack(spacing: 16) {
      ZStack {
        // Base logo in secondary color
        FreestyleLogo()
          .stroke(Color.secondary, style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))

        // Filled overlay in primary color, clipped by progress
        FreestyleLogo()
          .stroke(Color.primary, style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
          .mask(
            GeometryReader { geometry in
              Rectangle()
                .frame(height: geometry.size.height * CGFloat(progress ?? 0.0))
                .offset(y: geometry.size.height * CGFloat(1.0 - (progress ?? 0.0)))
            }
          )
      }
      .aspectRatio(347.0/280.0, contentMode: .fit)
      .frame(width: 100)
      .animation(.easeOut(duration: 0.3), value: progress)
    }
    .opacity(progress == 1.0 ? 0 : 1)
    .animation(.easeOut(duration: 0.3), value: progress)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}