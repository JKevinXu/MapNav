//
//  Item.m
//  Randomitems
//
//  Created by XuJian on 12/20/15.
//  Copyright (c) 2015 XuJian. All rights reserved.
//

#import "Item.h"

@implementation Item

+ (instancetype)randomItem
{
    // Create an immutable array of three adjectives
    NSArray *randomAdjectiveList = @[@"Fluffy", @"Rusty", @"Shiny"];
    
    // Create an immutable array of three nouns
    NSArray *randomNounList = @[@"Bear", @"Spork", @"Mac"];
    
    // Get the index of a random adjective/noun from the lists
    unsigned int adjectiveIndex =
        arc4random_uniform( (unsigned int)[randomAdjectiveList count]);
    
    unsigned int nounIndex =
    arc4random_uniform( (unsigned int) [randomNounList count]);
    
    // Note that NSInteger is not an object, but a type definition for "long"
    NSString *randomName = [NSString stringWithFormat:@"%@ %@",
                            [randomAdjectiveList objectAtIndex:adjectiveIndex],
                            [randomNounList objectAtIndex:nounIndex]
                            
                            ];
    // Generate the random value in dollars, 0-88
    int randomValue = arc4random_uniform(100);
    
    // Use NSUUID to generate a random 5-letter string for the serial number
    NSString *randomSerialNumber = [[[NSUUID UUID] UUIDString] substringToIndex:5];
    
    // Institiate the new item with the random values
    Item *newItem = [[self alloc] initWithName: randomName
                                 valueInDollars: randomValue
                                  serialNumber: randomSerialNumber];
    
    return newItem;
}

- (NSString *)description
{
    NSString *descriptionString =
    [[NSString alloc] initWithFormat:@"%@ (%@): Worth $%d, reorder on %@",
                        self.name,
                        self.serialNumber,
                        self.valueInDollars,
                        self.dateCreated];
    return descriptionString;
}

- (instancetype)initWithName:(NSString *)name
                valueInDollars:(int)value
                serialNumber:(NSString *)sNumber
{
    // Call teh superclass's designated initializer
    self = [super init];
    
    // Did the superclass's designated initilizer succeed?
    if (self) {
    // Give the instance variable initial values
        _name = name;
        _serialNumber = sNumber;
        _valueInDollars = value;
        // Set _dateCreated to the current date and time
        _dateCreated = [[NSDate alloc] init];
        _itemKey = [[NSUUID UUID] UUIDString];
    }
    
    // Return the address of the newly initialized object
    return self;
}

- (instancetype)initWithName:(NSString *)name
{
    return[self initWithName:name
              valueInDollars:0
                serialNumber:@""];
}

- (instancetype)init
{
    return [self initWithName:@"Item"];
}


@end
