//
//  BLESync.m
//  BLE Chat
//
//  Created by Greg Paton on 4/27/13.
//  Copyright (c) 2013 Red Bear Company Limited. All rights reserved.
//

#import "BLESync.h"

@implementation BLESync


#pragma mark - Init

- (id) init {
    self = [super init];
    if (self) {
        isConnected = false;
        isFileOpen = false;
        openFileName = @"";
        fileNames = [[NSMutableArray alloc] init];
        currentFileIndex = 0;
        bleShield = [[BLE alloc] init];
        [bleShield controlSetup:1];
        bleShield.delegate = self;
        currentLine = @"";
        previousLine = @"PL";
    }
    
    return self;
}

#pragma mark - BLE

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length {
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *string = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    const char *cstring = [string UTF8String];
    
    if ([string length] > 3 && [[string substringToIndex:3] isEqualToString:@"OBD"]) {
        [fileNames addObject:string];
    }
    else if ([string length] > 4 && [[string substringToIndex:5] isEqualToString:@"START"]) {
        
    }
    else if ([string length] > 3 && [[string substringToIndex:4] isEqualToString:@"OPEN"]) {
        printf("OPEN\n");
    }
    else if ([string length] > 3 && [[string substringToIndex:4] isEqualToString:@"EXIT"]) {
        
    }
    else if ([string length] > 2 && [[string substringToIndex:3] isEqualToString:@"DEL"]) {
        
    }
    else if ([string length] > 3 && [[string substringToIndex:4] isEqualToString:@"FAIL"]) {
        
    }
    else if (cstring[0] > 47 && cstring[0] < 58) {
        currentLine = string;
    }
}

- (void) bleDidDisconnect {
    isConnected = false;
    isFileOpen = false;
}

-(void) bleDidConnect {
    isConnected = true;
    [self updateFiles];
}

- (void) bleShieldSend: (NSString*)string {
    NSData *d;
    
    if (false == isConnected)
        return;
    
    if (string.length > 16)
        string = [string substringToIndex:16];
    
    string = [NSString stringWithFormat:@"%@\r\n", string];
    d = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [bleShield write:d];
}

#pragma mark - Timer

-(void) connectionTimer: (NSTimer *)timer {
    if(bleShield.peripherals.count > 0)
        [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:0]];
}

#pragma mark - Methods

- (BOOL) connect {
    const int timeout = 4;
    return [self connectWithTimeout:timeout];
}

- (BOOL) connectWithTimeout: (int) timeout {
    if (bleShield.activePeripheral)
        if (bleShield.activePeripheral.isConnected)
            return true;
    
    if (bleShield.peripherals)
        bleShield.peripherals = nil;
    
    [bleShield findBLEPeripherals:timeout];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    return true;
    
}

- (BOOL) isConnected {
    return isConnected;
}

- (BOOL) disconnect {
    if (bleShield.activePeripheral)
        if (bleShield.activePeripheral.isConnected)
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
    
    return true;
}

- (BOOL) start {
    [self bleShieldSend:@"s"];
    
    return true;
}

- (void) updateFiles {
    [self bleShieldSend:@"l"];
}

- (NSMutableArray*) getFileNames {
    return fileNames;
}

- (NSString*) getNextFileName {
    return [fileNames objectAtIndex:currentFileIndex];
    ++currentFileIndex;
    if (currentFileIndex >= [fileNames count])
        currentFileIndex = 0;
}

- (BOOL) openFile: (NSString*)file {
    if (false == isConnected)
        return false;
    
    if (file == NULL)
        return false;
    
    if (file.length > 12)
        return false;
    
    [self bleShieldSend:[NSString stringWithFormat:@"o%@", file]];
    
    isFileOpen = true;
    
    return true;
}

- (NSString*) readLine {
    if ([currentLine length] > 2 && [[currentLine substringToIndex:3] isEqualToString:@"EOF"])
        return @"EOF";
    if ([previousLine isEqualToString:currentLine]) 
        return @"";
    
    previousLine = currentLine;
    
    [self bleShieldSend:@"r"];
    
    return currentLine;
}

- (BOOL) deleteFile:(NSString*)file {
    return true;
}

@end
