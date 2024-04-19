//
//  CoreDataManager.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/18.
//

import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext 
    
    let articleEntity = "Articles"
    let articleKey = "article"
    let imageEntity = "CacheImages"
    let imageKey = "image"
    let imageUrlKey = "url"
    
    // save context
    private func saveContext() {
        
        if let context {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
                // 저장 실패시 되돌리기
                context.undo()
            }
        }
    }
}
    
// MARK: - Api Data
extension CoreDataManager {
    
    func getData() -> [ArticleModel] {
        
        guard let context else {
            print("context nil")
            return []
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: articleEntity)
        if let datas = try? context.fetch(fetchRequest).first?.value(forKey: articleKey) as? [String] {
            
            return datas
                .compactMap { $0.toArticleModel() }
        }
        
        return []
    }
    
    func saveData(articles: [ArticleModel]) {
        
        guard let context else {
            print("context nil")
            return
        }
        
        deleteData()
        
        var datas: [String] = []
        articles
            .compactMap({ $0.toString() })
            .forEach { datas.append($0) }
        
        if let entity = NSEntityDescription.entity(forEntityName: articleEntity, in: context) {
            
            let articles = NSManagedObject(entity: entity, insertInto: context)
            articles.setValue(datas, forKey: articleKey)
            
            saveContext()
        }
    }
    
    private func deleteData() {
        
        guard let context else {
            print("context nil")
            return
        }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: articleEntity)
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(delete)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}


// MARK: - Cache Image
extension CoreDataManager {
    
    func getImage(url: String) -> UIImage? {
        
        guard let context else {
            print("context nil")
            return nil
        }
        
        do {
            let fetchRequest : NSFetchRequest<CacheImages> = CacheImages.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "\(imageUrlKey) == %@", url)
            
            let fetchedResults = try context.fetch(fetchRequest)
            if let cacheImage = fetchedResults.first, let data = cacheImage.image {
                return UIImage(data: data)
            }
        }
        catch {
            print ("fetch task failed", error)
        }
        
        return nil
    }
    
    func saveImage(url: String, image: UIImage) {
        
        guard let context else {
            print("context nil")
            return
        }
        
        guard let data = image.jpegData(compressionQuality: 1) else {
            print("image compressing error")
            return
        }
        
        if let entity = NSEntityDescription.entity(forEntityName: imageEntity, in: context) {
            
            let image = NSManagedObject(entity: entity, insertInto: context)
            image.setValue(data, forKey: imageKey)
            image.setValue(url, forKey: imageUrlKey)
            
            saveContext()
        }
    }
    
}
