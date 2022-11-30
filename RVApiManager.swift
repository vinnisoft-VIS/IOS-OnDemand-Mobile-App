//
//  RVApiManager.swift
//  ManagerDemo
//
//  Created by Appdeft on 6/7/2021.
//  Copyright © 2021 Rajat. All rights reserved.
//
import Foundation
import Alamofire
import KRProgressHUD
import KRActivityIndicatorView
import Photos
import GoogleSignIn

typealias RvCompletionHandler = ((_ result: Any?,_ Error: Error?) -> Void)?

//Base Url
let serverBaseURL = "http://vrsidekick.appdeft.biz"
let googleAPIKey = "AIzaSyAKm1TZqNPKTLkzpu3wiap_efWcd2LLOXE"
let stripePublishableKey = "pk_test_51LLhGdSElgx5kdPjsUMMZWHizkpQNYlkaipgWjJj4U2wwzBVG5WVZ6DsdQBWou5ZaUWbuVSFlUxLkkzjHz8A45VS00wuRfXBOQ"
let kakaoLocalApiKey = "KakaoAK 2d7c9c8c9a403b7b28eead5e68aaadd9"
let googleSignInConfig = GIDConfiguration.init(clientID: "883364823798-eu9osm13h95llha2s9ttik17v6q26otl.apps.googleusercontent.com")

struct Apis{
    static let sendOTP = "api/send-otp"
    static let register = "api/register"
    static let login = "api/login"
    static let forgotPassword = "api/forgot-password"
    static let socialLogin = "api/social-login"
    static let userType = "api/add-type"
    static let categories = "api/category"
    static let searchCategories = "api/category-search"
    static let providers = "api/get-providers"
    static let favourites = "api/fav-providers"
    static let favToggleProvider = "api/fav-unfav-provider"
    static let postService = "api/add-provider-service"
    static let addProperty = "api/add-property"
    static let logout = "api/logout"
    static let properties = "api/properties"
    static let profile = "api/profile"
    static let editProfile = "api/edit-profile"
    static let filter = "api/filter"
    static let propertyDetail = "api/property-detail"
    static let changePassword = "api/change-password"
    static let providerDetail = "api/provider-detail"
    static let searchProvider = "api/search"
    static let myProperties   = "api/my-properties"
    static let deleteProperty = "api/delete-property"
    static let editProperty   = "api/edit-property"
    static let providerAvailability = "api/provider-availability"
    static let bookProvider = "api/book-provider"
    static let bookedProperties = "api/provider-bookings"
    static let bookedPropertyDetail = "api/booked-property-detail"
    static let workDone = "api/provider-work-done"
    static let getMySidekicks = "api/my-sidekicks"
    static let getSidekickDetail = "api/sidekick-detail"
    static let cancelBooking = "api/cancel-booking"
    static let propertySidekickDetails = "api/property-sidekick"
    static let reporting = "api/reporting"
    static let giveRating = "api/provider-rating"
    static let reviews = "api/reviews"
    static let postAd = "api/post-ad"
    static let confirmRate = "api/provider-work-start"
    static let approveRate = "api/approved-rate"
    static let addCard = "api/card"
    static let cards = "api/card"
    static let deleteCard = "api/delete-card"
    static let myServices = "api/my-services"
    static let deleteService = "api/delete-service"
    static let editService = "api/edit-service"
    static let addBankAccount = "api/add-bank-account"
    static let bankAccounts = "api/bank-accounts-list"
    static let acceptBooking = "api/accept-booking-request"
    static let rejectBooking = "api/rejected-booking-request"
    static let pendingRequests = "api/queue-bookings"
    static let rescheduleBooking = "api/reschedule-booking"
    static let completedBookings = "api/complete-bookings"

}

class RVApiManager: NSObject {
    static let shared = RVApiManager()
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }

}


extension RVApiManager {
    
    fileprivate func printAPI_Before(strURL:String = "", parameters:[String:Any] = [:], headers: HTTPHeaders = [:])
    
