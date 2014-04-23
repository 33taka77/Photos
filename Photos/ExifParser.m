//
//  ExifParser.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/04/06.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "ExifParser.h"

#define BS_BYTE1(x)     (x &0xFF)
#define BS_BYTE2(x)     ((x >> 8)&0xFF)
#define BS_BYTE3(x)     ((x >> 16)&0xFF)
#define BS_BYTE4(x)     ((x >> 24)&0xFF)
#define INV_INT16(x)    ( (unsigned short)( (BS_BYTE1(x)<<8)|BS_BYTE2(x)) )
#define INV_INT32(x)    ( BS_BYTE1(x)<<24|BS_BYTE2(x)<<16|BS_BYTE3(x)<<8|BS_BYTE4(x) )

@interface ExifParser()
{
    BOOL islittleEndian;
    BOOL isMachineLittleEndian;
}
@end

@implementation ExifParser
- (unsigned short)convert16:(unsigned short)value16
{
    unsigned short retVal = value16;
    if( islittleEndian != isMachineLittleEndian ){
        retVal = INV_INT16(value16);
    }
    return retVal;
}
- (unsigned long)convert32:(unsigned long)value32
{
    unsigned long retVal = value32;
    if( islittleEndian != isMachineLittleEndian ){
        retVal = INV_INT32(value32);
    }
    return retVal;
}

- (void)parseExifHeader:(uint8_t *)imageData
{
    
    if( CFByteOrderGetCurrent() == CFByteOrderLittleEndian )
    {
        isMachineLittleEndian = YES;
    }else{
        isMachineLittleEndian = NO;
    }
    
    unsigned short* pData = (unsigned short*)imageData;
    unsigned short endian = *pData;
    if( endian == 0x4949 )
    {
        islittleEndian = YES;
    }else{
        islittleEndian = NO;
    }
    pData++;
    pData++;
    unsigned long* pOffset = (unsigned long*)pData;
    unsigned long offset = *pOffset;
    
    uint8_t* p0ThIFD =  imageData+ [self convert16:offset];
    IFDData* pIfd = (IFDData*)p0ThIFD;
    
}

@end
