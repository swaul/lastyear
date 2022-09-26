//
//  FIrebasehandler.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics

public class FirebaseHandler {
    
    public static var shared = FirebaseHandler()
    
    let firestoreUsers = Firestore.firestore().collection("users")
    
    public func registerUser(email: String, password: String, userName: String, completion: ((Result<LYUser, FirebaseError>) -> Void)?) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion?(.failure(.error(error: error)))
            } else {
                guard let user = authResult?.user else {
                    completion?(.failure(.genericError()))
                    return
                }
                self?.saveUser(user: LYUser(user: user, userName: userName), completion: { result in
                    switch result {
                    case .failure(let error):
                        completion?(.failure(error))
                    case .success(let user):
                        AuthService.shared.logIn(user: user)
                        Analytics.logEvent(AnalyticsEventLogin, parameters: [:])
                        completion?(.success(user))
                    }
                })
            }
        }
    }
    
    public func loginUser(email: String, password: String, completion: ((Result<FirebaseAuth.User, FirebaseError>) -> Void)?) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion?(.failure(.error(error: error)))
            } else {
                guard let user = authResult?.user else {
                    completion?(.failure(.genericError()))
                    return
                }
                self?.getUser(by: user.uid) { result in
                    switch result {
                    case .failure(let error):
                        completion?(.failure(.error(error: error)))
                    case .success(let lyUser):
                        AuthService.shared.logIn(user: lyUser)
                        completion?(.success(user))
                    }
                }
            }
        }
    }
    
    public func logout() {
        do {
            try Auth.auth().signOut()
            AuthService.shared.logOut()

        } catch {
            print("Oh oh")
        }
    }
    
    public func saveUser(user: LYUser, completion: ((Result<LYUser, FirebaseError>) -> Void)?) {
        firestoreUsers.addDocument(data: user.toData()) { error in
            if let error = error {
                print("[LOG] - saving user failed with error", error)
                completion?(.failure(FirebaseError.error(error: error)))
            } else {
                completion?(.success(user))
            }
        }
    }
    
    public func getUser(by id: String, completion: ((Result<LYUser, FirebaseError>) -> Void)?) {
        firestoreUsers.whereField("id", in: [id]).getDocuments { response, error in
            if let error = error {
                print("[LOG] - saving user failed with error", error)
                completion?(.failure(FirebaseError.error(error: error)))
            } else {
                let users = response?.documents.map { LYUser(data: $0.data()) }
                guard let users = users, let user = users.first else {
                    completion?(.failure(.genericError()))
                    return
                }
                completion?(.success(user!))
            }
        }
    }
    
}

public class FirebaseError: Error {
    
    static func error(error: Error) -> FirebaseError {
        return FirebaseError()
    }
    
    static func genericError() -> FirebaseError {
        return FirebaseError()
    }
    
}
