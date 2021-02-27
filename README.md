# Wiki-Universe
## 
<!--- These are examples. See https://shields.io for others or to customize this set of shields. You might want to include dependencies, project status and licence info here --->
![GitHub repo size](https://img.shields.io/github/repo-size/lmt20/Wiki-Universe)
![GitHub issues](https://img.shields.io/github/issues/lmt20/Wiki-Universe)
![GitHub contributors](https://img.shields.io/github/contributors/lmt20/Wiki-Universe)
![Twitter Follow](https://img.shields.io/twitter/follow/TruongLeManh?style=social)

INTRODUCTION
------------
- This is a utility IOS app. It allows you to detect the main object in an image using your camera or through your photo library. 
- It predicts the type of object and provides its specific information based on Wikipedia website
- It used swift as programming language, Alamofire library to handle network requests, SwiftyJSON to parse JSON and SDWebImage to download image
- It can connect with Wikipedia API to get object type infomation, Google Translate API to translate language to Vietnamese language
- It used CoreML to implement Mobinet model (Machine Learning model is provided by Apple). This provided model is not customized and trained with custom data, so the accuracy will not be high. Anyway, this is just an app for fun ^^

![alt text](https://github.com/lmt20/Images/blob/main/Wiki%20Universe/IMG_6890.PNG)
![alt text](https://github.com/lmt20/Images/blob/main/Wiki%20Universe/IMG_6889.PNG)

REQUIREMENTS
------------
    platform :ios, '9.0'
    
    pod 'Alamofire', '~> 5.2'
    pod 'SwiftyJSON', '~> 4.0'
    pod 'SDWebImage', '~> 5.0'
    
    

AUTHOR
-----------
👤 **Le Manh Truong**
* Twitter: [@TruongLeManh](https://twitter.com/TruongLeManh)
* Github: [@lmt20](https://github.com/lmt20)
* LinkedIn: [@truong-le-manh](https://www.linkedin.com/in/truong-le-manh/)

