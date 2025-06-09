#import "uYouPlus.h"

// Constants
static UIColor *const kLowContrastColor = [UIColor colorWithRed:0.56 green:0.56 blue:0.56 alpha:1.00];
static UIColor *const kDefaultTextColor = [UIColor whiteColor];

// Helper Functions
static int contrastMode() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"lcm"];
}

static BOOL lowContrastMode() {
    return IS_ENABLED(@"lowContrastMode_enabled") && contrastMode() == 0;
}

static BOOL customContrastMode() {
    return IS_ENABLED(@"lowContrastMode_enabled") && contrastMode() == 1;
}

static UIColor *getCustomContrastColor() {
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCustomUIColor"];
    if (colorData) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:colorData error:nil];
        [unarchiver setRequiresSecureCoding:NO];
        return [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey] ?: kLowContrastColor;
    }
    return kLowContrastColor;
}

// Shared Color Hook Macros
#define HOOK_LCM_COLOR_METHOD(method) \
+ (UIColor *)method { \
    if (lowContrastMode()) { \
        return kLowContrastColor; \
    } \
    return [super method]; \
}

#define HOOK_CCM_COLOR_METHOD(method) \
+ (UIColor *)method { \
    if (customContrastMode()) { \
        return getCustomContrastColor(); \
    } \
    return [super method]; \
}

// Shared Palette Hook Macro
#define HOOK_PALETTE_METHOD(method, alpha) \
- (UIColor *)method { \
    if (self.pageStyle == 1) { \
        UIColor *baseColor = lowContrastMode() ? kLowContrastColor : customContrastMode() ? getCustomContrastColor() : kDefaultTextColor; \
        return alpha < 1.0 ? [baseColor colorWithAlphaComponent:alpha] : baseColor; \
    } \
    return %orig; \
}

%group gLowContrastMode // Low Contrast Mode v1.7.0 (Compatible with only YouTube v19.01.1-v20.21.6)
%hook UIColor
HOOK_LCM_COLOR_METHOD(whiteColor)
HOOK_LCM_COLOR_METHOD(lightTextColor)
HOOK_LCM_COLOR_METHOD(lightGrayColor)
HOOK_LCM_COLOR_METHOD(ychGrey7)
HOOK_LCM_COLOR_METHOD(skt_chipBackgroundColor)
HOOK_LCM_COLOR_METHOD(placeholderTextColor)
HOOK_LCM_COLOR_METHOD(systemLightGrayColor)
HOOK_LCM_COLOR_METHOD(systemExtraLightGrayColor)
HOOK_LCM_COLOR_METHOD(labelColor)
HOOK_LCM_COLOR_METHOD(secondaryLabelColor)
HOOK_LCM_COLOR_METHOD(tertiaryLabelColor)
HOOK_LCM_COLOR_METHOD(quaternaryLabelColor)
%end

%hook YTCommonColorPalette
HOOK_PALETTE_METHOD(textPrimary, 1.0)
HOOK_PALETTE_METHOD(textSecondary, 1.0)
HOOK_PALETTE_METHOD(overlayTextPrimary, 1.0)
HOOK_PALETTE_METHOD(overlayTextSecondary, 1.0)
HOOK_PALETTE_METHOD(iconActive, 1.0)
HOOK_PALETTE_METHOD(iconActiveOther, 1.0)
HOOK_PALETTE_METHOD(brandIconActive, 1.0)
HOOK_PALETTE_METHOD(staticBrandWhite, 1.0)
HOOK_PALETTE_METHOD(overlayIconActiveOther, 1.0)
HOOK_PALETTE_METHOD(overlayIconInactive, 0.7)
HOOK_PALETTE_METHOD(overlayIconDisabled, 0.3)
HOOK_PALETTE_METHOD(overlayFilledButtonActive, 0.2)
%end

