import SwiftUI

public struct FreestyleLogo: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.20173*width, y: 0.95357*height))
        path.addLine(to: CGPoint(x: 0.20173*width, y: 0.84212*height))
        path.addCurve(to: CGPoint(x: 0.03746*width, y: 0.59349*height), control1: CGPoint(x: 0.10805*width, y: 0.81891*height), control2: CGPoint(x: 0.03746*width, y: 0.71641*height))
        path.addCurve(to: CGPoint(x: 0.17646*width, y: 0.35327*height), control1: CGPoint(x: 0.03746*width, y: 0.48189*height), control2: CGPoint(x: 0.09564*width, y: 0.38714*height))
        path.addCurve(to: CGPoint(x: 0.42778*width, y: 0.04643*height), control1: CGPoint(x: 0.17847*width, y: 0.18338*height), control2: CGPoint(x: 0.29022*width, y: 0.04643*height))
        path.addCurve(to: CGPoint(x: 0.65747*width, y: 0.23126*height), control1: CGPoint(x: 0.5302*width, y: 0.04643*height), control2: CGPoint(x: 0.61831*width, y: 0.12235*height))
        path.addCurve(to: CGPoint(x: 0.7115*width, y: 0.22405*height), control1: CGPoint(x: 0.67488*width, y: 0.22654*height), control2: CGPoint(x: 0.69295*width, y: 0.22405*height))
        path.addCurve(to: CGPoint(x: 0.96284*width, y: 0.53553*height), control1: CGPoint(x: 0.85031*width, y: 0.22405*height), control2: CGPoint(x: 0.96284*width, y: 0.3635*height))
        path.addCurve(to: CGPoint(x: 0.83285*width, y: 0.80837*height), control1: CGPoint(x: 0.96284*width, y: 0.65302*height), control2: CGPoint(x: 0.91035*width, y: 0.75531*height))
        path.addLine(to: CGPoint(x: 0.83285*width, y: 0.95357*height))
        path.move(to: CGPoint(x: 0.42075*width, y: 0.84643*height))
        path.addLine(to: CGPoint(x: 0.42075*width, y: 0.95357*height))
        path.move(to: CGPoint(x: 0.6196*width, y: 0.84643*height))
        path.addLine(to: CGPoint(x: 0.6196*width, y: 0.95357*height))
        return path
    }
}
