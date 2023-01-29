#include <Core/CoreAll.h>
#include <Fusion/FusionAll.h>
#include <Cam/CAMAll.h>

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

void orbit(double deltaX, double deltaY) {
    auto camera = app->activeViewport()->camera();
    camera->isSmoothTransition(false);

    deltaX = M_PI * deltaX / 300;
    deltaY = M_PI * deltaY / 300;

    auto up = camera->upVector();
    up->normalize();
    auto right = getViewportCameraRightVector();
    right->normalize();

    auto target = camera->target();
    auto eyeToTarget = target->vectorTo(camera->eye());

    auto origin = Point3D::create();

    auto rotation = adsk::core::Matrix3D::create();
    rotation->setToRotation(deltaX, up, origin);
    eyeToTarget->transformBy(rotation);

    rotation->setToRotation(deltaY, right, origin);
    eyeToTarget->transformBy(rotation);

    // TODO(ibash) handle isOk is false
    auto isOk = eyeToTarget->add(target->asVector());

    camera->eye(eyeToTarget->asPoint());

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
 * 5 = orbit
 */
int howWeShouldHandleEvent(NSEvent* event) {
    // TODO handle only events to QTCanvas

    if (event.type != NSEventTypeScrollWheel && event.type != NSEventTypeMagnify && event.type != NSEventTypeGesture && event.type != NSEventTypeSmartMagnify) {
        return 0;
    }

    if (!app->activeViewport()) {
        return 0;
    }

    if (![event.window.title hasPrefix: @"Autodesk Fusion 360"]) {
        return 0;
    }

    // shift is for oribting
    // macos will send both NSEventTypeGesture and NSEventTypeScrollWheel, we
    // ignore the former (or else fusion360 will handle orbit too) and handle
    // the latter.

    if ((event.modifierFlags & NSEventModifierFlagShift) &&
        event.type == NSEventTypeGesture) {
      return 1;
    }

    if ((event.modifierFlags & NSEventModifierFlagShift) &&
        event.type == NSEventTypeScrollWheel) {
      return 5;
    }

    // other modified events are passed on to fusion360
    if (event.modifierFlags != 0) {
      return 0;
    }

    if (event.type == NSEventTypeGesture) {
        return 1;
    }

    if (event.type == NSEventTypeScrollWheel) {
        return 2;
    }

    if (event.type == NSEventTypeMagnify) {
        return 3;
    }

    if (event.type == NSEventTypeSmartMagnify) {
        return 4;
    }

    return 0;
}


/**
 * Method swizzling here
 */
@implementation NSApplication (Tracking)
- (void)mySendEvent:(NSEvent *)event {
    int result = howWeShouldHandleEvent(event);
    if (result == 0) {
       [self mySendEvent:event];
    } else if(result == 1) {
        // noop
    } else if(result == 2) {
        pan(event.scrollingDeltaX, event.scrollingDeltaY);
    } else if(result == 3) {
        zoom(event.magnification);
    } else if(result == 4) {
        zoomToFit();
    } else if(result == 5) {
      orbit(event.scrollingDeltaX, event.scrollingDeltaY);
    }
}

- (void)nativeTrackpad {
    Method original = class_getInstanceMethod([self class], @selector(sendEvent:));
    Method swizzled = class_getInstanceMethod([self class], @selector(mySendEvent:));

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
 * Stop overriding events
 */
extern "C" XI_EXPORT bool stop(const char* context) {
    // this is the same as run since we just need to swap the sendEvent implementations back
    app = Application::get();
    if (!app) { return false; }

    ui = app->userInterface();
    if (!ui) { return false; }

    [NSApplication.sharedApplication nativeTrackpad];

    return true;
}
