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

#import <UIKit/UIKit.h>
#import <PVEmulatorCore.h>

typedef NS_ENUM(NSUInteger, PVSNESButton)
{
    PVSNESButtonUp,
    PVSNESButtonDown,
    PVSNESButtonLeft,
    PVSNESButtonRight,
    PVSNESButtonA,
    PVSNESButtonB,
    PVSNESButtonX,
    PVSNESButtonY,
    PVSNESButtonTriggerLeft,
    PVSNESButtonTriggerRight,
    PVSNESButtonStart,
    PVSNESButtonSelect,
    PVSNESButtonCount,
};

typedef NS_ENUM(NSUInteger, PVGBAButton)
{
    PVGBAButtonUp,
    PVGBAButtonDown,
    PVGBAButtonLeft,
    PVGBAButtonRight,
    PVGBAButtonA,
    PVGBAButtonB,
    PVGBAButtonL,
    PVGBAButtonR,
    PVGBAButtonStart,
    PVGBAButtonSelect,
    PVGBAButtonSpeed,
    PVGBAButtonCapture,
    PVGBAButtonCount
};

typedef NS_ENUM(NSUInteger, PVGBButton)
{
    PVGBButtonUp,
    PVGBButtonDown,
    PVGBButtonLeft,
    PVGBButtonRight,
    PVGBButtonA,
    PVGBButtonB,
    PVGBButtonStart,
    PVGBButtonSelect,
    PVGBButtonCount,
};

typedef NS_ENUM(NSUInteger, PVNESButton)
{
    PVNESButtonUp,
    PVNESButtonDown,
    PVNESButtonLeft,
    PVNESButtonRight,
    PVNESButtonA,
    PVNESButtonB,
    PVNESButtonStart,
    PVNESButtonSelect,
    PVNESButtonCount
};

@interface PVSNESEmulatorCore : PVEmulatorCore

- (oneway void)pushSNESButton:(PVSNESButton)button;
- (oneway void)releaseSNESButton:(PVSNESButton)button;
- (oneway void)pushGBAButton:(PVGBAButton)button;
- (oneway void)releaseGBAButton:(PVGBAButton)button;
- (oneway void)pushGBButton:(PVGBButton)button;
- (oneway void)releaseGBButton:(PVGBButton)button;
- (oneway void)pushNESButton:(PVNESButton)button;
- (oneway void)releaseNESButton:(PVNESButton)button;

@end
