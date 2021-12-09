//
//  IMPLogging.h
//  Tests
//
//  Created by Vladimir on 7/9/20.
//  Copyright © 2020 Mind Blown Apps, LLC. All rights reserved.
//

// DEBUG MODE
// Add the following macro to your project to activate verbose logging:
// #define IMPROVE_AI_DEBUG
// Make sure, that macro is defined before Improve framework import.
// The best place to define this macro is a Prefix Header.

@import os.log;

#ifndef IMPLogging_h
#define IMPLogging_h

/**
 IMPLog is for any debug data. Outputs only if
 1) running app in Debug scheme (DEBUG=1 is defined) and
 2) IMPROVE_AI_DEBUG macro is defined in the project
 Format: "-/+[<class> <method>] L<line> <formatted message>"
 */
#if defined DEBUG && defined IMPROVE_AI_DEBUG
#   define IMPLog(fmt, ...) os_log_debug(OS_LOG_DEFAULT, ("[improve.ai] %s L%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define IMPLog(...) (void)0
#endif

/**
 IMPErrLog is for errors and critical debug messages. Saved to the data store both in testing and production.
 Format: "-/+[<class> <method>] L<line> <formatted message>"
 */
#define IMPErrLog(fmt, ...) os_log_error(OS_LOG_DEFAULT, ("[improve.ai] %s L%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#endif /* IMPLogging_h */
