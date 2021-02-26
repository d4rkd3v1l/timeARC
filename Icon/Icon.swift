//
//  Icon.swift
//  timeARC
//
//  Created by d4Rk on 12.12.20.
//

import SwiftUI

struct Icon: View {
    let ms: UInt32 = 1000
    let deviceScale: CGFloat = 2

    let colors: [Color] = [.black, .blue, .gray, .green, .orange, .pink, .purple, .red, .white, .yellow]
    let sizes: [Int: String] = [120: "@2x",
                                180: "@3x",
                                1024: "_1024"]//[40, 60, 58, 87, 80, 120, 180, 1024]

    let watchColors: [Color] = [.green]
    let watchSizes: [Int: String] = [48: "_48",
                                     55: "_55",
                                     58: "_58",
                                     87: "_87",
                                     80: "_80",
                                     88: "_88",
                                     100: "_100",
                                     172: "_172",
                                     196: "_196",
                                     216: "_216",
                                     1024: "_1024"]

    @Environment(\.colorScheme) var colorScheme
    @State private var rect: CGRect = .zero
    @State private var color: Color = .green
    @State private var size: CGFloat = 512

    var body: some View {
        VStack {
            Spacer()

            GeometryReader { proxy in
                ArcViewFull2(duration: 67,
                             maxDuration: 100,
                             color: self.color,
                             allowedUnits: [.minute, .second],
                             displayMode: .countUp)
                    .padding(.all, self.size * 0.1)
                    .frame(width: self.size)
                    .redacted(reason: .placeholder)
                    .gradientBackground()
                    .background(RectGetter(rect: $rect))
            }

            Spacer()

            Button("Store") {
                DispatchQueue.global().async {
                    for size in self.sizes {
                        DispatchQueue.main.async {
                            self.size = CGFloat(size.key)/self.deviceScale
                        }
                        usleep(100 * ms)

                        for color in self.colors {
                            DispatchQueue.main.async {
                                self.color = color
                            }
                            usleep(100 * ms)

                            DispatchQueue.main.async {
                                let image = UIApplication.shared.windows[0].rootViewController!.view.asImage(rect: self.rect)
                                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let filename = path.appendingPathComponent("icon_\(colorScheme)_\(color)\(size.value).png")
                                try! image.pngData()!.write(to: filename)
                            }
                        }
                    }

                    for size in self.watchSizes {
                        DispatchQueue.main.async {
                            self.size = CGFloat(size.key)/self.deviceScale
                        }
                        usleep(100 * ms)

                        for color in self.watchColors {
                            DispatchQueue.main.async {
                                self.color = color
                            }
                            usleep(100 * ms)

                            DispatchQueue.main.async {
                                let image = UIApplication.shared.windows[0].rootViewController!.view.asImage(rect: self.rect)
                                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let filename = path.appendingPathComponent("icon_\(colorScheme)_\(color)\(size.value).png")
                                try! image.pngData()!.write(to: filename)
                            }
                        }
                    }

                    print("Done. All files stored in: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)")
                }
            }
            .frame(width: 200, height: 50)
            .foregroundColor(.white)
            .background(Color.gray)
            .cornerRadius(25)

            Spacer()
        }
    }
}

struct Icon_Previews: PreviewProvider {
    static var previews: some View {
        Icon()
    }
}

private extension UIView {
    func asImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

private struct RectGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }

    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}

private struct ArcViewFull2: View {
    var duration: Int
    var maxDuration: Int
    var color: Color = Color.accentColor
    var allowedUnits: NSCalendar.Unit = [.hour, .minute, .second]
    var displayMode: TimerDisplayMode = .countUp

    func timeFontSize(for geometry: GeometryProxy) -> CGFloat {
        if self.allowedUnits == [.hour, .minute, .second] {
            return geometry.size.width / 7.5
        }

        return geometry.size.width / 5.5
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ArcView(color: self.color, progress: (Double(self.duration) / Double(max(self.maxDuration, 1))))

                HStack(alignment: .lastTextBaseline, spacing: geometry.size.width * 0.01) {
                    Text("XX%")
                        .animatableSystemFont(size: geometry.size.width / 3.5, weight: .bold)
                        .padding(0)
                }

                VStack {
                    Text("XX:XX")
                        .animatableSystemFont(size: self.timeFontSize(for: geometry), weight: .bold)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                }
                .frame(width: geometry.size.width * 0.65)
                .offset(x: 0, y: geometry.size.height / 3)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct GradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(LinearGradient(gradient: Gradient(colors: [Color("BackgroundGradientFirst"),
                                                                             Color("BackgroundGradientSecond")]),
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing))
    }
}

private extension View {
    func gradientBackground() -> some View {
        self.modifier(GradientBackgroundModifier())
    }
}
