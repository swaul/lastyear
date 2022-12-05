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
    let firestorePublic = Firestore.firestore().collection("public")
    let firestoreFriends = Firestore.firestore().collection("friends")
    
    
    public func registerUser(email: String, password: String, userName: String, appTracking: Bool, completion: ((Result<LYUser, FirebaseError>) -> Void)?) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion?(.failure(.error(error: error)))
            } else {
                guard let user = authResult?.user else {
                    completion?(.failure(.genericError()))
                    return
                }
                Analytics.setUserID(user.uid)
                Analytics.setConsent([.analyticsStorage: appTracking ? .granted : .denied])
                
                self?.saveUser(user: LYUser(user: user, userName: userName, appTracking: appTracking, friends: [], friendRequests: [], sharedLastYear: nil), completion: { result in
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
                        Analytics.setAnalyticsCollectionEnabled(lyUser.appTracking)
                        completion?(.success(user))
                    }
                }
            }
        }
    }
    
    public func logout(completion: ((Result<Void, FirebaseError>) -> Void)?) {
        do {
            try Auth.auth().signOut()
            completion?(.success(()))
        } catch let error {
            print("Oh oh")
            completion?(.failure(.error(error: error)))
        }
    }
    
    public func saveUser(user: LYUser, completion: ((Result<LYUser, FirebaseError>) -> Void)?) {
        firestoreUsers.document(user.id).setData(user.toData()) { error in
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
    
    public func getUsers(by ids: [String], completion: ((Result<[LYUser], FirebaseError>) -> Void)?) {
        firestoreUsers.whereField("id", in: ids).getDocuments { response, error in
            if let error = error {
                print("[LOG] - saving user failed with error", error)
                completion?(.failure(FirebaseError.error(error: error)))
            } else {
                let users = response?.documents.compactMap { LYUser(data: $0.data()) }
                guard let users = users else {
                    completion?(.failure(.genericError()))
                    return
                }
                completion?(.success(users))
            }
        }
    }
    
    public func checkForName(id: String, completion: ((Result<LYUser, FirebaseError>) -> Void)?) {
        firestoreUsers.whereField("userName", in: [id]).getDocuments { response, error in
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
    
    public func sendFriendRequest(to user: String, from sender: String, completion: ((Result<Void, FirebaseError>) -> Void)?) {
        firestoreUsers.document(user).updateData([
            "friendRequests": FieldValue.arrayUnion([sender])
        ]) { error in
            if let error {
                completion?(.failure(FirebaseError.error(error: error)))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    public func acceptRequest(from user: String, by receiver: String, completion: ((Result<Void, FirebaseError>) -> Void)?) {
        firestoreUsers.document(receiver).updateData([
            "friends": FieldValue.arrayUnion([user]),
            "friendRequests": FieldValue.arrayRemove([user])
        ]) { error in
            if let error {
                completion?(.failure(FirebaseError.error(error: error)))
            } else {
                self.firestoreUsers.document(user).updateData([
                    "friends": FieldValue.arrayUnion([receiver])
                ]) { error in
                    if let error {
                        completion?(.failure(FirebaseError.error(error: error)))
                    } else {
                        completion?(.success(()))
                    }
                }
            }
        }
    }
    
    public func denyRequest(from user: String, by receiver: String, completion: ((Result<Void, FirebaseError>) -> Void)?) {
        firestoreUsers.document(receiver).updateData([
            "friendRequests": FieldValue.arrayRemove([user])
        ]) { error in
            if let error {
                completion?(.failure(FirebaseError.error(error: error)))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    public func subscribeToFriends(from user: String, completion: ((Result<LYUser, FirebaseError>) -> Void)?) {
        firestoreUsers.document(user)
            .addSnapshotListener { snapshot, error in
                guard let document = snapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let user = LYUser(data: document.data() ?? [:]) else {
                    print("Document data was empty.")
                    return
                }
                completion?(.success(user))
            }
    }
    
    public func shareMemory(to: Collection, discovery: DiscoveryUpload, completion: ((Result<Void, FirebaseError>) -> Void)?) {
        to.getCollection().document(discovery.id).setData(discovery.toData()) { error in
            if let error {
                completion?(.failure(FirebaseError.error(error: error)))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    public func changeReaction(id: String, selfId: String, user: String, reaction: String, remove: Bool, completion: ((Result<Void, FirebaseError>) -> Void)?) {
        firestorePublic.document(user).updateData(
            [
                "reactions" : remove ? FieldValue.arrayRemove(
                    [
                        Reaction(id: id, reaction: reaction, user: selfId).toData()
                    ]
                ) : FieldValue.arrayUnion(
                    [
                        Reaction(id: id, reaction: reaction, user: selfId).toData()
                    ]
                )
            ]
        ) { error in
            if let error {
                completion?(.failure(FirebaseError.error(error: error)))
            } else {
                completion?(.success(()))
            }
        }
        
    }
    
    public func removeMemory(user: String, completion: ((Result<Void, FirebaseError>) -> Void)?) {
        firestoreUsers.document(user).updateData([
            "sharedLastYear": ""
        ]) { error in
            if let error {
                completion?(.failure(FirebaseError.error(error: error)))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    public func checkField(id: String, name: String, completion: ((Result<[LYUser], FirebaseError>) -> Void)?) {
        firestoreUsers.whereField(id, in: [name]).getDocuments { snapshot, error in
            if let error {
                completion?(.failure(.error(error: error)))
            } else {
                let users = snapshot?.documents.compactMap { LYUser(data: $0.data()) }
                guard let users = users else {
                    completion?(.failure(.genericError()))
                    return
                }
                completion?(.success(users))
            }
        }
    }
    
    public func changeLike(selfId: String, user: String, remove: Bool, completion: ((Result<Void, FirebaseError>) -> Void)?) {
        firestorePublic.document(user).updateData([
            "likes": remove ? FieldValue.arrayRemove([selfId]) : FieldValue.arrayUnion([selfId])
        ]) { error in
            if let error {
                completion?(.failure(FirebaseError.error(error: error)))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    public func changeUserTracking(to granted: Bool) {
        guard let user = Auth.auth().currentUser else { return }
        Analytics.setUserID(user.uid)
        Analytics.setConsent([.analyticsStorage: granted ? .granted : .denied])
        Analytics.setAnalyticsCollectionEnabled(granted)
    }
    
    var nextDiscovery: Query? = nil
    
    public func getDiscoveries(empty: Bool, completion: ((Result<[DiscoveryUpload], FirebaseError>) -> Void)?) {
        var first: Query
        
        if let next = nextDiscovery, !empty {
            first = next
        } else {
            first = firestorePublic
                .limit(to: 10)
                .order(by: "timePosted", descending: true)
        }
        
        first.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retreving cities: \(error.debugDescription)")
                return
            }
                        
            let discoveries = snapshot.documents.map { DiscoveryUpload(data: $0.data()) }
            
            guard let lastSnapshot = snapshot.documents.last else {
                completion?(.failure(FirebaseError.empty()))
                return
            }
            
            self.nextDiscovery = self.firestorePublic
                .order(by: "timePosted", descending: true)
                .limit(to: 10)
                .start(afterDocument: lastSnapshot)
            
            print("Found: \(discoveries.count) discoveries")
            
            completion?(.success(discoveries))
            
        }
        
    }
    
    public func getNextDiscoveries(completion: ((Result<[DiscoveryUpload], FirebaseError>) -> Void)?) {
        var first: Query
        
        if let next = nextDiscovery {
            first = next
        } else {
            first = firestorePublic
                .limit(to: 10)
                .order(by: "timePosted", descending: true)
        }
        
        first.getDocuments() { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retreving cities: \(error.debugDescription)")
                return
            }
            
            let discoveries = snapshot.documents.map { DiscoveryUpload(data: $0.data()) }
            
            guard let lastSnapshot = snapshot.documents.last else {
                completion?(.failure(FirebaseError.empty()))
                return
            }
            
            print(lastSnapshot.data())
            // Construct a new query starting after this document,
            // retrieving the next 25 cities.
            self.nextDiscovery = self.firestorePublic
                .order(by: "timePosted", descending: true)
                .limit(to: 10)
                .start(afterDocument: lastSnapshot)
            
            // Use the query for pagination.
            // ...
            completion?(.success(discoveries))
        }
    }
    
    var nextFriendsMemory: Query? = nil
    
    public func getFriendsMemories(ids: [String], empty: Bool, completion: ((Result<[DiscoveryUpload], FirebaseError>) -> Void)?) {
        var first: Query
        
        if let next = nextFriendsMemory, !empty {
            first = next
        } else {
            first = firestoreFriends
                .whereField("id", in: ids)
                .limit(to: 10)
        }
        
        guard !ids.isEmpty else {
            completion?(.failure(FirebaseError.empty()))
            return
        }
        
        first.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retreving cities: \(error.debugDescription)")
                return
            }
            
            let discoveries = snapshot.documents.map { DiscoveryUpload(data: $0.data()) }
            
            guard let lastSnapshot = snapshot.documents.last else {
                completion?(.failure(FirebaseError.empty()))
                return
            }
            
            // Construct a new query starting after this document,
            // retrieving the next 25 cities.
            self.nextFriendsMemory = self.firestoreFriends
                .whereField("id", in: ids)
                .limit(to: 10)
                .start(afterDocument: lastSnapshot)
            
            // Use the query for pagination.
            // ...
            completion?(.success(discoveries))
            
        }
    }
    
    public func getNextMemories(ids: [String], completion: ((Result<[DiscoveryUpload], FirebaseError>) -> Void)?) {
        var first: Query
        
        if let next = nextFriendsMemory {
            first = next
        } else {
            first = firestoreFriends
                .whereField("id", in: ids)
                .limit(to: 10)
        }
        
        guard !ids.isEmpty else {
            completion?(.failure(FirebaseError.empty()))
            return
        }
        
        first.whereField("id", in: ids).getDocuments() { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retreving cities: \(error.debugDescription)")
                return
            }
            
            let discoveries = snapshot.documents.map { DiscoveryUpload(data: $0.data()) }
            
            guard let lastSnapshot = snapshot.documents.last else {
                completion?(.failure(FirebaseError.empty()))
                return
            }
            
            print(lastSnapshot.data())
            
            self.nextFriendsMemory = self.firestoreFriends
                .whereField("id", in: ids)
                .start(afterDocument: lastSnapshot)
                .limit(to: 10)
            
            completion?(.success(discoveries))
        }
    }
}

public class FirebaseError: Error {
    
    let description: String?
    
    init(description: String? = nil) {
        self.description = description
    }
    
    static func error(error: Error) -> FirebaseError {
        return FirebaseError(description: error.localizedDescription)
    }
    
    static func genericError() -> FirebaseError {
        return FirebaseError()
    }
    
    static func empty() -> FirebaseError {
        return FirebaseError()
    }
}

public enum Collection {
    
    case _public
    case friends
    
    func getCollection() -> CollectionReference {
        switch self {
        case ._public:
            return Firestore.firestore().collection("public")
        case .friends:
            return Firestore.firestore().collection("friends")
        }
    }
}