    {
        var str = "\(parameters)"
        str = str.replacingOccurrences(of: " = ", with: ":")
        str = str.replacingOccurrences(of: "\"", with: "")
        str = str.replacingOccurrences(of: ";", with: "")
        print("APi - \(strURL)\nParameters - \(str)\nHeaders - \(headers)")
    }
    
    fileprivate func printAPI_After(response :AFDataResponse<Any>)
    {
        if let value = response.value
        {
            print("result.value: \(value)") // result of response serialization
        }
        if let error = response.error
        {
            print("result.error: \(error)") // result of response serialization
        }
    }
    
    fileprivate func hitApi(_ apiUrl: String = "",
                            type: HTTPMethod = .post,
                            parameter: [String:Any] = [:],
                            completionHandler : RvCompletionHandler
    ) {
        var strUrl : String = serverBaseURL
        if apiUrl.contains("http") {
            strUrl = ""
        }
        if !strUrl.isEmpty && !apiUrl.isEmpty {
            strUrl.append("/")
        }
        strUrl.append(apiUrl)
        
        var headers : HTTPHeaders = [:]
        let token = AppConstant.token
        if !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
            headers["X-Requested-With"] = "XMLHttpRequest"
        }
        //        headers["lang"] = Constant.language
        //        headers["gender"] = Constant.gender
        RVApiManager.shared.printAPI_Before(strURL: strUrl, parameters: parameter, headers: headers)
        let api = AF.request(strUrl, method: type, parameters: parameter, encoding: JSONEncoding.default, headers: headers)
        
        api.responseJSON { (responce) in
            if let statusCode = responce.response?.statusCode{
                if statusCode == 401{
                    RVApiManager.shared.exitOnUnauthorisedToken()
                }
            }
            RVApiManager.shared.printAPI_After(response: responce)
            if let JSON = responce.data, JSON.count > 0 {
                completionHandler!(JSON, nil)
            }
            else if let Error = responce.error {
                completionHandler!(nil,Error as Error )
            }
            else {
                completionHandler!(nil , NSError(domain: "error", code: 117, userInfo: nil))
            }
        }
    }
    
    fileprivate func upLoadApi(_ apiUrl: String = "",
                               uploadObjects: [MultipartObject]?,
                               type: HTTPMethod = .post,
                               parameter : [String: Any] = [:],
                               completionHandler: RvCompletionHandler
    ) {
        var strUrl : String = serverBaseURL
        if apiUrl.contains("http") {
            strUrl = ""
        }
        if !strUrl.isEmpty && !apiUrl.isEmpty {
            strUrl.append("/")
        }
        strUrl.append(apiUrl)
        
        var headers : HTTPHeaders = [:]
        let token = AppConstant.token
        if !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
            headers["X-Requested-With"] = "XMLHttpRequest"
        }
        RVApiManager.shared.printAPI_Before(strURL: strUrl, parameters: parameter, headers: headers)
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameter {
                if let d = value as? [String : Any] {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: d, options: .prettyPrinted)
                        multipartFormData.append(data, withName: key)
                    } catch {
                        
                    }
                } else {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
            }
            
            if uploadObjects?.count ?? 0 > 0{
                for data in uploadObjects! {
                    multipartFormData.append(data.dataObj, withName: data.strName, fileName: data.strFileName, mimeType: data.strMimeType)
                }
            }
            
        }, to: strUrl, method: type, headers: headers)
            .responseJSON { response in
                debugPrint(response)
                
                print("Succesfully Updated")
                if let statusCode = response.response?.statusCode{
                    if statusCode == 401{
                        RVApiManager.shared.exitOnUnauthorisedToken()
                    }
                }
                RVApiManager.shared.printAPI_After(response: response)
                
                if let JSON = response.data, JSON.count > 0 {
                    completionHandler!(JSON, nil)
                }
                else if let Error = response.error {
                    completionHandler!(nil,Error as Error )
                }
                else {
                    completionHandler!(nil , NSError(domain: "error", code: 117, userInfo: nil))
                }
            }
    }
}

