/*

I know this probably isn't the best way to go about this, but it works.

- Dekesto

*/

#import <UIKit/UIKit.h>
#import "../PS.h"

%hook CAMViewfinderViewController

- (int)_aspectRatioForMode:(int)mode
{
	static NSString *settingsPath = @"/var/mobile/Library/Preferences/com.dekesto.minimalcamera.plist";
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	BOOL keepRatio = ![[prefs allKeys] containsObject:@"keepRatio"] || [prefs[@"keepRatio"] boolValue];

	if (!keepRatio)
		return 1;
	return %orig;
}

- (void)_createCommonGestureRecognizersIfNecessary
{
	%orig;
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleUI:)];
    UITapGestureRecognizer *snapButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapButton:)];
    snapButton.numberOfTapsRequired = 2;
    tapGesture.numberOfTapsRequired = 1;
 	tapGesture.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    [self.view addGestureRecognizer:snapButton];
    [tapGesture release];
    [snapButton release];
}

%new
- (void)toggleUI:(UITapGestureRecognizer *)sender
{
	static NSString *settingsPath = @"/var/mobile/Library/Preferences/com.dekesto.minimalcamera.plist";
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	BOOL isEnabled = ![[prefs allKeys] containsObject:@"isEnabled"] || [prefs[@"isEnabled"] boolValue];
	if (isEnabled) {
		if (self._topBar.hidden == NO) {
			self._topBar.hidden = YES;
			self._bottomBar.hidden = YES;
		} else {
	 		self._topBar.hidden = NO;
			self._bottomBar.hidden = NO;
		}
	}
}

%new
- (void)snapButton:(UITapGestureRecognizer *)sender
{
	static NSString *settingsPath = @"/var/mobile/Library/Preferences/com.dekesto.minimalcamera.plist";
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	BOOL isEnabled = ![[prefs allKeys] containsObject:@"isEnabled"] || [prefs[@"isEnabled"] boolValue];
	if (isEnabled) {
		if (self._bottomBar.hidden)
			[self._shutterButton sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
}

%end