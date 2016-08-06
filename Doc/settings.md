This singleton class stores all the settings for the apperance of your debugViews and debugDescriptions.

You only need this class if you want to change the look of your debugViews. You can either set some properties in code or load them from a plist.


##Load Settings:
```objective-c
- (void)loadSettings:(NSURL *)url
```
Use this method if you want to load settings from a plist file. You will find a complete list of supported keys on the end of this page. You can also use one of the default settings files in this repository. They all have different styles (inspired by the Xcode themes):

* com.kladek.pkDebugFramework.settings.default.plist
* com.kladek.pkDebugFramework.settings.dusk.plist
* com.kladek.pkDebugFramework.settings.basic.plist

##Save Settings:
```objective-c
- (void)saveSettings:(NSURL *)url
```
Currently not supported.

## Text

### Text Color
This property stores the color for all textfields.

```objective-v
@property (nonatomic) NSColor *textColor;
```
Propertylist-Key:`debugView.text.color`

<img src=/Users/patrick/Desktop/Color%20Text%20Badge.png height=25>

### Text Font
This property stores the Font of all Textfield.

```objective-c
@property (nonatomic) NSFont *textFont;
```
Propertylist-Keys:

* `debugView.text.font`
* `debugView.text.size`

<img src=/Users/patrick/Desktop/Default%20Font%20Badge.png height=25>


##Keywords
The following Settings are for highlighting Keywords.

###Highlight Keywords
Currently the following keywords are highlighted:

* nil, NULL, @"(null)"
* YES, NO

```objective-c
@property (nonatomic) BOOL highlightKeywords;
```
Propertylist-Key:`debugView.numbers.highlight` 

<img src=/Users/patrick/Desktop/Defualt%20YES%20Badge.png height=25>


### Keyword Color
This property stores the color of all keywords.

```objective-c
@property (nonatomic) NSColor *keywordColor;
```

Propertylist-Key:`debugView.keywords.color`

<img src=/Users/patrick/Desktop/Color%20Keyword%20Badge.png height=25>


### Keyword Font
This property stores the Font of all keywords.

```objective-c
@property (nonatomic) NSFont *keywordFont;
```
Propertylist-Keys:

* `debugView.keywords.font`
* `debugView.keywords.size`

<img src=/Users/patrick/Desktop/Default%20Font%20Badge.png height=25>




## Numbers

### Highlight Numbers
If set all numbers will be colored in a different color.

```objective-c
@property (nonatomic) BOOL highlightNumbers;
```
Propertlist-Key `debugView.numbers.highlight `

<img src=/Users/patrick/Desktop/Defualt%20YES%20Badge.png height=25>


### Number Color
This property stores the Color of all numbers.

```objective-c
@property (nonatomic) BOOL numberColor;
```
Propertylist-Key: `debugView.number.color`

<img src=/Users/patrick/Desktop/Color%20Number%20Badge.png height=25>



### Number Font
This property stores the font of all Numbers

```objective-c
@property (nonatomic) NSFont numberFont;
```

Propertylist-Keys:

* `debugView.number.font`
* `debugView.number.size`

<img src=/Users/patrick/Desktop/Default%20Font%20Badge.png height=25>


## Property Name
Propertynames (Keys) are drawn at the left side, while values are displayed on the right. Usually they have a lighter color so they are visually subtile while keys are more aggresive and a litle darker.

<img src=/Users/patrick/Desktop/Person.png>

### Property Name Color
This property stores the Color of all numbers.

```objective-c
@property (nonatomic) NSColor *propertyNameColor;
```
Propertylist-Key: `debugView.propertyName.color`

<img src=/Users/patrick/Desktop/Color%20PropertyName%20Badge.png height=25>

### Property Name Font
This property stores the font of all Property Names

```objective-c
@property (nonatomic) NSFont propertyNameFont;
```

Propertylist-Keys:

* `debugView.propertyName.font`
* `debugView.propertyName.size`

<img src=/Users/patrick/Desktop/Default%20Font%20Badge.png height=25>


## Title

### Title Color

This property stores the color of the title. Please keep in mind that this color and the color of the frame should have a high contrast.

```objective-c
@property (nonatomic) NSColor *titleColor;
```
Propertylist-Key:`debugView.title.color`

<img src=/Users/patrick/Desktop/Color%20Title%20Badge.png height=25>


### Title Font
This property stores the font of the Title

```objective-c
@property (nonatomic) NSFont *titleFont;
```

Propertylist-Keys:

* `debugView.title.font `
* `debugView.title.size `

<img src=/Users/patrick/Desktop/Title%20Font%20Badge.png height=25>

## Data & Image
Now here comes the magic. Lets say you have an NSData property (which represent an image) in a Core Data application. To inspect the image/data you have to write some code, rebuild and navigate where you left. Or you could name your variable something like `imageData` and add `image` to the searchlist. Now every NSData object with `image` in its propertyName will be displayed as image and not as raw data.

### Convert Data to Image
To enable this feature this property must be set to TRUE.

