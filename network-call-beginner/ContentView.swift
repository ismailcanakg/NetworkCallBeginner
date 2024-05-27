//
//  ContentView.swift
//  network-call-beginner
//
//  Created by İsmail Can Akgün on 14.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitHubUser? // MARK: - State Property for User
    
    var body: some View {
        VStack(spacing:20) {
            // MARK: - Avatar Image
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120,height: 120)
            
            // MARK: - User Login
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)
            
            // MARK: - User Bio
            Text(user?.bio ?? "Bio Placeholder")
                .padding()
            
            Spacer()
        }
        .padding()
        .task {
            // MARK: - Fetch User Data
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("invalid URL")
            }
            catch GHError.invalidResponse {
                print("invalid Response")
            }
            catch GHError.invalidData {
                print("invalid Data")
            }
            catch {
                print("unexpected error")
            }
        }
    }
    
    // MARK: - Network Request
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/ismailcanakg"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

// MARK: - Model
struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

// MARK: - Error Handling
enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
