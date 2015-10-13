
//! \file   ParseBase.h
//! \brief  Base class of any Parse based class.
//__________________________________________________________________________________________________

#import <Parse/Parse.h>
//__________________________________________________________________________________________________

//! Base class of any Parse based class.
@interface ParseBase : PFObject<PFSubclassing>
{
}
//____________________

//! Get the Parse class name.
+ (NSString*)parseClassName;
//____________________

@end
//__________________________________________________________________________________________________
