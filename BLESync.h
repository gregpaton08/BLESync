//
//  BLESync.h
//  BLE Chat
//
//  Created by Greg Paton on 4/27/13.
//  Copyright (c) 2013 Red Bear Company Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLE.h"

@interface BLESync : NSObject <BLEDelegate> {
    BLE *bleShield;
    
    BOOL isConnected;
    BOOL isFileOpen;
    NSString *openFileName;
    NSMutableArray *fileNames;
    int currentFileIndex;
    NSString *currentLine;
    NSString *previousLine;
}

- (BOOL) connect;
- (BOOL) connectWithTimeout: (int) timeout;
- (BOOL) isConnected;
- (BOOL) disconnect;
- (BOOL) start;
- (void) updateFiles;
- (NSMutableArray*) getFileNames;
- (NSString*) getNextFileName;
- (BOOL) openFile: (NSString*)file;
- (NSString*) readLine;
- (BOOL) deleteFile:(NSString*)file;


@end
