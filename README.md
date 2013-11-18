## Dial
#### The beginnings of a replacement Contacts app for iOS.

![demo](https://raw.github.com/indragiek/Dial/master/dial.gif)

This is an unfinished project that [Tyler Murphy](http://twitter.com/tylrmurphy) and I started working on last year. The project wasn't completed for two primary reasons:

* Lack of APIs to truly **replace** the Contacts app (e.g. no way to access call history)
* We were both busy with other things.

This is open sourced now in hopes that someone may find it useful for something. The project was built on the **iOS 6 SDK**. It compiles as-is on Xcode 5. 

### Notable Bits

* `ABAddressBook` wrapper consisting of the following classes:
	* [DALABAddressBook](https://github.com/indragiek/Dial/blob/master/Dial/Classes/DALABAddressBook.h)
	* [DALABRecord](https://github.com/indragiek/Dial/blob/master/Dial/Classes/DALABRecord.h)
	* [DALABPerson](https://github.com/indragiek/Dial/blob/master/Dial/Classes/DALABPerson.h)
	* [DALABMultiValueObject](https://github.com/indragiek/Dial/blob/master/Dial/Classes/DALABMultiValueObject.h)
* [DALSectionIndexCollectionView](https://github.com/indragiek/Dial/blob/master/Dial/Classes/DALSectionIndexCollectionView.h) - `UICollectionView` subclass that adds a `UITableView`-like section index control.
* [DALCircularMenu](https://github.com/indragiek/Dial/blob/master/Dial/Classes/DALCircularMenu.h) - Path-like animated circular menu implementation.
	* Also see [DALOverlayViewController](https://github.com/indragiek/Dial/blob/master/Dial/Classes/DALOverlayViewController.m), which presents the circular menu with automatically calculated angles so that the contents are visible within the view bounds.
	
### License

MIT License. See [LICENSE.md](https://github.com/indragiek/Dial/blob/master/LICENSE.md).

### Credits

Developed by [Indragie Karunaratne](http://indragie.com), designed by [Tyler Murphy](http://twitter.com/tylrmurphy).