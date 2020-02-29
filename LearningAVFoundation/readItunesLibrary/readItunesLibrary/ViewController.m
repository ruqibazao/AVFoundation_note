//
//  ViewController.m
//  readItunesLibrary
//
//  Created by nenhall on 2020/1/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "ViewController.h"
#import <iTunesLibrary/iTunesLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property(copy)NSArray *allMediaItems;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSError *error;
    ITLibrary *library = [ITLibrary libraryWithAPIVersion:@"1.0" error:&error];
    
    NSArray *items = library.allMediaItems;
    NSString *query = @"artist.name == 'Robert Johnson' AND"
    "album.title == 'king of the Delta Blues Singers' AND"
    "title == 'Cross Road Blues'";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
    NSArray *songs = [items filteredArrayUsingPredicate:predicate];
    if (songs.count) {
        ITLibMediaItem *item = songs[0];
        AVAsset *asset = [AVAsset assetWithURL:item.location];
        // ...
        NSLog(@"ITLibMediaItem.URL:%@",item.location);
    }

}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
