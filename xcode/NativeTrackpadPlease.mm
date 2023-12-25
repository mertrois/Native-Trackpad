#include <Core/CoreAll.h>
#include <Fusion/FusionAll.h>
#include <Cam/CamAll.h>

#include <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>

#import <objc/runtime.h>

using namespace adsk::core;
using namespace adsk::fusion;
using namespace adsk::cam;

adsk::core::Ptr<Application> app;
adsk::core::Ptr<UserInterface> ui;


/**
 * Helper function
 */
adsk::core::Ptr<Vector3D> getViewportCameraRightVector() {
    auto camera = app->activeViewport()->camera();
    
    auto right = camera->upVector();
    
    auto rotation = Matrix3D::create();
    auto axis = camera->eye()->vectorTo(camera->target());
    rotation->setToRotation(M_PI / 2, axis, Point3D::create(0, 0, 0));
    right->transformBy(rotation);
    
    return right;
}

/**
 * Helper function
 */
void panViewportCameraByVector(adsk::core::Ptr<Vector3D> vector) {
    auto camera = app->activeViewport()->camera();
    camera->isSmoothTransition(false);
    
    auto eye = camera->eye();
    eye->translateBy(vector);
    camera->eye(eye);
    
    auto target = camera->target();
    target->translateBy(vector);
    camera->target(target);
    
    app->activeViewport()->camera(camera);
    app->activeViewport()->refresh();
}

/**
 * Panning logic
 */
void pan(double deltaX, double deltaY) {
    auto camera = app->activeViewport()->camera();
    
    if (camera->cameraType() == OrthographicCameraType) {
        auto distance = sqrt(camera->viewExtents());
        
        deltaX *= distance / 500 * -1;
        deltaY *= distance / 500;
    }
    else {
        auto distance = camera->eye()->distanceTo(camera->target());
        
        deltaX *= distance / 2000 * -1;
        deltaY *= distance / 2000;
    }
    
    auto right = getViewportCameraRightVector();
    right->scaleBy(deltaX);
    
    auto up = app->activeViewport()->camera()->upVector();
    up->scaleBy(deltaY);
    
    right->add(up);
    
    panViewportCameraByVector(right);
}


/**
 * Zoom logic
 */
void zoom(double magnification) {
    // TODO zoom to mouse cursor
    
    auto camera = app->activeViewport()->camera();
    camera->isSmoothTransition(false);
    
    if (camera->cameraType() == OrthographicCameraType) {
        auto viewExtents = camera->viewExtents();
        camera->viewExtents(viewExtents + viewExtents * -magnification * 2);
    }
    else {
        auto eye = camera->eye();
        auto step = eye->vectorTo(camera->target());
        
        step->scaleBy(magnification * 0.9);
        
        eye->translateBy(step);
        camera->eye(eye);
    }
    
    app->activeViewport()->camera(camera);
    app->activeViewport()->refresh();
}

/**
 * Zoom to fit
 */
void zoomToFit() {
    ui->commandDefinitions()->itemById("FitCommand")->execute();
    app->activeViewport()->refresh();
}

/**
 * This function determines how we handle every event in app
 * Returns:
 * 0 = no change
 * 1 = discard event
 * 2 = pan
 * 3 = zoom
 * 4 = zoom to fit
 */
int howWeShouldHandleEvent(NSEvent* event) {
    // TODO handle only events to QTCanvas
    
    if (event.type == NSEventTypeGesture) {
        if (event.modifierFlags != 0 || !app->activeViewport() || ![event.window.title hasPrefix: @"Autodesk Fusion 360"]) {
            return 0;
        }
        return 1;
    }
    if (event.type == NSEventTypeScrollWheel) {
        if (event.modifierFlags != 0 || !app->activeViewport() || ![event.window.title hasPrefix: @"Autodesk Fusion 360"]) {
            return 0;
        }
        return 2;
    }
    if (event.type == NSEventTypeMagnify) {
        if (event.modifierFlags != 0 || !app->activeViewport() || ![event.window.title hasPrefix: @"Autodesk Fusion 360"]) {
            return 0;
        }
        return 3;
    }
    if (event.type == NSEventTypeSmartMagnify) {
        if (event.modifierFlags != 0 || !app->activeViewport() || ![event.window.title hasPrefix: @"Autodesk Fusion 360"]) {
            return 0;
        }
        return 4;
    }
    
    return 0;
}


/**
 * Method swizzling here
 */
@implementation NSApplication (Tracking)
- (void)mySendEvent2:(NSEvent *)event {
    int result = howWeShouldHandleEvent(event);
    if (result == 0) {
        [self mySendEvent2:event];
    } else if(result == 1) {
        // noop
    } else if(result == 2) {
        pan(event.scrollingDeltaX, event.scrollingDeltaY);
    } else if(result == 3) {
        zoom(event.magnification);
    } else if(result == 4) {
        zoomToFit();
    }
}

- (void)nativeTrackpad {
    Method original = class_getInstanceMethod([self class], @selector(sendEvent:));
    Method swizzled = class_getInstanceMethod([self class], @selector(mySendEvent2:));
    
    method_exchangeImplementations(original, swizzled);
}
@end

/**
 * Main entry here
 */
extern "C" XI_EXPORT bool run(const char* context) {
    app = Application::get();
    if (!app) { return false; }
    
    ui = app->userInterface();
    if (!ui) { return false; }
    
    [NSApplication.sharedApplication nativeTrackpad];
    
    return true;
}

/**
 * Stop function not implemented
 */
extern "C" XI_EXPORT bool stop(const char* context) {
    return true;
}
