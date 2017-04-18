
import AFNetworking

class SetDateViewController: UIViewController, ApiListener {
    
    @IBOutlet weak var btnSend: UIButton!
    
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var dbManager: AbstractDbManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoaderStub(state: false)
        initActivityIndicator()
    }
    
    func initActivityIndicator() {
        activityIndicator.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2)
        activityIndicator.backgroundColor = UIColor.darkGray
        activityIndicator.layer.cornerRadius = 6.0
        activityIndicator.frame = .init(x: self.view.bounds.size.width/2 - 40, y: self.view.bounds.size.height/2 - 40, width: 80.0, height: 80.0)
    }
    
    @IBAction func setDate(_ sender: Any) {
        isLoaderStub(state: true)
        ApiManager.instance.loadScheduleItems(listener: self, url: ApiManager.instance.createUrl(dateFrom: fromDatePicker.date, dateTo: toDatePicker.date, entity: ApiManager.ApiEntity.trips), dbManager: dbManager!, vc: self)
    }
    
    func isLoaderStub(state: Bool) {
        if state {
            self.navigationController?.view.isUserInteractionEnabled = false
            self.view.isUserInteractionEnabled = false
            self.view.isUserInteractionEnabled = false
            self.btnSend.isEnabled = false
            self.fromDatePicker.isEnabled = false
            self.toDatePicker.isEnabled = false
            self.view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
        } else {
            self.navigationController?.view.isUserInteractionEnabled = true
            self.view.isUserInteractionEnabled = true
            self.view.isUserInteractionEnabled = true
            self.btnSend.isEnabled = true
            self.fromDatePicker.isEnabled = true
            self.toDatePicker.isEnabled = true
            
            activityIndicator.removeFromSuperview()
            activityIndicator.stopAnimating()
        }
    }
    
    //MARK: api listener implementation 
    
    internal func success() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
        _ = self.navigationController?.popToRootViewController(animated: true)
        isLoaderStub(state: false)
    }
    
    internal func parseError() {
        isLoaderStub(state: false)
    }
    
    internal func connectionError(error: NSError, url: String) {
        isLoaderStub(state: false)
    }
    
}















