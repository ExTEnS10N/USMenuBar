# USMenuBar
### Introduction
ios menubar with slide effect  
![Preview](https://raw.githubusercontent.com/ExTEnS10N/The-Month/master/preview.png)  
When switching between the menu bar item, this animation will start: the slider which is at the bottom of menu bar will move to target item, and length of the slider will change animated to fit the target item.

### Usage  
1. Download USMenuBar.Swift, add it to your project
2. In storyboard/xib, add a UIView to your view/view controller, and set its class as 'USMenuBar'
3. in code aspect,use it just like tableview/collection view, set menubar's datasource and delegate

```swift
@IBOutlet menuBar:USMenuBar!
override func viewDidLoad(){
  super.viewDidLoad()
  menuBar.dataSource = self
  menuBar.delegate = self
}
private let menuTitle = ["item1", "item2"]
func numberOfItemInMenuBar(menuBar: USMenuBar) -> Int {
	return menuTitle.count
}
	
func uSMenuBar(menuBar: USMenuBar, titleForItemAtIndex index: Int) -> String {
	return menuTitle[index]
}
	
func uSMenuBar(menuBar: USMenuBar, didSelectRowAtIndex index: Int) {
	<#code#>
}
```
