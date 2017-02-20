//
//  ZipcodeSearchDataSource.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/28/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AppDelegate;
@class CityDataObject;

@interface ZipcodeSearchDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, strong) NSString* userSearchInput;

@property (nonatomic, strong) NSOrderedSet* uniqueStates;

@property (nonatomic, strong) NSArray* filteredStatesData;

-(NSUInteger) numberOfSectionsBasedOnSearchResults:(NSString*)userInput forTable:(UITableView*) tableView;

@end
