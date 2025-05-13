//
//  MyIcon.swift
//  MyWallet
//
//  Created by Sok Pich on 5/13/25.
//

import SwiftUI
struct MyIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.51228*width, y: 0.37561*height))
        path.addCurve(to: CGPoint(x: 0.43841*width, y: 0.39123*height), control1: CGPoint(x: 0.48664*width, y: 0.37307*height), control2: CGPoint(x: 0.46083*width, y: 0.37853*height))
        path.addCurve(to: CGPoint(x: 0.38701*width, y: 0.44654*height), control1: CGPoint(x: 0.41598*width, y: 0.40393*height), control2: CGPoint(x: 0.39803*width, y: 0.42325*height))
        path.addCurve(to: CGPoint(x: 0.37684*width, y: 0.52136*height), control1: CGPoint(x: 0.37598*width, y: 0.46984*height), control2: CGPoint(x: 0.37243*width, y: 0.49597*height))
        path.addCurve(to: CGPoint(x: 0.41161*width, y: 0.58839*height), control1: CGPoint(x: 0.38124*width, y: 0.54675*height), control2: CGPoint(x: 0.39339*width, y: 0.57017*height))
        path.addCurve(to: CGPoint(x: 0.47863*width, y: 0.62316*height), control1: CGPoint(x: 0.42983*width, y: 0.60661*height), control2: CGPoint(x: 0.45324*width, y: 0.61876*height))
        path.addCurve(to: CGPoint(x: 0.55346*width, y: 0.61299*height), control1: CGPoint(x: 0.50403*width, y: 0.62757*height), control2: CGPoint(x: 0.53016*width, y: 0.62401*height))
        path.addCurve(to: CGPoint(x: 0.60877*width, y: 0.56159*height), control1: CGPoint(x: 0.57675*width, y: 0.60197*height), control2: CGPoint(x: 0.59607*width, y: 0.58402*height))
        path.addCurve(to: CGPoint(x: 0.62439*width, y: 0.48772*height), control1: CGPoint(x: 0.62147*width, y: 0.53917*height), control2: CGPoint(x: 0.62693*width, y: 0.51336*height))
        path.addCurve(to: CGPoint(x: 0.58833*width, y: 0.41166*height), control1: CGPoint(x: 0.6215*width, y: 0.45896*height), control2: CGPoint(x: 0.60877*width, y: 0.4321*height))
        path.addCurve(to: CGPoint(x: 0.51228*width, y: 0.37561*height), control1: CGPoint(x: 0.5679*width, y: 0.39123*height), control2: CGPoint(x: 0.54103*width, y: 0.37849*height))
        path.addLine(to: CGPoint(x: 0.51228*width, y: 0.37561*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.81326*width, y: 0.5*height))
        path.addCurve(to: CGPoint(x: 0.81027*width, y: 0.5406*height), control1: CGPoint(x: 0.81318*width, y: 0.51359*height), control2: CGPoint(x: 0.81218*width, y: 0.52715*height))
        path.addLine(to: CGPoint(x: 0.89857*width, y: 0.60986*height))
        path.addCurve(to: CGPoint(x: 0.90588*width, y: 0.62241*height), control1: CGPoint(x: 0.90242*width, y: 0.61305*height), control2: CGPoint(x: 0.90501*width, y: 0.6175*height))
        path.addCurve(to: CGPoint(x: 0.90336*width, y: 0.63672*height), control1: CGPoint(x: 0.90676*width, y: 0.62733*height), control2: CGPoint(x: 0.90586*width, y: 0.6324*height))
        path.addLine(to: CGPoint(x: 0.81982*width, y: 0.78125*height))
        path.addCurve(to: CGPoint(x: 0.80863*width, y: 0.79041*height), control1: CGPoint(x: 0.81728*width, y: 0.78553*height), control2: CGPoint(x: 0.81332*width, y: 0.78877*height))
        path.addCurve(to: CGPoint(x: 0.79416*width, y: 0.79022*height), control1: CGPoint(x: 0.80393*width, y: 0.79205*height), control2: CGPoint(x: 0.7988*width, y: 0.79198*height))
        path.addLine(to: CGPoint(x: 0.70646*width, y: 0.7549*height))
        path.addCurve(to: CGPoint(x: 0.69122*width, y: 0.75288*height), control1: CGPoint(x: 0.70162*width, y: 0.75298*height), control2: CGPoint(x: 0.69639*width, y: 0.75228*height))
        path.addCurve(to: CGPoint(x: 0.67683*width, y: 0.75832*height), control1: CGPoint(x: 0.68605*width, y: 0.75348*height), control2: CGPoint(x: 0.6811*width, y: 0.75535*height))
        path.addCurve(to: CGPoint(x: 0.63476*width, y: 0.78281*height), control1: CGPoint(x: 0.66345*width, y: 0.76754*height), control2: CGPoint(x: 0.64939*width, y: 0.77572*height))
        path.addCurve(to: CGPoint(x: 0.62318*width, y: 0.79251*height), control1: CGPoint(x: 0.63017*width, y: 0.78505*height), control2: CGPoint(x: 0.62619*width, y: 0.78838*height))
        path.addCurve(to: CGPoint(x: 0.61754*width, y: 0.80653*height), control1: CGPoint(x: 0.62018*width, y: 0.79665*height), control2: CGPoint(x: 0.61824*width, y: 0.80146*height))
        path.addLine(to: CGPoint(x: 0.60439*width, y: 0.90006*height))
        path.addCurve(to: CGPoint(x: 0.59717*width, y: 0.91275*height), control1: CGPoint(x: 0.60353*width, y: 0.905*height), control2: CGPoint(x: 0.60098*width, y: 0.90948*height))
        path.addCurve(to: CGPoint(x: 0.58353*width, y: 0.91797*height), control1: CGPoint(x: 0.59337*width, y: 0.91602*height), control2: CGPoint(x: 0.58855*width, y: 0.91786*height))
        path.addLine(to: CGPoint(x: 0.41646*width, y: 0.91797*height))
        path.addCurve(to: CGPoint(x: 0.40298*width, y: 0.91297*height), control1: CGPoint(x: 0.41153*width, y: 0.91788*height), control2: CGPoint(x: 0.40678*width, y: 0.91612*height))
        path.addCurve(to: CGPoint(x: 0.39558*width, y: 0.90065*height), control1: CGPoint(x: 0.39919*width, y: 0.90982*height), control2: CGPoint(x: 0.39658*width, y: 0.90548*height))
        path.addLine(to: CGPoint(x: 0.38246*width, y: 0.80725*height))
        path.addCurve(to: CGPoint(x: 0.37666*width, y: 0.79311*height), control1: CGPoint(x: 0.38172*width, y: 0.80213*height), control2: CGPoint(x: 0.37973*width, y: 0.79727*height))
        path.addCurve(to: CGPoint(x: 0.36488*width, y: 0.78338*height), control1: CGPoint(x: 0.3736*width, y: 0.78894*height), control2: CGPoint(x: 0.36955*width, y: 0.7856*height))
        path.addCurve(to: CGPoint(x: 0.32297*width, y: 0.75883*height), control1: CGPoint(x: 0.35027*width, y: 0.77633*height), control2: CGPoint(x: 0.33626*width, y: 0.76812*height))
        path.addCurve(to: CGPoint(x: 0.30863*width, y: 0.75343*height), control1: CGPoint(x: 0.31871*width, y: 0.75587*height), control2: CGPoint(x: 0.31378*width, y: 0.75401*height))
        path.addCurve(to: CGPoint(x: 0.29345*width, y: 0.75549*height), control1: CGPoint(x: 0.30348*width, y: 0.75285*height), control2: CGPoint(x: 0.29826*width, y: 0.75355*height))
        path.addLine(to: CGPoint(x: 0.20578*width, y: 0.79078*height))
        path.addCurve(to: CGPoint(x: 0.19132*width, y: 0.79099*height), control1: CGPoint(x: 0.20113*width, y: 0.79255*height), control2: CGPoint(x: 0.19601*width, y: 0.79263*height))
        path.addCurve(to: CGPoint(x: 0.18011*width, y: 0.78184*height), control1: CGPoint(x: 0.18662*width, y: 0.78935*height), control2: CGPoint(x: 0.18265*width, y: 0.78611*height))
        path.addLine(to: CGPoint(x: 0.09658*width, y: 0.6373*height))
        path.addCurve(to: CGPoint(x: 0.09405*width, y: 0.623*height), control1: CGPoint(x: 0.09407*width, y: 0.63299*height), control2: CGPoint(x: 0.09317*width, y: 0.62792*height))
        path.addCurve(to: CGPoint(x: 0.10136*width, y: 0.61045*height), control1: CGPoint(x: 0.09492*width, y: 0.61808*height), control2: CGPoint(x: 0.09752*width, y: 0.61363*height))
        path.addLine(to: CGPoint(x: 0.17599*width, y: 0.55185*height))
        path.addCurve(to: CGPoint(x: 0.18534*width, y: 0.53959*height), control1: CGPoint(x: 0.18008*width, y: 0.54861*height), control2: CGPoint(x: 0.1833*width, y: 0.5444*height))
        path.addCurve(to: CGPoint(x: 0.18771*width, y: 0.52435*height), control1: CGPoint(x: 0.18739*width, y: 0.53479*height), control2: CGPoint(x: 0.1882*width, y: 0.52955*height))
        path.addCurve(to: CGPoint(x: 0.18658*width, y: 0.49994*height), control1: CGPoint(x: 0.18701*width, y: 0.51621*height), control2: CGPoint(x: 0.18658*width, y: 0.50809*height))
        path.addCurve(to: CGPoint(x: 0.18771*width, y: 0.47582*height), control1: CGPoint(x: 0.18658*width, y: 0.4918*height), control2: CGPoint(x: 0.18699*width, y: 0.48379*height))
        path.addCurve(to: CGPoint(x: 0.18523*width, y: 0.46071*height), control1: CGPoint(x: 0.18815*width, y: 0.47065*height), control2: CGPoint(x: 0.18729*width, y: 0.46546*height))
        path.addCurve(to: CGPoint(x: 0.17586*width, y: 0.44859*height), control1: CGPoint(x: 0.18316*width, y: 0.45595*height), control2: CGPoint(x: 0.17994*width, y: 0.45179*height))
        path.addLine(to: CGPoint(x: 0.10127*width, y: 0.39*height))
        path.addCurve(to: CGPoint(x: 0.0941*width, y: 0.37748*height), control1: CGPoint(x: 0.09748*width, y: 0.3868*height), control2: CGPoint(x: 0.09494*width, y: 0.38237*height))
        path.addCurve(to: CGPoint(x: 0.09664*width, y: 0.36328*height), control1: CGPoint(x: 0.09325*width, y: 0.3726*height), control2: CGPoint(x: 0.09415*width, y: 0.36757*height))
        path.addLine(to: CGPoint(x: 0.18017*width, y: 0.21875*height))
        path.addCurve(to: CGPoint(x: 0.19137*width, y: 0.20959*height), control1: CGPoint(x: 0.18271*width, y: 0.21447*height), control2: CGPoint(x: 0.18668*width, y: 0.21123*height))
        path.addCurve(to: CGPoint(x: 0.20584*width, y: 0.20978*height), control1: CGPoint(x: 0.19607*width, y: 0.20795*height), control2: CGPoint(x: 0.20119*width, y: 0.20802*height))
        path.addLine(to: CGPoint(x: 0.29353*width, y: 0.2451*height))
        path.addCurve(to: CGPoint(x: 0.30878*width, y: 0.24712*height), control1: CGPoint(x: 0.29837*width, y: 0.24702*height), control2: CGPoint(x: 0.30361*width, y: 0.24772*height))
        path.addCurve(to: CGPoint(x: 0.32316*width, y: 0.24168*height), control1: CGPoint(x: 0.31395*width, y: 0.24653*height), control2: CGPoint(x: 0.31889*width, y: 0.24466*height))
        path.addCurve(to: CGPoint(x: 0.36523*width, y: 0.21719*height), control1: CGPoint(x: 0.33655*width, y: 0.23246*height), control2: CGPoint(x: 0.35061*width, y: 0.22428*height))
        path.addCurve(to: CGPoint(x: 0.37681*width, y: 0.20749*height), control1: CGPoint(x: 0.36983*width, y: 0.21495*height), control2: CGPoint(x: 0.37381*width, y: 0.21162*height))
        path.addCurve(to: CGPoint(x: 0.38246*width, y: 0.19348*height), control1: CGPoint(x: 0.37981*width, y: 0.20335*height), control2: CGPoint(x: 0.38175*width, y: 0.19854*height))
        path.addLine(to: CGPoint(x: 0.3956*width, y: 0.09994*height))
        path.addCurve(to: CGPoint(x: 0.40282*width, y: 0.08725*height), control1: CGPoint(x: 0.39647*width, y: 0.095*height), control2: CGPoint(x: 0.39902*width, y: 0.09051*height))
        path.addCurve(to: CGPoint(x: 0.41646*width, y: 0.08203*height), control1: CGPoint(x: 0.40663*width, y: 0.08398*height), control2: CGPoint(x: 0.41145*width, y: 0.08214*height))
        path.addLine(to: CGPoint(x: 0.58353*width, y: 0.08203*height))
        path.addCurve(to: CGPoint(x: 0.59701*width, y: 0.08703*height), control1: CGPoint(x: 0.58846*width, y: 0.08212*height), control2: CGPoint(x: 0.59322*width, y: 0.08388*height))
        path.addCurve(to: CGPoint(x: 0.60441*width, y: 0.09936*height), control1: CGPoint(x: 0.60081*width, y: 0.09018*height), control2: CGPoint(x: 0.60342*width, y: 0.09453*height))
        path.addLine(to: CGPoint(x: 0.61754*width, y: 0.19275*height))
        path.addCurve(to: CGPoint(x: 0.62333*width, y: 0.20689*height), control1: CGPoint(x: 0.61828*width, y: 0.19787*height), control2: CGPoint(x: 0.62026*width, y: 0.20273*height))
        path.addCurve(to: CGPoint(x: 0.63511*width, y: 0.21662*height), control1: CGPoint(x: 0.6264*width, y: 0.21106*height), control2: CGPoint(x: 0.63045*width, y: 0.2144*height))
        path.addCurve(to: CGPoint(x: 0.67703*width, y: 0.24117*height), control1: CGPoint(x: 0.64972*width, y: 0.22367*height), control2: CGPoint(x: 0.66374*width, y: 0.23188*height))
        path.addCurve(to: CGPoint(x: 0.69136*width, y: 0.24657*height), control1: CGPoint(x: 0.68128*width, y: 0.24413*height), control2: CGPoint(x: 0.68621*width, y: 0.24599*height))
        path.addCurve(to: CGPoint(x: 0.70654*width, y: 0.24451*height), control1: CGPoint(x: 0.69651*width, y: 0.24716*height), control2: CGPoint(x: 0.70173*width, y: 0.24645*height))
        path.addLine(to: CGPoint(x: 0.79422*width, y: 0.20922*height))
        path.addCurve(to: CGPoint(x: 0.80868*width, y: 0.20901*height), control1: CGPoint(x: 0.79886*width, y: 0.20745*height), control2: CGPoint(x: 0.80398*width, y: 0.20738*height))
        path.addCurve(to: CGPoint(x: 0.81988*width, y: 0.21816*height), control1: CGPoint(x: 0.81338*width, y: 0.21065*height), control2: CGPoint(x: 0.81734*width, y: 0.21389*height))
        path.addLine(to: CGPoint(x: 0.90342*width, y: 0.3627*height))
        path.addCurve(to: CGPoint(x: 0.90595*width, y: 0.377*height), control1: CGPoint(x: 0.90592*width, y: 0.36701*height), control2: CGPoint(x: 0.90682*width, y: 0.37208*height))
        path.addCurve(to: CGPoint(x: 0.89863*width, y: 0.38955*height), control1: CGPoint(x: 0.90507*width, y: 0.38192*height), control2: CGPoint(x: 0.90248*width, y: 0.38637*height))
        path.addLine(to: CGPoint(x: 0.824*width, y: 0.44815*height))
        path.addCurve(to: CGPoint(x: 0.8146*width, y: 0.46039*height), control1: CGPoint(x: 0.8199*width, y: 0.45138*height), control2: CGPoint(x: 0.81666*width, y: 0.45559*height))
        path.addCurve(to: CGPoint(x: 0.81218*width, y: 0.47565*height), control1: CGPoint(x: 0.81253*width, y: 0.4652*height), control2: CGPoint(x: 0.8117*width, y: 0.47044*height))
        path.addCurve(to: CGPoint(x: 0.81326*width, y: 0.5*height), control1: CGPoint(x: 0.81283*width, y: 0.48373*height), control2: CGPoint(x: 0.81326*width, y: 0.49185*height))
        path.closeSubpath()
        return path
    }
}

struct MyLogo: View {
    var body: some View {
        ZStack {
            // Base orange rectangle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 1, green: 0.68, blue: 0.35))
                .frame(width: 44, height: 18)
                .rotationEffect(Angle(degrees: -10))

            // Green overlapping rectangle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.3, green: 0.82, blue: 0.5))
                .frame(width: 44, height: 18)
                .rotationEffect(Angle(degrees: -10))
                .offset(x: 4, y: -4)

            Text("Wpay")
                .font(Font.custom("DM Sans", size: 12).weight(.bold))
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: -10))
                .offset(x: 4, y: -4)
        }
    }
}