%hook YTColor
+ (BOOL)darkerPaletteTextColorEnabled {
    return NO;
}
+ (UIColor *)white1 { return kDefaultTextColor; }
+ (UIColor *)white2 { return kDefaultTextColor; }
+ (UIColor *)white3 { return kDefaultTextColor; }
+ (UIColor *)white4 { return kDefaultTextColor; }
+ (UIColor *)white5 { return kDefaultTextColor; }
+ (UIColor *)grey1 { return kDefaultTextColor; }
+ (UIColor *)grey2 { return kDefaultTextColor; }
%end

%hook _ASDisplayView
- (void)layoutSubviews {
    %orig;
    NSArray *accessibilityLabels = @[@"connect account", @"Thanks", @"Save to playlist", @"Report"];
    for (UIView *subview in self.subviews) {
        if ([accessibilityLabels containsObject:subview.accessibilityLabel]) {
            subview.backgroundColor = kLowContrastColor;
            if ([subview isKindOfClass:[UILabel class]]) {
                [(UILabel *)subview setTextColor:[UIColor blackColor]];
            }
        }
    }
}
%end

%hook QTMColorGroup
- (UIColor *)tint100 { return kDefaultTextColor; }
- (UIColor *)tint300 { return kDefaultTextColor; }
- (UIColor *)tint500 { return kDefaultTextColor; }
- (UIColor *)tint700 { return kDefaultTextColor; }
- (UIColor *)accent200 { return kDefaultTextColor; }
- (UIColor *)accent400 { return kDefaultTextColor; }
- (UIColor *)accentColor { return kDefaultTextColor; }
- (UIColor *)brightAccentColor { return kDefaultTextColor; }
- (UIColor *)regularColor { return kDefaultTextColor; }
- (UIColor *)darkerColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColor { return kDefaultTextColor; }
- (UIColor *)lightBodyTextColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnRegularColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnLighterColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnDarkerColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnAccentColor { return kDefaultTextColor; }
- (UIColor *)buttonBackgroundColor { return kDefaultTextColor; }
%end

%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *tintedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:kDefaultTextColor];
    %orig(tintedImage);
}
%end

%hook UIExtendedSRGColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig([kDefaultTextColor colorWithAlphaComponent:0.9]);
}
%end

%hook UIExtendedSRGBColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UIExtendedGrayColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:kDefaultTextColor];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:kDefaultTextColor forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end

%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    %orig(kDefaultTextColor, state);
}
%end

%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:kDefaultTextColor forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end

%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:kDefaultTextColor forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end

%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig(kDefaultTextColor.CGColor);
}
%end

%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *original = %orig;
    NSMutableAttributedString *modified = [original mutableCopy];
    [modified addAttribute:NSForegroundColorAttributeName value:kDefaultTextColor range:NSMakeRange(0, modified.length)];
    return modified;
}
%end

%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UIControl
- (UIColor *)backgroundColor {
    return [UIColor blackColor];
}
%end
%end

%group gCustomContrastMode
%hook UIColor
HOOK_CCM_COLOR_METHOD(whiteColor)
HOOK_CCM_COLOR_METHOD(lightTextColor)
HOOK_CCM_COLOR_METHOD(lightGrayColor)
HOOK_CCM_COLOR_METHOD(ychGrey7)
HOOK_CCM_COLOR_METHOD(skt_chipBackgroundColor)
HOOK_CCM_COLOR_METHOD(placeholderTextColor)
HOOK_CCM_COLOR_METHOD(systemLightGrayColor)
HOOK_CCM_COLOR_METHOD(systemExtraLightGrayColor)
HOOK_CCM_COLOR_METHOD(labelColor)
HOOK_CCM_COLOR_METHOD(secondaryLabelColor)
HOOK_CCM_COLOR_METHOD(tertiaryLabelColor)
HOOK_CCM_COLOR_METHOD(quaternaryLabelColor)
%end