```objective-v
@property (nonatomic) BOOL convertDataToImage;
```
Propertylist-Key `debugView.image.dataToImage`

<img src=/Users/patrick/Desktop/Defualt%20YES%20Badge.png height=25>

### Property Name Contains
Furthermore this array must contain at least one entry otherwise the conversation won´t work.

```objective-c
@property (nonatomic) NSArray *propertyNameContains;
```

Propertylist-Key: `debugView.image.propertyNameContains`

The default value is an empty array.


### Image Size
This property limits the size of an image. Use a resonable value or you are wasting a lot of space.

```objective-c
@property (nonatomic) NSSize imageSize;
```

Propertylist-Key: `debugView.image.size`

<img src=/Users/patrick/Desktop/Image%20Size%20Badge.png height=25>


### Max Data Lenght
*Only for DebugDescription.*
You can cut a data objects lenght so it won´t produce a lot useless information. Just set the `maxDataLenght` property to a reasonable value.

```objective-c
@property (nonatomic) NSNumber *maxDataLenght;
```

Propertylist-Key: `debugDescription.NSData.cutLenght`

<img src=/Users/patrick/Desktop/Max%20Lenght%20Badge.png height=25>


## Appearance
With this keys you can change the look of your views. For example change the Framecolor or Backgroundcolor.

### Line Spacing
This property stores the line space. The textfields are aligned vertically with `linespacing` in between.

```objective-v
@property (nonatomic) NSInteger lineSpace;
```

Propertylist-Key: `debugView.appearance.lineSpace`

<img src=/Users/patrick/Desktop/Line%20Spacing%20Badge.png height=25>


### Background Color
This property stores the backgroundcolor information which can even be changed after the view was rendered.

```objective-v
@property (nonatomic) NSColor *backgroundColor;
```
Propertylist-Key: `debugView.appearance.backgroundColor`

<img src=/Users/patrick/Desktop/Background%20Color%20Badge.png height=25>

### Frame Color
This property stores the Frame Color from which the frame gradient is created. The Gradient uses the frame color plus the same color with 20% more white. So it´s better to use some darker colors.

```objective-v
@property (nonatomic) NSColor *frameColor;
```
Propertylist-Key: `debugView.appearance.frameColor`

<img src=/Users/patrick/Desktop/Frame%20Color%20Badge.png height=25>


### Color
Colors are rendered as follows:

<img src=/Users/patrick/Desktop/NSColor.png>

Because NSColor saves each rgb-channel as a float value we have to calculate the 8bit value. If you are using something other than a 8 bit colorspace you shoudld change this.

```objective-v
@property (nonatomic) NSInteger numberOfBitsPerColorComponent;
```

Propertylist-Key: `debugView.appearance.numberOfBitsPerColorComponent`

<img src=/Users/patrick/Desktop/Color%20Bits%20Badge.png height=25>


### Date
This property stores the dateFormat for the dateFormatter.

```objective-v
@property (nonatomic) NSString *dateFormat;
```

Propertylist-Key: `debugView.NSDate.format`

Default Value: <b>yyyy-MM-dd 'at' HH:mm</b>



## Auto Save
For Documentation you can also save each view automatically.

### Save
This property stores if the view is saved or not.

```objective-v
@property (nonatomic) BOOL save;
```

Propertylist-Key: `debugView.appearance.save`

<img src=/Users/patrick/Desktop/Auto%20Save%20Badge.png height=25>

### Save Path
This property store the filepath where the view is saved.
The File Structure look something like this

`debugView/` Document Root

`debugView/1.0` App Version

`debugView/1.0/123` App Build Number

Because of the naming structure you should use a automated versioning tool. See Chapter `Automated Versioning`

```objective-v
@property (nonatomic) NSURL *saveUrl;
```

Propertylist-Key: `debugView.appearance.path`

<img src=/Users/patrick/Desktop/Save%20Url%20Badge.png height=25>

### PDF
This property stores if the saved file is a pdf or a png file.

```objective-v
@property (nonatomic) BOOL saveAsPDF;
```

Propertylist-Key: `debugView.appearance.usePDF`

<img src=/Users/patrick/Desktop/Auto%20Save%20Badge.png height=25>







##Supported Keys
Here is a list of all supported keys.

```
debugView.keywords.highlight
debugView.keywords.color
debugView.keywords.font
debugView.keywords.size

debugView.numbers.highlight
debugView.numbers.color
debugView.numbers.font
debugView.numbers.size

debugView.text.color
debugView.text.font
debugView.text.size

debugView.propertyName.color
debugView.propertyName.font
debugView.propertyName.size

debugView.title.color
debugView.title.font
debugView.title.size

debugView.image.size
debugView.image.dataToImage
debugView.image.propertyNameContains

debugView.appearance.lineSpace
debugView.appearance.backgroundColor
debugView.appearance.frameColor
debugView.appearance.numberOfBitsPerColorComponent
debugView.appearance.save
debugView.appearance.path
debugView.appearance.usePDF

debugView.NSDate.format

debugDescription.NSData.cutLenght
```