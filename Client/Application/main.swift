/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared

private var appDelegate: AppDelegate.Type

if AppConstants.IsRunningTest {
    appDelegate = TestAppDelegate.self
} else {
#if BRAVE
  appDelegate = AppDelegate.self
#else
  switch AppConstants.BuildChannel {
    case .Aurora:
        appDelegate = AuroraAppDelegate.self
    case .Developer:
        appDelegate = AppDelegate.self
    case .Release:
        appDelegate = AppDelegate.self
    }
#endif
}

UIApplicationMain(Process.argc, Process.unsafeArgv, NSStringFromClass(UIApplication.self), NSStringFromClass(appDelegate))