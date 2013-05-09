//
//  MHConverter.m
//  
//
//  Created by Tulakshana on 06/05/2013.
//  
//

#import "MHConverter.h"

#import "CommonDefinitions.h"

@implementation MHConverter

- (NSString *)getHTML:(NSString *)string{
    if ([string length] <= 0) {
        return @"";
    }
    string = [self makeBold:string];
    string = [self makeItalic:string]; 
    
    string = [self makeList:string];
    string = [self makeHeaders:string];
    string = [self makeImage:string];
    string = [self makeLink:string];
    

    string = [self makeLineBreaks:string];
    
    
    return string;
}

- (NSString *)makeItalic:(NSString *)string{

    NSString *regString = @"[\\*\\_].*[\\_\\*]";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regString options:NSRegularExpressionCaseInsensitive error:&error];
    string = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@"<i>$0</i>"];
    
    NSArray *array = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    for (int i = 0; i < [array count]; i++) {
        NSTextCheckingResult *result = [array objectAtIndex:i];
        DLog(@"%d %d",result.range.length,result.range.location);
        NSString *match = [string substringWithRange:result.range];
        DLog(@"%@",match);
    }
    DLog(@"%@",string);
    string = [string stringByReplacingOccurrencesOfString:@"<i>*" withString:@"<i>"];
    string = [string stringByReplacingOccurrencesOfString:@"*</i>" withString:@"</i>"];
    string = [string stringByReplacingOccurrencesOfString:@"<i>_" withString:@"<i>"];
    string = [string stringByReplacingOccurrencesOfString:@"_</i>" withString:@"</i>"];

    return string;
}

- (NSString *)makeBold:(NSString *)string{

//    NSString *regString = @"[\\*_]+[\\*_]+[a-zA-Z0-9\"\\'\\?\\!\\;\\:\\#\\$\\%\\&\\(\\)\\*\\+\\-\\/\\<\\>\\=\\@\\[\\]\\\\^\\_\\{\\}\\|\\~ \\.]+[\\*_]+[\\*_]";
    NSString *regString = @"[\\*\\_][\\*\\_].*[\\_\\*][\\_\\*]";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regString options:NSRegularExpressionCaseInsensitive error:&error];
    string = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@"<strong>$0</strong>"];
    string = [string stringByReplacingOccurrencesOfString:@"<strong>**" withString:@"<strong>"];
    string = [string stringByReplacingOccurrencesOfString:@"**</strong>" withString:@"</strong>"];
    string = [string stringByReplacingOccurrencesOfString:@"<strong>__" withString:@"<strong>"];
    string = [string stringByReplacingOccurrencesOfString:@"__</strong>" withString:@"</strong>"];

    return string;
}

- (NSString *)makeImage:(NSString *)string{
    //![alt text](/path/img.jpg "Title")
    DLog(@"%@",string);
    NSMutableArray *replacements = [[NSMutableArray alloc]init];
//    NSString *regString = @"[\\!]+[\\[]+[a-zA-Z0-9\"\\'\\?\\!\\;\\:\\#\\$\\%\\&\\*\\+\\-\\/\\<\\>\\=\\@\\\\^\\_\\{\\}\\|\\~\\s\\.]+[\\]]+[\\(]+[a-zA-Z0-9\"\\'\\?\\!\\;\\:\\#\\$\\%\\&\\*\\+\\-\\/\\<\\>\\=\\@\\\\^\\_\\{\\}\\|\\~\\.\\s]+[\\)]";
    NSString *regString = @"[\\!][\\[].*[\\]][\\(].*[\\)]";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regString options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *array = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    for (int i = 0; i < [array count]; i++) {
        NSTextCheckingResult *result = [array objectAtIndex:i];
        DLog(@"%d %d",result.range.length,result.range.location);
        NSString *match = [string substringWithRange:result.range];
        DLog(@"%@",match);
        //duplicates will get replace but not removed from the array
        //check whether text in range is not alreay replace
        if ([[match substringToIndex:1] isEqualToString:@"!"]) {
            NSScanner *theScanner;
            NSString *text = nil;
            
            theScanner = [NSScanner scannerWithString:match];
            
            NSString *image = @"<img alt=\"";
            
            
            
            // find start of tag
            [theScanner scanUpToString:@"[" intoString:NULL] ;
            // find end of tag
            [theScanner scanUpToString:@"]" intoString:&text] ;
            
            // replace the found tag with a space
            //(you can filter multi-spaces out later if you wish)
            image = [NSString stringWithFormat:@"%@%@\"",image,[text substringFromIndex:1]];
            
            
            
            text = nil;
            
            
            // find start of tag
            [theScanner scanUpToString:@"(" intoString:NULL] ;
            // find end of tag
            [theScanner scanUpToString:@")" intoString:&text] ;
            
            // replace the found tag with a space
            //(you can filter multi-spaces out later if you wish)
            text = [text substringFromIndex:1];
            NSArray *componants = [text componentsSeparatedByString:@" "];
            NSString *url = @"";
            NSString *title = @"\"\"";
            if ([componants count]>1) {
                url = [componants objectAtIndex:0];
                title = [text stringByReplacingOccurrencesOfString:url withString:@""];
            }else {
                url = text;
            }
            image = [NSString stringWithFormat:@"%@ src=\"%@\" title=%@ />",image,url,title];
            
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:match,@"match",image,@"replacement", nil];
            [replacements addObject:dic];
            DLog(@"%@",string);

        }

    }
    
    for (int j = 0; j < [replacements count]; j++) {
        NSDictionary *dic = [replacements objectAtIndex:j];
        string = [string stringByReplacingOccurrencesOfString:[dic valueForKey:@"match"] withString:[dic valueForKey:@"replacement"]];
    }
    [replacements release];

    return string;
}

