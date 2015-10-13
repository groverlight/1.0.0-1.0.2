
//! \file   ParseTemplateClass.h
//! \brief  Template class to use to build any other Parse based class.
//__________________________________________________________________________________________________

#import <Parse/PFObject+Subclass.h>
//__________________________________________________________________________________________________

//! Template class to use to build any other Parse based class.
@interface ParseTemplateClass : PFObject
{
}
//____________________

//! Return the name of the class.
+ (NSString*)parseClassName;
//____________________

@end
//__________________________________________________________________________________________________
