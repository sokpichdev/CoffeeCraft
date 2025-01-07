//
//  View.swift
//  PaginationApp
//
//  Created by Sok Pich on 1/7/25.
//

import SwiftUI

struct UserView: View {
    //MARK: - PROPERTIES
    var user : User
    
    //MARK: - BODY
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            //Image
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80.0, height: 80.0, alignment: .center)
                .foregroundColor(.orange)
                .padding(.all, 20)
            
            VStack(alignment: .leading, spacing: 5, content: {
                HStack{
                    Text("First Name :")
                        .fontWeight(.semibold)
                    Text("\(user.firstName)")
                }
                
                HStack{
                    Text("Last Name :")
                        .fontWeight(.semibold)
                        .bold()
                    Text("\(user.lastName)")
                }
                
                HStack{
                    Text("Email :")
                        .fontWeight(.semibold)
                    Text("\(user.email)")
                }
                
            })
            .foregroundColor(.white)
        })
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .background(Color.black)
        .cornerRadius(10.0)
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}

//MARK: - PREVIEW
struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(id: 1, email: "apoorv487@gmail.com", firstName: "Apoorv", lastName: "Garg", avatar: URL(string: "https://avatar.com")!)
        UserView(user: user)
            .previewLayout(.fixed(width: 375.0, height: 100.0))
    }
}
