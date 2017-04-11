
import CoreData

class CoreDataDbManager : AbstractDbManager {
    
    static let instance = CoreDataDbManager()
    
    var context: NSManagedObjectContext
    
    init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    //MARK: db manager implementation
    
    internal func retrieveDataFromDb() -> [UniversalDbModel] {
        do {
            let fetch: NSFetchRequest = ScheduleItem.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "fromDate", ascending: true)
            fetch.sortDescriptors = [sortDescriptor]
            return self.convertCoreDataList(coreDataList: try context.fetch(fetch))
        } catch let error as NSError {
            print("Data was not retrieved, error: \(error.localizedDescription)")
        }
        return []
    }
    
    internal func clearDb() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ScheduleItem")
        let result = try? context.fetch(fetchRequest)
        for object in result! {
            context.delete(object as! NSManagedObject)
        }
        let fetchRequestCity = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
        let resultCity = try? context.fetch(fetchRequestCity)
        for object in resultCity! {
            context.delete(object as! NSManagedObject)
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Database was not cleared, error: \(error)")
        }
    }
    
    internal func getItemById(id: String) -> UniversalDbModel? {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ScheduleItem")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let universalDataArray = self.convertCoreDataList(coreDataList: try context.fetch(fetchRequest) as! [ScheduleItem])
            return universalDataArray[0]
        } catch let error as NSError {
            print("Detailed obj was not loaded, error: \(error)")
        }
        return nil
    }
    
    internal func saveJsonArrayToDb(data: NSArray) {
        for dataItem in data {
            
            let tmpData = dataItem as! NSDictionary
            let fromCity = tmpData["from_city"] as! NSDictionary
            let toCity = tmpData["to_city"] as! NSDictionary
            
            do {
                
                var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ScheduleItem")
                fetchRequest.fetchLimit = 1
                var idStr = String(describing: tmpData["id"])
                fetchRequest.predicate = NSPredicate(format: "id == %@", idStr)
                
                let items = try context.fetch(fetchRequest) as! [ScheduleItem]
                
                if(items.count == 0) {
                    let newScheduleItem = NSEntityDescription.insertNewObject(forEntityName: "ScheduleItem", into: context)
                    
                    newScheduleItem.setValue(String(describing: tmpData["id"]) , forKey: "id")
                    newScheduleItem.setValue(tmpData["info"] as! String, forKey: "info")
                    newScheduleItem.setValue(tmpData["price"], forKey: "price")
                    newScheduleItem.setValue(DateConverter.convertStringToDate(string: tmpData["from_date"] as! String), forKey: "fromDate")
                    newScheduleItem.setValue(DateConverter.convertStringToDate(string: tmpData["to_date"] as! String), forKey: "toDate")
                    newScheduleItem.setValue(tmpData["from_info"], forKey: "fromInfo")
                    newScheduleItem.setValue(tmpData["to_info"], forKey: "toInfo")
                    
                    fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
                    idStr = String(describing: fromCity["name"])
                    fetchRequest.predicate = NSPredicate(format: "name == %@", idStr)
                    
                    let fromCities = try context.fetch(fetchRequest) as! [City]
                    
                    if(fromCities.count > 0) {
                        newScheduleItem.setValue(fromCities[0], forKey: "fromCity")
                    } else {
                        let newFromCity = NSEntityDescription.insertNewObject(forEntityName: "City", into: context)
                        newFromCity.setValue(fromCity["name"], forKey: "name")
                        newFromCity.setValue(fromCity["highlight"], forKey: "highlight")
                        newScheduleItem.setValue(newFromCity, forKey: "fromCity")
                    }
                    
                    fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
                    idStr = String(describing: toCity["name"])
                    fetchRequest.predicate = NSPredicate(format: "name == %@", idStr)
                    
                    let toCities = try context.fetch(fetchRequest) as! [City]
                    
                    if(toCities.count > 0) {
                        newScheduleItem.setValue(toCities[0], forKey: "toCity")
                    } else {
                        let newToCity = NSEntityDescription.insertNewObject(forEntityName: "City", into: context)
                        newToCity.setValue(toCity["name"], forKey: "name")
                        newToCity.setValue(toCity["highlight"], forKey: "highlight")
                        newScheduleItem.setValue(newToCity, forKey: "toCity")
                    }
                    
                    try context.save()
                } else {
                    print("\tData[\(tmpData["id"])] - already exist, info: \(items[0].info)")
                }
            } catch let error as NSError {
                print("\tData[\(tmpData["id"])] - NOT SAVED: \(error.localizedDescription); \n\t\t Full text error: \(error)")
            }
        }

    }
    
    
    //MARK: additional methods
    
    func convertCoreDataList(coreDataList: [ScheduleItem]) -> [UniversalDbModel]{

        var universalList = [UniversalDbModel]()
        
        for coreDataItem in coreDataList {
            universalList.append(UniversalDbModel(withCoreDataModel: coreDataItem))
        }
        
        return universalList
    }
    
    func convertRealmList(realmList: [ScheduleItemRealm]) -> [UniversalDbModel]{
        
        var universalList = [UniversalDbModel]()
        
        for realmItem in realmList {
            universalList.append(UniversalDbModel(withRealmModel: realmItem))
        }
        
        return universalList
    }
    
    
}