extension RVApiManager {
    
    class func getAPI <T: Decodable>(_ apiUrl: String = "", parameters : [String:Any] = [:], Vc: UIViewController, showLoader : Bool = true, completionHandler : @escaping (T)->()) {
        if RVApiManager.isConnectedToInternet {
            if showLoader {
                Indicator.shared.start()
            }
            var strUrl : String = serverBaseURL
            if apiUrl.contains("http") {
                strUrl = ""
            }
            if !strUrl.isEmpty && !apiUrl.isEmpty {
                strUrl.append("/")
            }
            strUrl.append(apiUrl)
            var headers : HTTPHeaders = [:] // ["Content-Type" : "application/x-www-form-urlencoded"]
            let token = AppConstant.token
            if !token.isEmpty {
                headers["Authorization"] = "Bearer \(token)"
                headers["X-Requested-With"] = "XMLHttpRequest"
            }
            RVApiManager.shared.printAPI_Before(strURL: strUrl, parameters: parameters, headers : headers)
            let api = AF.request(strUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            
            api.responseJSON { (responce) in
                if showLoader {
                    Indicator.shared.stop()
                }
                
                if let statusCode = responce.response?.statusCode{
                    if statusCode == 401{
                        RVApiManager.shared.exitOnUnauthorisedToken()
                    }
                }
                
                RVApiManager.shared.printAPI_After(response: responce)
                if let JSON = responce.data, JSON.count > 0 {
                    do {
                        let obj = try JSONDecoder().decode(T.self, from: JSON)
                        completionHandler(obj)
                    }
                    catch let jsonError {
                        print("failed to download data", jsonError)
                    }
                }
                else if let Error = responce.error {
                    Vc.showAlert(message: Error.localizedDescription, title: "Error")
                    
                }
                else {
                }
            }
        }
        else {
            Vc.showAlert(message: "No Internet Connected", title: "Error")
        }
    }

    class func getAPIWithoutVC <T: Decodable>(_ apiUrl: String = "", parameters : [String:Any] = [:], showLoader : Bool = true, completionHandler : @escaping (T)->()) {
        if RVApiManager.isConnectedToInternet {
            if showLoader {
                Indicator.shared.start()
            }
            var strUrl : String = serverBaseURL
            if apiUrl.contains("http") {
                strUrl = ""
            }
            if !strUrl.isEmpty && !apiUrl.isEmpty {
                strUrl.append("/")
            }
            strUrl.append(apiUrl)
            var headers : HTTPHeaders = [:] // ["Content-Type" : "application/x-www-form-urlencoded"]
            let token = AppConstant.token
            if !token.isEmpty {
                headers["Authorization"] = token
            }
            RVApiManager.shared.printAPI_Before(strURL: strUrl, parameters: parameters, headers : headers)
            let api = AF.request(strUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            api.responseJSON { (responce) in
                if showLoader {
                    Indicator.shared.stop()
                }
                if let statusCode = responce.response?.statusCode{
                    if statusCode == 401{
                        RVApiManager.shared.exitOnUnauthorisedToken()
                    }
                }
                RVApiManager.shared.printAPI_After(response: responce)
                if let JSON = responce.data, JSON.count > 0 {
                    do {
                        let obj = try JSONDecoder().decode(T.self, from: JSON)
                        completionHandler(obj)
                    }
                    catch let jsonError {
                        print("failed to download data", jsonError)
                    }
                }
                else {
                    print("")
                }
            }
        }
        else {
            print("")
        }
    }
    
