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
    
    let entityName = "Articles"
    let keyName = "article"
    
    func getData() -> [ArticleModel] {
        
        guard let context else {
            print("context nil")
            return []
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: entityName)
        if let datas = try? context.fetch(fetchRequest).first?.value(forKey: keyName) as? [String] {
            
            return datas
                .compactMap { $0.toArticleModel() }
        }
        
        return []
    }
    
    func setData(articles: [ArticleModel]) {
        
        guard let context else {
            print("context nil")
            return
        }
        
        deleteData()
        
        var datas: [String] = []
        articles
            .compactMap({ $0.toString() })
            .forEach { datas.append($0) }
        
        print(datas)
        
        if let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) {
            
            let articles = NSManagedObject(entity: entity, insertInto: context)
            articles.setValue(datas, forKey: keyName)
            
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
                // 저장 실패시 되돌리기
                context.undo()
            }
        }
    }
    
    func deleteData() {
        
        guard let context else {
            print("context nil")
            return
        }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(delete)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
    
