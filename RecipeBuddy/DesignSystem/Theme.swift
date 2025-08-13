import SwiftUI

struct Theme {
    
    struct Colors {
        static let background = Color(red: 0.08, green: 0.08, blue: 0.12)
        static let surface = Color(red: 0.12, green: 0.12, blue: 0.16)
        static let surfaceSecondary = Color(red: 0.16, green: 0.16, blue: 0.20)
        
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.8)
        static let textTertiary = Color.white.opacity(0.6)
        static let textOnLight = Color.black
        
        static let gradientStart = Color(red: 1.0, green: 0.4, blue: 0.2)
        static let gradientMiddle = Color(red: 1.0, green: 0.2, blue: 0.6)
        static let gradientEnd = Color(red: 0.6, green: 0.2, blue: 1.0)
        static let gradientBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
        
        static let buttonPrimary = Color.white
        static let buttonSecondary = Color(red: 0.2, green: 0.2, blue: 0.25)
        static let buttonSelected = Color.white
        
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
        static let warning = Color(red: 1.0, green: 0.8, blue: 0.2)
        static let error = Color(red: 1.0, green: 0.3, blue: 0.3)
        
        static let primary = gradientStart
        static let secondary = gradientMiddle
        static let accent = gradientEnd
    }
    
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .medium, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
        static let button = Font.system(size: 17, weight: .semibold, design: .rounded)
    }
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
        static let button: CGFloat = 16
        static let card: CGFloat = 20
    }
    
    struct Shadows {
        static let small = Color.black.opacity(0.15)
        static let medium = Color.black.opacity(0.25)
        static let large = Color.black.opacity(0.35)
        static let button = Color.black.opacity(0.1)
    }
    
    struct Gradients {
        static let primary = LinearGradient(
            colors: [Colors.gradientStart, Colors.gradientMiddle, Colors.gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let secondary = LinearGradient(
            colors: [Colors.gradientBlue, Colors.gradientMiddle],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    static func theme(_ color: Color, fallback: Color) -> Color { fallback }
}