- (NSString *)makeLink:(NSString *)string{
    //![alt text](/path/img.jpg "Title")
    DLog(@"%@",string);
    NSMutableArray *replacements = [[NSMutableArray alloc]init];
//    NSString *regString = @"[\\[]+[a-zA-Z0-9\"\\'\\?\\!\\;\\:\\#\\$\\%\\&\\*\\+\\-\\/\\<\\>\\=\\@\\\\^\\_\\{\\}\\|\\~\\s\\.]+[\\]]+[\\(]+[a-zA-Z0-9\"\\'\\?\\!\\;\\:\\#\\$\\%\\&\\*\\+\\-\\/\\<\\>\\=\\@\\\\^\\_\\{\\}\\|\\~\\.\\s]+[\\)]";
        NSString *regString = @"[\\[].*[\\]][\\(].*[\\)]";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regString options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *array = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    for (int i = 0; i < [array count]; i++) {
        NSTextCheckingResult *result = [array objectAtIndex:i];
        DLog(@"%d %d",result.range.length,result.range.location);
        NSString *match = [string substringWithRange:result.range];
        DLog(@"%@",match);
        
        NSScanner *theScanner;
        NSString *text = nil;
        if ([[match substringToIndex:1] isEqualToString:@"["]) {
            theScanner = [NSScanner scannerWithString:match];
            
            NSString *image = @"<a";
            NSString *linkedText = nil;
            
            // find start of tag
            [theScanner scanUpToString:@"[" intoString:NULL] ;
            // find end of tag
            [theScanner scanUpToString:@"]" intoString:&text] ;
            
            // replace the found tag with a space
            //(you can filter multi-spaces out later if you wish)
            linkedText = [text substringFromIndex:1];
            
            text = nil;
            
            // find start of tag
            [theScanner scanUpToString:@"(" intoString:NULL] ;
            // find end of tag
            [theScanner scanUpToString:@")" intoString:&text] ;
            
            // replace the found tag with a space
            //(you can filter multi-spaces out later if you wish)
            text = [text substringFromIndex:1];
            NSArray *componants = [text componentsSeparatedByString:@" "];
            NSString *url = @"";
            NSString *title = @"\"\"";
            if ([componants count]>1) {
                url = [componants objectAtIndex:0];
                title = [text stringByReplacingOccurrencesOfString:url withString:@""];
            }else {
                url = text;
            }
            image = [NSString stringWithFormat:@"%@ href=\"%@\" title=%@ >%@</a>",image,url,title,linkedText];
            
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:match,@"match",image,@"replacement", nil];
            [replacements addObject:dic];
            DLog(@"%@",string);

        }
        

    }

    for (int j = 0; j < [replacements count]; j++) {
        NSDictionary *dic = [replacements objectAtIndex:j];
        string = [string stringByReplacingOccurrencesOfString:[dic valueForKey:@"match"] withString:[dic valueForKey:@"replacement"]];
    }
    [replacements release];
    
    return string;
}

- (NSString *)makeHeaders:(NSString *)string{
    DLog(@"%@",string);
///^(.+)[ \t]*\n-+[ \t]*\n+/gm
    string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"######"] withString:[NSString stringWithFormat:@"<h6>"]];
    string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"#####"] withString:[NSString stringWithFormat:@"<h5>"]];
    string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"####"] withString:[NSString stringWithFormat:@"<h4>"]];
    string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"###"] withString:[NSString stringWithFormat:@"<h3>"]];
    string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"##"] withString:[NSString stringWithFormat:@"<h2>"]];
    string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"#"] withString:[NSString stringWithFormat:@"<h1>"]];
    DLog(@"%@",string);
    for (int i = 1; i < 7; i++) {
        NSString *regString = nil;
        switch (i) {
            case 1:
                regString = @"[\\<][h][1][\\>].*[\n]";
                break;
            case 2:
                regString = @"[\\<][h][2][\\>].*[\n]";
                break;
            case 3:
                regString = @"[\\<][h][3][\\>].*[\n]";
                break;
            case 4:
                regString = @"[\\<][h][4][\\>].*[\n]";
                break;
            case 5:
                regString = @"[\\<][h][5][\\>].*[\n]";
                break;
            case 6:
                regString = @"[\\<][h][6][\\>].*[\n]";
                break;
            default:
                break;
        }

        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regString options:NSRegularExpressionCaseInsensitive error:&error];
        string = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:[NSString stringWithFormat:@"$0</h%d>",i]];
        DLog(@"%@",string);
        
    }



    return string;
}

