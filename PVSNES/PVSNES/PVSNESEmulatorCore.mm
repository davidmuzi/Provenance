/*
 Copyright (c) 2013, OpenEmu Team


 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the OpenEmu Team nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "OERingBuffer.h"

#import "PVSNESEmulatorCore.h"
#import "HiganInterface.h"
#import "HiganImporter.h"
#import "OETimingUtils.h"

@interface PVSNESEmulatorCore ()
{
    Interface *_interface;
}
@end

@implementation PVSNESEmulatorCore

- (void)dealloc
{
    delete _interface;
}

#pragma mark - Execution

- (BOOL)loadFileAtPath:(NSString *)path
{
    _interface = new Interface;

    _interface->bundlePath  = [[[NSBundle mainBundle] resourcePath] UTF8String];
    _interface->supportPath = _interface->bundlePath;

    vector<uint8_t> buffer  = file::read([path UTF8String]);
    string romName          = [[path lastPathComponent] UTF8String];
    string biosPath         = _interface->bundlePath;

    if([[self systemIdentifier] isEqualToString:@"com.provenance.snes"])
    {
        _interface->loadMedia(romName, "Super Famicom", PVSuperFamicomSystem, SuperFamicom::ID::SuperFamicom);
        importSuperFamicom(_interface->path(SuperFamicom::ID::SuperFamicom), biosPath, buffer);
    }
    else if([[self systemIdentifier] isEqualToString:@"com.provenance.gba"])
    {
        string gbaBiosPath = {biosPath, "/bios.rom"};

        if(!file::exists(gbaBiosPath))
            return NO;

        _interface->loadMedia(romName, "Game Boy Advance", PVGameBoyAdvanceSystem, GameBoyAdvance::ID::GameBoyAdvance);
        importGameBoyAdvance(_interface->path(GameBoyAdvance::ID::GameBoyAdvance), buffer);

        file::copy(gbaBiosPath, {_interface->path(0), "bios.rom"});
    }
    else if([[self systemIdentifier] isEqualToString:@"com.provenance.gb"])
    {
        string systemName = "Game Boy";
        unsigned mediaID = GameBoy::ID::GameBoy;

        if(checkGameBoyColorSupport(buffer))
        {
            systemName = "Game Boy Color";
            mediaID = GameBoy::ID::GameBoyColor;
        }

        _interface->loadMedia(romName, systemName, PVGameBoySystem, mediaID);
        importGameBoy(_interface->path(mediaID), buffer);

        string sgbRomPath = {biosPath, "/Super Game Boy (World).sfc"};
        string sgbBootRomPath = {biosPath, "/sgb.rom"};
        bool sgbAvailable = file::exists(sgbRomPath) && file::exists(sgbBootRomPath);
        
        // Check for Super Game Boy header
        if(sgbAvailable && (buffer[0x0146] & 0x03) == 0x03)
        {
            buffer = file::read(sgbRomPath);
            
            _interface->loadMedia("Super Game Boy (World).sfc", "Super Famicom", PVSuperFamicomSystem, SuperFamicom::ID::SuperFamicom);
            importSuperFamicom(_interface->path(SuperFamicom::ID::SuperFamicom), biosPath, buffer);
        }
    }
    else if([[self systemIdentifier] isEqualToString:@"com.provenance.nes"])
    {
        _interface->loadMedia(romName, "Famicom", PVFamicomSystem, Famicom::ID::Famicom);
        importFamicom(_interface->path(Famicom::ID::Famicom), buffer);
    }

    NSLog(@"Higan: Loading game");
    _interface->load();

    return YES;
}

- (void)frameRefreshThread:(id)anArgument
{
	gameInterval = 1.0 / [self frameInterval];
	NSTimeInterval gameTime = OEMonotonicTime();
	
	/*
	 Calling OEMonotonicTime() from the base class implementation
	 of this method causes it to return a garbage value similar
	 to 1.52746e+9 which, in turn, causes OEWaitUntil to wait forever.
	 
	 Calculating the absolute time in the base class implementation
	 without using OETimingUtils yields an expected value.
	 
	 However, calculating the absolute time while in the base class
	 implementation seems to have a performance hit effect as
	 emulation is not as fast as it should be when running on a device,
	 causing audio and video glitches, but appears fine in the simulator
	 (no doubt because it's on a faster CPU).
	 
	 Calling OEMonotonicTime() from any subclass implementation of
	 this method also yields the expected value, and results in
	 expected emulation speed.
	 
	 I am unable to understand or explain why this occurs. I am obviously
	 missing some vital information relating to this issue.
	 Perhaps someone more knowledgable than myself can explain and/or fix this.
	 */
	
	////	struct mach_timebase_info timebase;
	////	mach_timebase_info(&timebase);
	////	double toSec = 1e-09 * (timebase.numer / timebase.denom);
	////	NSTimeInterval gameTime = mach_absolute_time() * toSec;
	
	OESetThreadRealtime(gameInterval, 0.007, 0.03); // guessed from bsnes
	while (!shouldStop)
	{
		if (self.shouldResyncTime)
		{
			self.shouldResyncTime = NO;
			gameTime = OEMonotonicTime();
		}
		
		gameTime += gameInterval;
		
		@autoreleasepool
		{
			if (isRunning)
			{
				[self executeFrame];
			}
		}
		
		OEWaitUntil(gameTime);
		//		mach_wait_until(gameTime / toSec);
	}
}

