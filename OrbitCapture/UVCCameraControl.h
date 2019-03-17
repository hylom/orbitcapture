/*
 * UVCCameraControl is written by Dominic Szablewski (https://phoboslab.org/log/2009/07/uvc-camera-control-for-mac-os-x),
 *  kazu (https://github.com/kazu/UVCCameraControl),
 *  and hylom (https://github.com/hylom).
 */

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#include <CoreFoundation/CoreFoundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>


#define UVC_INPUT_TERMINAL_ID 0x01
#define UVC_PROCESSING_UNIT_ID 0x02

// for Logitech LXU
#define UVC_LOGITECH_MOTOR 0x9


//TODO: use guid instead of unit id
//#define UVC_GUID_INPUT_TERMINAL_ID {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, \
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01}
//#define UVC_GUID_PROCESSING_UNIT_ID {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, \
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02}
//#define UVC_GUID_LOGITECH_MOTOR {0x82, 0x06, 0x61, 0x63, 0x70, 0x50, 0xab, 0x49, \
0xb8, 0xcc, 0xb3, 0x85, 0x5e, 0x8d, 0x22, 0x56}


#define LXU_MOTOR_PANTILT_RELATIVE_CONTROL              0x01
#define LXU_MOTOR_PANTILT_RESET_CONTROL                 0x02
#define LXU_MOTOR_FOCUS_MOTOR_CONTROL                   0x03

#define XU_HW_CONTROL_LED1               1
#define XU_MOTORCONTROL_PANTILT_RELATIVE 1
#define XU_MOTORCONTROL_PANTILT_RESET    2
#define XU_MOTORCONTROL_FOCUS            3

#define UVC_CONTROL_INTERFACE_CLASS 14
#define UVC_CONTROL_INTERFACE_SUBCLASS 1
	
#define UVC_SET_CUR	0x01
#define UVC_GET_CUR	0x81
#define UVC_GET_MIN	0x82
#define UVC_GET_MAX	0x83

#define UVC_GET_RES 0x84
#define UVC_GET_LEN 0x85
#define UVC_GET_INFO 0x86
#define UVC_GET_DEF 0x87


typedef struct {
	int min, max;
} uvc_range_t;

typedef struct {
	int unit;
	int selector;
	int size;
} uvc_control_info_t;

typedef struct {
	uvc_control_info_t autoExposure;
	uvc_control_info_t exposure;
    uvc_control_info_t zoomrel;
    uvc_control_info_t zoom;
	uvc_control_info_t autoFocus;
	uvc_control_info_t pantiltrel;
	uvc_control_info_t pantilt_reset;
	uvc_control_info_t brightness;
	uvc_control_info_t contrast;
	uvc_control_info_t gain;
	uvc_control_info_t saturation;
	uvc_control_info_t sharpness;
	uvc_control_info_t whiteBalance;
	uvc_control_info_t autoWhiteBalance;
} uvc_controls_t ;


@interface UVCCameraControl : NSObject {
	long dataBuffer;
	IOUSBInterfaceInterface190 **interface;
}


- (id)initWithLocationID:(UInt32)locationID;
- (id)initWithVendorID:(long)vendorID productID:(long)productID;
- (IOUSBInterfaceInterface190 **)getControlInferaceWithDeviceInterface:(IOUSBDeviceInterface **)deviceInterface;

- (BOOL)sendControlRequest:(IOUSBDevRequest)controlRequest;
- (BOOL)setData:(long)value withLength:(int)length forSelector:(int)selector at:(int)unitID;
- (BOOL)setData2:(void *)value withLength:(int)length forSelector:(int)selector at:(int)unitID;

- (long)getDataFor:(int)type withLength:(int)length fromSelector:(int)selector at:(int)unitID;

- (uvc_range_t)getRangeForControl:(const uvc_control_info_t *)control;
- (float)mapValue:(float)value fromMin:(float)fromMin max:(float)fromMax toMin:(float)toMin max:(float)toMax;
- (float)getValueForControl:(const uvc_control_info_t *)control;
- (BOOL)setValue:(float)value forControl:(const uvc_control_info_t *)control;

- (BOOL)setAutoExposure:(BOOL)enabled;
- (BOOL)setPanTiltRelative:(BOOL)reset withPan:(int)pan withTilt:(int)tilt;
- (BOOL)setZoomRelative:(int)zoom_rel withSpeed:(int)speed;
- (BOOL)setZoom:(int)value;
- (BOOL)resetTiltPan:(BOOL)enabled;
- (BOOL)getAutoExposure;
- (BOOL)setExposure:(float)value;
- (float)getZoom;
- (float)getExposure;
- (BOOL)setGain:(float)value;
- (float)getGain;
- (BOOL)setBrightness:(float)value;
- (float)getBrightness;
- (BOOL)setContrast:(float)value;
- (float)getContrast;
- (BOOL)setSaturation:(float)value;
- (float)getSaturation;
- (BOOL)setSharpness:(float)value;
- (float)getSharpness;
- (BOOL)setAutoWhiteBalance:(BOOL)enabled;
- (BOOL)getAutoWhiteBalance;
- (BOOL)setWhiteBalance:(float)value;
- (float)getWhiteBalance;
- (BOOL)listOfUVCdevice:(UInt32)deviceclass;

@end