- (NSString *)makeList:(NSString *)string{
    DLog(@"%@",string);
    NSString *finalString = @"";
    NSArray *array = [string componentsSeparatedByString:@"\n"];
    BOOL listTagOpened = FALSE;
    for (int i = 0; i < [array count]; i++) {
        NSString *subStr = [array objectAtIndex:i];

            DLog(@"%@",subStr);
            NSString *regString = @"[0-9][\\.][ ].*";
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regString options:NSRegularExpressionCaseInsensitive error:&error];
            int count = [regex numberOfMatchesInString:subStr options:0 range:NSMakeRange(0, [subStr length])];
            if (count == 0) {
                if (listTagOpened) {
                    subStr = [NSString stringWithFormat:@"</ol>%@",subStr];
                    listTagOpened = FALSE;
                }
            }else {
                if (!listTagOpened) {
                    subStr = [regex stringByReplacingMatchesInString:subStr options:0 range:NSMakeRange(0, [subStr length]) withTemplate:@"<ol><li>$0</li>"];
                    listTagOpened = TRUE;
                }else {
                    subStr = [regex stringByReplacingMatchesInString:subStr options:0 range:NSMakeRange(0, [subStr length]) withTemplate:@"<li>$0</li>"];
                }
            }
            
            regString = @"[0-9]+[\\.]+[ ]";
            error = NULL;
            regex = [NSRegularExpression regularExpressionWithPattern:regString options:NSRegularExpressionCaseInsensitive error:&error];
            subStr = [regex stringByReplacingMatchesInString:subStr options:0 range:NSMakeRange(0, [subStr length]) withTemplate:@""];
            
            //        subStr = [subStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            if (listTagOpened) {
                finalString = [NSString stringWithFormat:@"%@%@",finalString,subStr];
            }else {
                finalString = [NSString stringWithFormat:@"%@\n%@",finalString,subStr];
            }
            DLog(@"%@",finalString);

    }
    
    if (listTagOpened) {
        finalString = [NSString stringWithFormat:@"%@</ol>",finalString];
        listTagOpened = FALSE;
    }
    
    array = [finalString componentsSeparatedByString:@"\n"];
    finalString = @"";
    for (int i = 0; i < [array count]; i++) {
        NSString *subStr = [array objectAtIndex:i];
        
        DLog(@"%@",subStr);
        NSString *regString = @"[\\*][ ].*";
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regString options:NSRegularExpressionCaseInsensitive error:&error];
        int count = [regex numberOfMatchesInString:subStr options:0 range:NSMakeRange(0, [subStr length])];
        
        
        
        if (count == 0) {
            if (listTagOpened) {
                subStr = [NSString stringWithFormat:@"</ul>%@",subStr];
                listTagOpened = FALSE;
            }
            
        }else {
            if (!listTagOpened) {
                subStr = [regex stringByReplacingMatchesInString:subStr options:0 range:NSMakeRange(0, [subStr length]) withTemplate:@"<ul><li>$0</li>"];
                listTagOpened = TRUE;
            }else {
                subStr = [regex stringByReplacingMatchesInString:subStr options:0 range:NSMakeRange(0, [subStr length]) withTemplate:@"<li>$0</li>"];
            }
        }
        
        regString = @"[\\*]+[ ]";
        error = NULL;
        regex = [NSRegularExpression regularExpressionWithPattern:regString options:NSRegularExpressionCaseInsensitive error:&error];
        subStr = [regex stringByReplacingMatchesInString:subStr options:0 range:NSMakeRange(0, [subStr length]) withTemplate:@""];
        
        //        subStr = [subStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if (listTagOpened) {
            finalString = [NSString stringWithFormat:@"%@%@",finalString,subStr];
        }else {
            finalString = [NSString stringWithFormat:@"%@\n%@",finalString,subStr];
        }
        DLog(@"%@",finalString);
        
    }
    
    if (listTagOpened) {
        finalString = [NSString stringWithFormat:@"%@</ul>",finalString];
        listTagOpened = FALSE;
    }
    
    
    finalString = [finalString stringByReplacingOccurrencesOfString:@"<li></li>" withString:@""];
    if ([finalString length] <=0) {
        finalString = string;
    }
    
    DLog(@"%@",finalString);
    
    return finalString;
}

- (NSString *)makeLineBreaks:(NSString *)string{
    return [string stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
}

@end
