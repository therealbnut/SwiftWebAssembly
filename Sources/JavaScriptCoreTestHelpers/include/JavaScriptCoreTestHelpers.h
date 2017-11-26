//
//  JavaScriptCoreTestHelpers.h
//
//  Created by Andrew Bennett on 26/11/17.
//

#ifndef _JavaScriptCoreTestHelpers_h_
#define _JavaScriptCoreTestHelpers_h_

#import <JavaScriptCore/JavaScriptCore.h>

#ifdef __cplusplus
extern "C" {
#endif

JS_EXPORT void JSSynchronousGarbageCollectForDebugging(JSContextRef);

#ifdef __cplusplus
}
#endif

#endif // _JavaScriptCoreTestHelpers_h_
