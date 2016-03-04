//
//  PDTMacro.h
//  Pocodot
//
//  Created by Andrey Ten on 6/18/15.
//  Copyright (c) 2015 Andrey Ten. All rights reserved.
//

#define PDTDefineBaseViewProperty(propertyName, viewClass)\
    @property (nonatomic, readonly) viewClass *propertyName;

#define PDTBaseViewGetterSynthesize(selector, viewClass)\
    - (viewClass *)selector { \
        if ([self isViewLoaded] && [self.view isKindOfClass:[viewClass class]]) { \
            return (viewClass *)self.view; \
        } \
        \
        return nil; \
    }

#define PDTViewControllerBaseViewProperty(baseViewController, propertyName, baseViewClass) \
    @interface baseViewController (__##baseViewController##BaseView) \
    PDTDefineBaseViewProperty(propertyName, baseViewClass) \
    \
    @end \
    \
    @implementation baseViewController (__##baseViewController##BaseView) \
    \
    @dynamic propertyName; \
    \
    PDTBaseViewGetterSynthesize(propertyName, baseViewClass); \
    \
    @end

#define PDTWeakify(variable) \
    __weak __typeof(variable) __PDTWeakified_##variable = variable;

// you should only call this method after you called weakify for that same variable
#define PDTStrongify(variable) \
    _Pragma ("clang diagnostic push"); \
    _Pragma ("clang diagnostic ignored \"-Wshadow\""); \
    \
    __strong __typeof(variable) variable = __PDTWeakified_##variable; \
    \
    _Pragma ("clang diagnostic pop");

#define PDTEmptyResult

#define PDTStrongifyAndReturnIfNil(variable) \
    PDTStrongifyAndReturnResultIfNil(variable, PDTEmptyResult)

#define PDTStrongifyAndReturnNilIfNil(variable) \
    PDTStrongifyAndReturnResultIfNil(variable, nil)

#define PDTStrongifyAndReturnResultIfNil(variable, result) \
    PDTStrongify(variable) \
    if (!variable) { \
        return result; \
    }

#define PDTObserverSetter(propertyName)         \
    if (_##propertyName != propertyName) {      \
        [_##propertyName removeObserver:self];  \
                                                \
        _##propertyName = propertyName;         \
        [propertyName addObserver:self];        \
    }

#define PDTSaveToUserDefaults(className)                                                                        \
    NSData *encoded##className = [NSKeyedArchiver archivedDataWithRootObject:[className sharedInstance]];       \
    [[NSUserDefaults standardUserDefaults] setObject:encoded##className forKey:@"k"#className"UserDefaultsKey"];

#define PDTRestoreFromUserDefaults(className)                                                                          \
    NSData *decoded##className = [[NSUserDefaults standardUserDefaults] objectForKey:@"k"#className"UserDefaultsKey"]; \
    [NSKeyedUnarchiver unarchiveObjectWithData:decoded##className];

#define PDTClearUserDefaults(className)                                                         \
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"k"#className"UserDefaultsKey"];

#define PDTKeyForNSCoding(propertyName) \
    @"kPDT"#propertyName"NSCodingKey"

#define DEBUG_MODE 1

#if (1 == DEBUG_MODE)
    #define PDTSleep(time) sleep(time)
    #define PDTUSleep(time) usleep(time)
#else
    #define PDTSleep(time)
    #define PDTUSleep(time)
#endif
