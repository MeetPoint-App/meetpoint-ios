//
//  StorageManager.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 4.03.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import FirebaseStorage

class StorageManager {
    
    static let sharedManager = StorageManager()
    
    let storage: Storage
    
    // MARK: - Constructors
    
    init() {
        storage = Storage.storage()
    }
    
    // MARK: - Functions
    
    func uploadProfileImage(_ image: UIImage, uid: String, completion: @escaping(_ url: String?, _ error: Error?) -> Void) {
        guard let data = UIImageJPEGRepresentation(image, 0.7) else {
            
            completion(nil, NSError.inlineErrorWithErrorCode(code: ErrorCode.unknownError))
            
            return
        }
        
        self.storage.reference().child("ProfileImages").child(uid).child(UUID.init().uuidString).putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                
                completion(nil, error)
                
                return
            }
            
            guard let url = metadata?.downloadURL() else {
                return
            }
            
            completion(url.absoluteString, nil)
        }
    }
    
    func uploadCoverPhoto(_ image: UIImage, completion: @escaping (_ urlString: String?, _ error: Error?) -> Void) {
        guard let data = UIImageJPEGRepresentation(image, 0.7) else {
            
            completion(nil, NSError.inlineErrorWithErrorCode(code: ErrorCode.unknownError))
            
            return
        }
        
         self.storage.reference().child("ActivityCoverImages").child(UUID.init().uuidString).putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                
                completion(nil, error)
                
                return
            }
            
            let urlString = metadata?.downloadURL()?.absoluteString
            
            completion(urlString, nil)
        }
    }
}
