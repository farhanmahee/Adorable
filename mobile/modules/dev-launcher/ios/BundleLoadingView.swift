// BundleLoadingView.swift
// Minimal SwiftUI overlay shown during RN app load with optional percent.

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
    ZStack(alignment: .top) {
      // Faint scrim so the overlay is visible even on white backgrounds
      Color.black.opacity(0.15).ignoresSafeArea()

      VStack(spacing: 10) {
        if let p = progress {
          // Determinate linear bar with percent text
          ProgressView(value: p)
            .progressViewStyle(.linear)
            .tint(.white)
            .frame(maxWidth: .infinity)
          Text("\(statusText) \(Int(p * 100))%")
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .semibold))
        } else {
          // Indeterminate spinner
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(0.9)
          Text(statusText)
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .semibold))
        }
      }
      .padding(10)
      .background(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(Color.black.opacity(0.8))
      )
      .padding(.horizontal)
      .padding(.top, 12)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}