    class func postApiWithImages<T : Decodable >(_ apiUrl: String = "", image: [UIImage?], imageName: [String],Vc: UIViewController, parameters : [String: Any] = [:],isAnimating : Bool = true, completion : @escaping (T) -> Void) {
        if RVApiManager.isConnectedToInternet {
            if isAnimating {
                Indicator.shared.start()
            }
            var obj : [MultipartObject]?
            for i in 0..<imageName.count {
                let data: Data = (image[i]?.jpegData(compressionQuality: 0.5)!)!//UIImageJPEGRepresentation(image, 0.5)!
                let name = Int(Date().timeIntervalSince1970)
                
                let uploadData = MultipartObject(data: data, name: imageName[i], fileName: "\(name).jpg", mimeType: "image/jpg")
                if i == 0 {
                    obj = [uploadData]
                } else {
                    obj?.append(uploadData)
                }
            }
            
            RVApiManager.shared.upLoadApi(apiUrl, uploadObjects: obj, parameter: parameters) { (result, error) in
                if isAnimating {
                    Indicator.shared.stop()
                }
                guard error == nil else {
                    
                    Vc.showAlert(message: (error?.localizedDescription)!, title: "Error")
                    return }
                guard let data = result else {return}
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data as! Data)
                    completion(obj)
                }
                catch let jsonError {
                    print("failed to dowload data", jsonError)
                    Vc.showAlert(message: jsonError.localizedDescription, title: "Error")
                }
            }
        }
        else {
            Vc.showAlert(message: "No Internet Connected", title: "Error")
        }
    }
    
