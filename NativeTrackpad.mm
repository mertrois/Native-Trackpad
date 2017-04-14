
#include <Core/CoreAll.h>
#include <Fusion/FusionAll.h>
#include <CAM/CAMAll.h>

#include <math.h>

#include <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>

using namespace adsk::core;
using namespace adsk::fusion;
using namespace adsk::cam;

Ptr<Application> app;
Ptr<UserInterface> ui;

void zoom(double magnification) {
    auto camera = app->activeViewport()->camera();
    camera->isSmoothTransition(false);
    
    auto viewExtents = camera->viewExtents();
    
    magnification *= -3;
    
    if(magnification > 0) {
        viewExtents *= magnification + 1;
    }
    else {
        viewExtents /= -magnification + 1;
    }
    
    camera->viewExtents(viewExtents);
    
    app->activeViewport()->camera(camera);
    app->activeViewport()->refresh();
}

void orbit(double deltaX, double deltaY) {
    Ptr<Camera> camera = app->activeViewport()->camera();
    camera->isSmoothTransition(false);
    
    Ptr<Point3D> eye = camera->eye();
    eye->x(eye->x() + deltaX);
    eye->y(eye->y() + deltaY);
    camera->eye(eye);
    
    app->activeViewport()->camera(camera);
    app->activeViewport()->refresh();
}

Ptr<Vector3D> getViewportCameraRightVector() {
    auto camera = app->activeViewport()->camera();
    
    auto right = camera->upVector();
    
    auto rotation = Matrix3D::create();
    auto axis = camera->eye()->vectorTo(camera->target());
    rotation->setToRotation(M_PI / 2, axis, Point3D::create(0, 0, 0));
    right->transformBy(rotation);
    
    return right;
}

double getViewportCameraTargetDistance() {
    auto camera = app->activeViewport()->camera();
    return camera->eye()->distanceTo(camera->target()) + camera->viewExtents();
}

void panViewportCameraByVector(Ptr<Vector3D> vector) {
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

void pan(double deltaX, double deltaY) {
    auto distance = getViewportCameraTargetDistance();
    
    deltaX = distance * deltaX / 10000 * -1;
    deltaY = distance * deltaY / 10000;
    
    auto right = getViewportCameraRightVector();
    right->scaleBy(deltaX);
    
    auto up = app->activeViewport()->camera()->upVector();
    up->scaleBy(deltaY);
    
    right->add(up);
    
    panViewportCameraByVector(right);
}

void install() {
    NSEvent * (^handler)(NSEvent*);
    handler = ^NSEvent*(NSEvent* event) {
        if(event.modifierFlags & NSEventModifierFlagShift) {
            orbit(event.scrollingDeltaX, event.scrollingDeltaY);
            return nil;
        }
        
        if(event.modifierFlags == 0) {
            pan(event.scrollingDeltaX, event.scrollingDeltaY);
            return nil;
        }
        
        return event;
    };
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskScrollWheel handler:handler];
    
    NSEvent * (^handlerMagnify)(NSEvent*);
    handlerMagnify = ^NSEvent*(NSEvent* event) {
        zoom(event.magnification);
        return event;
    };
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskMagnify handler:handlerMagnify];
}

extern "C" XI_EXPORT bool run(const char* context) {
    app = Application::get();
    if (!app) { return false; }
    
    ui = app->userInterface();
    if (!ui) { return false; }
    
    install();
    
    return true;
}

extern "C" XI_EXPORT bool stop(const char* context) {
    return true;
}
