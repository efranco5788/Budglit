//
//  ZipcodeSearchDataSource.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/28/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "ZipcodeSearchDataSource.h"
#import "AppDelegate.h"
#import "CityDataObject.h"

@interface ZipcodeSearchDataSource()

@property (nonatomic, strong) NSArray* dataCityFiltered;

@property (nonatomic, strong) NSArray* dataPostalCodeFiltered;

@end

@implementation ZipcodeSearchDataSource
@synthesize userSearchInput;

static NSString* const cellIdentifier = @"Cell";

-(instancetype)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSSortDescriptor* cityDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSSortDescriptor* postalDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postal" ascending:YES selector:nil];
    
    self.dataCityFiltered = [[appDelegate.locationManager cities] sortedArrayUsingDescriptors:@[cityDescriptor]];
    
    self.dataPostalCodeFiltered = [[appDelegate.locationManager cities] sortedArrayUsingDescriptors:@[postalDescriptor]];
    
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    self.uniqueStates = [[NSOrderedSet alloc] initWithArray:[self.filteredStatesData valueForKey:@"state"]];
    
    NSString* uniqueState = [self.uniqueStates objectAtIndex:section];
    
    NSPredicate* statePredicate = [NSPredicate predicateWithFormat:@"state = %@", uniqueState];
    
    NSArray* totalCitiesForState = [self.filteredStatesData filteredArrayUsingPredicate:statePredicate];
    
    if (totalCitiesForState.count >= 10) {
        return 10;
    }
    else
        return totalCitiesForState.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSectionsBasedOnSearchResults:userSearchInput forTable:tableView];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    self.uniqueStates = [[NSOrderedSet alloc] initWithArray:[self.filteredStatesData valueForKey:@"state"]];
    
    NSString* stateSection = [self.uniqueStates objectAtIndex:section];
    
    return stateSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString* uniqueState = [self.uniqueStates objectAtIndex:indexPath.section];
    
    NSPredicate* statePredicate = [NSPredicate predicateWithFormat:@"state = %@", uniqueState];
    
    NSArray* totalCitiesForState = [self.filteredStatesData filteredArrayUsingPredicate:statePredicate];
    
    CityDataObject* specifiedCity = [totalCitiesForState objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString* state = specifiedCity.state;
    
    NSString* zipcode = specifiedCity.postal;
    
    NSString* city = specifiedCity.name;
    
    NSString* cellText = [NSString stringWithFormat:@"%@, %@", city, state];
    
    cell.textLabel.text = cellText;
    
    cell.detailTextLabel.text = zipcode;
    
    return cell;
}

-(NSUInteger) numberOfSectionsBasedOnSearchResults:(NSString*)userInput forTable:(UITableView*) tableView
{
    
    NSString* copy = [userInput stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([copy isEqual:NULL] || copy == nil || copy.length == 0)
    {
        return 0;
    }
    else
    {
        if ([userInput integerValue])
        {
            self.filteredStatesData = [self filterContentForSearchText:copy scope:self.dataPostalCodeFiltered byPostal:YES];
            
        }
        else
        {
            self.filteredStatesData = [self filterContentForSearchText:copy scope:self.dataCityFiltered byPostal:NO];
        }
    }
    
    self.uniqueStates = [NSOrderedSet orderedSetWithArray:[self.filteredStatesData valueForKey:@"state"]];
    
    if (!self.uniqueStates) {
        return 0;
    }
    else if (self.uniqueStates.count > 10)
    {
        return 10;
    }
    else return self.uniqueStates.count;
    

}

-(NSArray*)filterContentForSearchText:(NSString *)searchText scope:(NSArray *)scope byPostal:(BOOL)usePostal
{
    NSArray* filteredList;
    
    if (usePostal) {
        
        NSPredicate* postalPredicate = [NSPredicate predicateWithFormat:@"postal BEGINSWITH[cd] %@", searchText];
        
        filteredList = [scope filteredArrayUsingPredicate:postalPredicate];
        
    }
    else {
        
        NSCompoundPredicate* cityORStatePredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", searchText], [NSPredicate predicateWithFormat:@"state BEGINSWITH[cd] %@", searchText]]];
        
        filteredList = [scope filteredArrayUsingPredicate:cityORStatePredicate];
        
    }
    
    return filteredList;
}

@end