%hook YTCommonColorPalette
HOOK_PALETTE_METHOD(textPrimary, 1.0)
HOOK_PALETTE_METHOD(textSecondary, 1.0)
HOOK_PALETTE_METHOD(overlayTextPrimary, 1.0)
HOOK_PALETTE_METHOD(overlayTextSecondary, 1.0)
HOOK_PALETTE_METHOD(iconActive, 1.0)
HOOK_PALETTE_METHOD(iconActiveOther, 1.0)
HOOK_PALETTE_METHOD(brandIconActive, 1.0)
HOOK_PALETTE_METHOD(staticBrandWhite, 1.0)
HOOK_PALETTE_METHOD(overlayIconActiveOther, 1.0)
HOOK_PALETTE_METHOD(overlayIconInactive, 0.7)
HOOK_PALETTE_METHOD(overlayIconDisabled, 0.3)
HOOK_PALETTE_METHOD(overlayFilledButtonActive, 0.2)
%end

%hook YTColor
+ (BOOL)darkerPaletteTextColorEnabled {
    return NO;
}
+ (UIColor *)white1 { return kDefaultTextColor; }
+ (UIColor *)white2 { return kDefaultTextColor; }
+ (UIColor *)white3 { return kDefaultTextColor; }
+ (UIColor *)white4 { return kDefaultTextColor; }
+ (UIColor *)white5 { return kDefaultTextColor; }
+ (UIColor *)grey1 { return kDefaultTextColor; }
+ (UIColor *)grey2 { return kDefaultTextColor; }
%end

%hook _ASDisplayView
- (void)layoutSubviews {
    %orig;
    NSArray *accessibilityLabels = @[@"connect account", @"Thanks", @"Save to playlist", @"Report"];
    for (UIView *subview in self.subviews) {
        if ([accessibilityLabels containsObject:subview.accessibilityLabel]) {
            subview.backgroundColor = getCustomContrastColor();
            if ([subview isKindOfClass:[UILabel class]]) {
                [(UILabel *)subview setTextColor:[UIColor blackColor]];
            }
        }
    }
}
%end

%hook QTMColorGroup
- (UIColor *)tint100 { return kDefaultTextColor; }
- (UIColor *)tint300 { return kDefaultTextColor; }
- (UIColor *)tint500 { return kDefaultTextColor; }
- (UIColor *)tint700 { return kDefaultTextColor; }
- (UIColor *)accent200 { return kDefaultTextColor; }
- (UIColor *)accent400 { return kDefaultTextColor; }
- (UIColor *)accentColor { return kDefaultTextColor; }
- (UIColor *)brightAccentColor { return kDefaultTextColor; }
- (UIColor *)regularColor { return kDefaultTextColor; }
- (UIColor *)darkerColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColor { return kDefaultTextColor; }
- (UIColor *)lightBodyTextColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnRegularColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnLighterColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnDarkerColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnAccentColor { return kDefaultTextColor; }
- (UIColor *)buttonBackgroundColor { return kDefaultTextColor; }
%end

%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *tintedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:kDefaultTextColor];
    %orig(tintedImage);
}
%end

%hook UIExtendedSRGColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig([kDefaultTextColor colorWithAlphaComponent:0.9]);
}
%end

%hook UIExtendedSRGBColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UIExtendedGrayColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:kDefaultTextColor];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:kDefaultTextColor forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end

%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    %orig(kDefaultTextColor, state);
}
%end

%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:kDefaultTextColor forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end

%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:kDefaultTextColor forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end

%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig(kDefaultTextColor.CGColor);
}
%end

%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *original = %orig;
    NSMutableAttributedString *modified = [original mutableCopy];
    [modified addAttribute:NSForegroundColorAttributeName value:kDefaultTextColor range:NSMakeRange(0, modified.length)];
    return modified;
}
%end

%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UIControl
- (UIColor *)backgroundColor {
    return [UIColor blackColor];
}
%end
%end

%ctor {
    %init;
    if (lowContrastMode()) {
        %init(gLowContrastMode);
    }
    if (customContrastMode()) {
        %init(gCustomContrastMode);
    }
}