    class func postAPI <T: Decodable>(_ apiUrl: String = "", parameters : [String:Any] = [:], Vc: UIViewController, showLoader : Bool = true, completionHandler : @escaping (T)->()) {
        if RVApiManager.isConnectedToInternet {
            if showLoader {
                Indicator.shared.start()
            }
            RVApiManager.shared.hitApi(apiUrl, type: .post, parameter: parameters) { (result, error) in
                if showLoader {
                    Indicator.shared.stop()
                }
                guard error == nil else {
                    if showLoader {
                        Indicator.shared.stop()
                    }
                    return}
                guard let data = result else {return}
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data as! Data)
                    completionHandler(obj)
                }
                catch let jsonError  {
                    print("failed to download data", jsonError)
                }
            }
        }
        else {
            Vc.showAlert(message: "No Internet Connected", title: "Error")
        }
    }
    class func deleteAPI <T: Decodable>(_ apiUrl: String = "", parameters : [String:Any] = [:], Vc: UIViewController, showLoader : Bool = true, completionHandler : @escaping (T)->()) {
        if RVApiManager.isConnectedToInternet {
            if showLoader {
                Indicator.shared.start()
            }
            RVApiManager.shared.hitApi(apiUrl, type: .delete, parameter: parameters) { (result, error) in
                if showLoader {
                    Indicator.shared.stop()
                }
                guard error == nil else {
                    if showLoader {
                        Indicator.shared.stop()
                    }
                    return}
                guard let data = result else {return}
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data as! Data)
                    completionHandler(obj)
                }
                catch let jsonError  {
                    print("failed to download data", jsonError)
                }
            }
        }
        else {
            Vc.showAlert(message: "No Internet Connected", title: "Error")
        }
    }
    
    
    
    class func postAPIInAppDelegate <T: Decodable>(_ apiUrl: String = "", parameters : [String:Any] = [:], showLoader : Bool = true, completionHandler : @escaping (T)->()) {
        if RVApiManager.isConnectedToInternet {
            if showLoader {
                Indicator.shared.start()
            }
            RVApiManager.shared.hitApi(apiUrl, type: .post, parameter: parameters) { (result, error) in
                if showLoader {
                    Indicator.shared.stop()
                }
                guard error == nil else {
                    if showLoader {
                        Indicator.shared.stop()
                    }
                    return}
                guard let data = result else {return}
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data as! Data)
                    completionHandler(obj)
                }
                catch let jsonError  {
                    print("failed to download data", jsonError)
                }
            }
        }
        else {
            print("No Internet Connection")
        }
    }
    
    
    
    
    class func putAPI <T: Decodable>(_ apiUrl: String = "", parameters : [String:Any] = [:], Vc: UIViewController, showLoader : Bool = true, completionHandler : @escaping (T)->()) {
        if RVApiManager.isConnectedToInternet {
            if showLoader {
                Indicator.shared.start()
            }
            RVApiManager.shared.hitApi(apiUrl, type: .put, parameter: parameters) { (result, error) in
                if showLoader {
                    Indicator.shared.stop()
                }
                guard error == nil else {
                    if showLoader {
                        Indicator.shared.stop()
                    }
                    return
                }
                guard let data = result else {return}
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data as! Data)
                    completionHandler(obj)
                }
                catch let jsonError  {
                    print("failed to download data", jsonError)
                }
            }
        }
        else {
            Vc.showAlert(message: "No Internet Connected", title: "Error")
        }
    }
    
    class func putAPIWithoutVC <T: Decodable>(_ apiUrl: String = "", parameters : [String:Any] = [:], showLoader : Bool = true, completionHandler : @escaping (T)->()) {
        if RVApiManager.isConnectedToInternet {
            if showLoader {
                Indicator.shared.start()
            }
            RVApiManager.shared.hitApi(apiUrl, type: .put, parameter: parameters) { (result, error) in
                if showLoader {
                    Indicator.shared.stop()
                }
                guard error == nil else {
                    if showLoader {
                        Indicator.shared.stop()
                    }
                    return}
                guard let data = result else {return}
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data as! Data)
                    completionHandler(obj)
                }
                catch let jsonError  {
                    print("failed to download data", jsonError)
                }
            }
        }
        else {
            print("")
        }
    }
    
    class func postApiWithImage<T : Decodable >(_ apiUrl: String = "", image: UIImage, imageName: String,Vc: UIViewController, parameters : [String: Any] = [:],isAnimating : Bool = true, completion : @escaping (T) -> Void) {
        if RVApiManager.isConnectedToInternet {
            if isAnimating {
                Indicator.shared.start()
            }
            let data: Data = image.jpegData(compressionQuality: 0.5)!//UIImageJPEGRepresentation(image, 0.5)!
            let name = Int(Date().timeIntervalSince1970)
            let uploadData = MultipartObject(data: data, name: imageName, fileName: "\(name).jpg", mimeType: "image/jpg")
            RVApiManager.shared.upLoadApi(apiUrl, uploadObjects: [uploadData], parameter: parameters) { (result, error) in
                if isAnimating {
                    Indicator.shared.stop()
                }
                guard error == nil else {
                    Vc.showAlert(message: (error?.localizedDescription)!, title: "Error")
                    return }
                guard let data = result else {return}
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data as! Data)
                    completion(obj)
                }
                catch let jsonError {
                    print("failed to dowload data", jsonError)
                    Vc.showAlert(message: jsonError.localizedDescription, title: "Error")
                }
            }
        }
        else {
            Vc.showAlert(message: "No Internet Connected", title: "Error")
        }
    }
    
    class func putApiWithImage<T : Decodable >(_ apiUrl: String = "", image: UIImage, imageName: String,Vc: UIViewController, parameters : [String: Any] = [:],isAnimating : Bool = true, completion : @escaping (T) -> Void) {
        if RVApiManager.isConnectedToInternet {
            if isAnimating {
                Indicator.shared.start()
            }
            let data: Data = image.jpegData(compressionQuality: 0.5)!//UIImageJPEGRepresentation(image, 0.5)!
            let name = Int(Date().timeIntervalSince1970)
            let uploadData = MultipartObject(data: data, name: imageName, fileName: "\(name).jpg", mimeType: "image/jpg")
            RVApiManager.shared.upLoadApi(apiUrl, uploadObjects: [uploadData],type: .put, parameter: parameters) { (result, error) in
                if isAnimating {
                    Indicator.shared.stop()
                }
                guard error == nil else {
                    Vc.showAlert(message: (error?.localizedDescription)!, title: "Error")
                    return }
                guard let data = result else {return}
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data as! Data)
                    completion(obj)
                }
                catch let jsonError {
                    print("failed to dowload data", jsonError)
                    Vc.showAlert(message: jsonError.localizedDescription, title: "Error")
                }
            }
        }
        else {
            Vc.showAlert(message: "No Internet Connected", title: "Error")
        }
    }
    
    
    func postGifImage <T : Decodable>(_ apiUrl: String = "", GifData: Data, imageName: String,Vc: UIViewController, parameters : [String: Any] = [:], completion : @escaping(T)->Void) {
        if RVApiManager.isConnectedToInternet {
            Indicator.shared.start()
            let name = Int(Date().timeIntervalSince1970)
            let uploadData = MultipartObject(data: GifData, name: imageName, fileName: "\(name).gif", mimeType: "image/gif")
            RVApiManager.shared.upLoadApi(apiUrl, uploadObjects: [uploadData], parameter: parameters) { (result, error) in
                Indicator.shared.stop()
                guard error == nil else {
                    Vc.showAlert(message: (error?.localizedDescription)!, title: "Error")
                    return }
                guard let data = result else {return}
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data as! Data)
                    completion(obj)
                }
                catch let jsonError {
                    print("failed to dowload data", jsonError)
                    Vc.showAlert(message: jsonError as? String ?? "", title: "Error")
                }
            }
        }
        else {
            Vc.showAlert(message: "No Internet Connected", title: "Error")
        }
    }
    
    class func postApiWithVideo<T : Decodable > (_ apiUrl : String,imageData : UIImage? ,videoData : Data?, Vc : UIViewController, parameters : [String : Any], completion : @escaping (T) -> Void) {
        if RVApiManager.isConnectedToInternet {
            Indicator.shared.start()
            let name = Int(Date().timeIntervalSince1970)
            var uploadData:[MultipartObject] = []
            if let imageData = imageData!.jpegData(compressionQuality: 0.8), let data1 = videoData
            {
                uploadData = [
                    MultipartObject(data: imageData, name: "video_thumbnail", fileName: "thumbnail_image_\(name).png", mimeType: "mp4"),MultipartObject(data: data1, name: "my_video_upload", fileName: "video_\(name).mov", mimeType: "mov")
                ]
            }
            RVApiManager.shared.upLoadApi(apiUrl, uploadObjects: uploadData, parameter: parameters) { (result, error) in
                Indicator.shared.stop()
                guard error == nil else {
                    Vc.showAlert(message: (error?.localizedDescription)!, title: "Error")
                    return }
                guard let data = result else {return}
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data as! Data)
                    completion(obj)
                }
                catch let jsonError {
                    print("failed to dowload data", jsonError)
                    Vc.showAlert(message: jsonError as! String, title: "Error")
                }
            }
        }
        else {
            Vc.showAlert(message: "No Internet Connected", title: "Error")
        }
    }
    
    fileprivate func exitOnUnauthorisedToken(){
       let window = UIApplication.shared.connectedScenes
           .filter({$0.activationState == .foregroundActive})
           .compactMap({$0 as? UIWindowScene})
           .first?.windows
           .filter({$0.isKeyWindow}).first
       window?.rootViewController?.showAlert(message: AlertMessages.tokenExpired, title: "", handler: { ok in
           UserDefaults.standard.removeObject(forKey: keys.isAlreadyLogin)
           let story = UIStoryboard(name: "Auth", bundle:nil)
           let vc = story.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
           let nav = UINavigationController(rootViewController: vc)
           nav.navigationBar.isHidden = true
           UIApplication.shared.windows.first?.rootViewController = nav
           UIApplication.shared.windows.first?.makeKeyAndVisible()
       })
   }
}

// MARK: -   MultiPartObject Class
class MultipartObject : NSObject {
    var dataObj : Data! = nil
    var strName : String = ""
    var strFileName : String = ""
    var strMimeType : String = ""
    
    init(data: Data!, name: String!, fileName: String!, mimeType: String! ) {
        super.init()
        dataObj = data
        strName = name
        strFileName = fileName
        strMimeType = mimeType
    }
}