- (void)executeFrame
{
    [self executeFrameSkippingFrame:NO];
}

- (void)executeFrameSkippingFrame:(BOOL)skip
{
    _interface->run();

    signed samples[2];
    while(_interface->resampler.pending())
    {
        _interface->resampler.read(samples);
        [[self ringBufferAtIndex:0] write:&samples[0] maxLength:2];
        [[self ringBufferAtIndex:0] write:&samples[1] maxLength:2];
    }
}

- (void)resetEmulation
{
    _interface->active->reset();
}

- (void)stopEmulation
{
    _interface->active->save();

    cleanupLibrary(_interface->gamePaths);

    [super stopEmulation];
}

#pragma mark - Video

- (CGSize)aspectSize
{
    switch(_interface->activeSystem)
    {
        case PVGameBoyAdvanceSystem:
            return CGSizeMake(3, 2);
        case PVGameBoySystem:
            return CGSizeMake(10, 9);
        default:
            return CGSizeMake(4, 3);
    }
}

- (CGRect)screenRect
{
    return CGRectMake(0, 0, _interface->width, _interface->height);
}

- (CGSize)bufferSize
{
    return CGSizeMake(512, 480);
}

- (const void *)videoBuffer
{
    return _interface->videoBuffer;
}

- (GLenum)pixelFormat
{
    return GL_RGB;
}

- (GLenum)pixelType
{
    return GL_UNSIGNED_SHORT_5_6_5;
}

- (GLenum)internalPixelFormat
{
    return GL_RGB565;
}

- (NSTimeInterval)frameInterval
{
    return _interface->active->videoFrequency();
}

#pragma mark - Audio

- (NSUInteger)channelCount
{
    return 2;
}

- (double)audioSampleRate
{
    return 44100;
}

#pragma mark - Save State

- (void)saveStateToFileAtPath:(NSString *)fileName completionHandler:(void (^)(BOOL, NSError *))block
{
    serializer state = _interface->active->serialize();
    NSData *stateData = [NSData dataWithBytes:state.data() length:state.size()];

    __autoreleasing NSError *error = nil;
    BOOL success = [stateData writeToFile:fileName options:NSDataWritingAtomic error:&error];

    block(success, success ? nil : error);
}

- (void)loadStateFromFileAtPath:(NSString *)fileName completionHandler:(void (^)(BOOL, NSError *))block
{
    __autoreleasing NSError *error = nil;
    NSData *state = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe | NSDataReadingUncached error:&error];

    if(state == nil)
    {
        block(NO, error);
        return;
    }

    serializer stateToLoad((const uint8_t *)[state bytes], [state length]);
    if(!_interface->active->unserialize(stateToLoad))
    {
        NSError *error = [NSError errorWithDomain:PVGameCoreErrorDomain code:PVGameCoreCouldNotLoadStateError userInfo:@{
            NSLocalizedDescriptionKey : @"The save state data could not be read",
            NSLocalizedRecoverySuggestionErrorKey : [NSString stringWithFormat:@"Could not read the file state in %@.", fileName]
        }];
        block(NO, error);
        return;
    }

    block(YES, nil);
}

#pragma mark - Input

static const int inputMapSuperFamicom [] = {4, 5, 6, 7, 8, 0, 9, 1,10, 11, 3, 2};

- (oneway void)pushSNESButton:(PVSNESButton)button
{
    _interface->inputState[0][inputMapSuperFamicom[button]] = 1;
}

- (oneway void)releaseSNESButton:(PVSNESButton)button
{
    _interface->inputState[0][inputMapSuperFamicom[button]] = 0;
}

static const int inputMapGameBoyAdvance [] = {6, 7, 5, 4, 0, 1, 9, 8, 3, 2};

- (oneway void)pushGBAButton:(PVGBAButton)button
{
    _interface->inputState[0][inputMapGameBoyAdvance[button]] = 1;
}

- (oneway void)releaseGBAButton:(PVGBAButton)button
{
    _interface->inputState[0][inputMapGameBoyAdvance[button]] = 0;
}

static const int inputMapGameBoy [] = {0, 1, 2, 3, 5, 4, 7, 6};
static const int inputMapSuperGameBoy [] = {4, 5, 6, 7, 8, 0, 3, 2};

- (oneway void)pushGBButton:(PVGBButton)button
{
    if(_interface->activeSystem == PVGameBoySystem)
        _interface->inputState[0][inputMapGameBoy[button]] = 1;
    else
        _interface->inputState[0][inputMapSuperGameBoy[button]] = 1;
}

- (oneway void)releaseGBButton:(PVGBButton)button
{
    if(_interface->activeSystem == PVGameBoySystem)
        _interface->inputState[0][inputMapGameBoy[button]] = 0;
    else
        _interface->inputState[0][inputMapSuperGameBoy[button]] = 0;
}

static const int inputMapFamicom [] = {4, 5, 6, 7, 0, 1, 3, 2};

- (oneway void)pushNESButton:(PVNESButton)button
{
    _interface->inputState[0][inputMapFamicom[button]] = 1;
}

- (oneway void)releaseNESButton:(PVNESButton)button
{
    _interface->inputState[0][inputMapFamicom[button]] = 0;
}

@end
