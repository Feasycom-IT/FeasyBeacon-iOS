/*
 *******************************************************************************
 *
 * Copyright (C) 2019-2020 Dialog Semiconductor.
 * 该计算机程序包含 Dialog Semiconductor 的机密和专有信息。版权所有。
 *
 *******************************************************************************
 */

/*!
 @header SuotaFile.h
 @brief SuotaFile 类的头文件。
 
 该头文件包含 SuotaFile 类的方法和属性声明。
 
 @copyright 2019 Dialog Semiconductor
 */

#import <Foundation/Foundation.h>

@class HeaderInfo;

/*!
 * @class SuotaFile
 *
 * @discussion 表示固件文件的类，包含文件路径、URL、文件名、文件头信息以及有关固件文件的各种属性。
 *
 */
@interface SuotaFile : NSObject

/*!
 * @property file
 *
 * @discussion 绝对文件路径。使用 {@link NSString} 类型来存储文件路径。
 */
@property NSString* file;

/*!
 * @property url
 *
 * @discussion 文件的 URL。使用 {@link NSURL} 类型来存储文件的 URL。
 */
@property NSURL* url;

/*!
 * @property filename
 *
 * @discussion 文件名。使用 {@link NSString} 类型来存储文件的名称。
 */
@property NSString* filename;

/*!
 * @property headerInfo
 *
 * @discussion 文件头信息。使用 {@link HeaderInfo} 类型来存储有关文件头的详细信息。
 */
@property HeaderInfo* headerInfo;

/*!
 * @property firmwareSize
 *
 * @discussion 固件文件的大小。以字节为单位，使用 {@link int} 类型来存储文件的总大小。
 */
@property int firmwareSize;

/*!
 * @property blockSize
 *
 * @discussion SUOTA 文件的块大小。以字节为单位，使用 {@link int} 类型来存储每个块的大小。
 */
@property int blockSize;

/*!
 * @property chunkSize
 *
 * @discussion SUOTA 文件的块大小。以字节为单位，使用 {@link int} 类型来存储每个块的大小。
 */
@property int chunkSize;

/*!
 * @property totalBlocks
 *
 * @discussion SUOTA 文件的总块数。使用 {@link int} 类型来存储文件的总块数量。
 */
@property int totalBlocks;

/*!
 * @property totalChunks
 *
 * @discussion SUOTA 文件的总块数。使用 {@link int} 类型来存储文件的总块数量。
 */
@property int totalChunks;

/*!
 * @property chunksPerBlock
 *
 * @discussion 每个块中的块数。使用 {@link int} 类型来存储每个块包含的块数量。
 *
 */
@property int chunksPerBlock;

/*!
 * @property lastBlockSize
 *
 * @discussion 最后一个块的大小。以字节为单位，使用 {@link int} 类型来存储最后一个块的大小。
 */
@property int lastBlockSize;

/*!
 * @property data
 *
 * @discussion 存储固件数据的 {@link NSMutableData} 对象。
 */
@property NSMutableData* data;

/*!
 * @property blocks
 *
 * @discussion 存储 SUOTA 文件的块的数组。使用 {@link NSMutableArray} 和 {@link NSData} 类型来表示。
 */
@property NSMutableArray<NSMutableArray<NSData*>*>* blocks;

/*!
 * @property crc
 *
 * @discussion 文件的 CRC 校验码。使用 {@link uint8_t} 类型来存储 CRC 校验码。
 */
@property uint8_t crc;

/*!
 * @method initWithAbsoluteFilePath:
 *
 * @param file 绝对文件路径。
 *
 * @discussion 通过打开给定的绝对文件路径来创建新的 {@link SuotaFile} 实例。
 *
 * @return 新创建的 {@link SuotaFile} 实例。
 */
- (instancetype) initWithAbsoluteFilePath:(NSString*)file;

/*!
 * @method initWithFilename:
 *
 * @param filename SUOTA 文件的名称。
 *
 * @discussion 通过在默认目录中打开具有给定文件名的文件来创建新的 {@link SuotaFile} 实例。默认目录是应用程序的 Documents 目录。
 *
 * @return 新创建的 {@link SuotaFile} 实例。
 */
- (instancetype) initWithFilename:(NSString*)filename;

/*!
 * @method initWithPath:filename:
 *
 * @param path SUOTA 文件的路径。
 * @param filename SUOTA 文件的名称。
 *
 * @discussion 通过转换给定的路径和文件名来创建新的 {@link SuotaFile} 实例。
 *
 * @return 新创建的 {@link SuotaFile} 实例。
 */
- (instancetype) initWithPath:(NSString*)path filename:(NSString*)filename;

/*!
 * @method initWithURL:
 *
 * @param url SUOTA 文件的 URL。
 *
 * @discussion 通过打开具有给定 URL 的文件来创建新的 {@link SuotaFile} 实例。
 *
 * @return 新创建的 {@link SuotaFile} 实例。
 */
- (instancetype) initWithURL:(NSURL*)url;

/*!
 * @method initWithFirmwareBuffer:
 *
 * @param firmware 固件原始缓冲区。
 *
 * @discussion 通过转换给定的固件缓冲区来创建新的 {@link SuotaFile} 实例。
 *
 * @return 新创建的 {@link SuotaFile} 实例。
 */
- (instancetype) initWithFirmwareBuffer:(NSData*)firmware;

/*!
 * @method listFilesInPathList:extension:searchSubFolders:withHeaderInfo:
 *
 * @param pathList 搜索路径列表。
 * @param extension 文件扩展名。如果为 nil，则返回的列表中包含所有文件。
 * @param searchSubFolders 指示是否在每个路径子文件夹中搜索文件。如果为 <code>false</code>，则忽略路径子文件夹。
 * @param withHeaderInfo 指示是否初始化每个 {@link SuotaFile} 对象的头信息。如果为 <code>false</code>，则忽略 {@link SuotaFile} 头信息初始化。
 *
 * @discussion 返回在给定路径列表中找到的 {@link SuotaFile} 对象列表，按文件名排序。
 *
 * @return {@link SuotaFile} 对象的列表。
 */
+ (NSArray<SuotaFile*>*) listFilesInPathList:(NSArray<NSString*>*)pathList extension:(NSString*)extension searchSubFolders:(BOOL)searchSubFolders withHeaderInfo:(BOOL)withHeaderInfo;

/*!
 * @method listFilesInPathList:
 *
 * @param pathList 搜索路径列表。
 * @return {@link SuotaFile} 对象的列表。
 *
 * @discussion 返回在给定路径中找到的 {@link SuotaFile} 对象列表，按文件名排序。忽略路径子文件夹。忽略 {@link SuotaFile} 头信息初始化。
 *
 * @return {@link SuotaFile} 对象的列表。
 */
+ (NSArray<SuotaFile*>*) listFilesInPathList:(NSArray<NSString*>*)pathList;

/*!
 * @method listFilesInPath:extension:searchSubFolders:withHeaderInfo:
 *
 * @param path 搜索路径。
 * @param extension 文件扩展名。如果为 nil，则返回的列表中包含所有文件。
 * @param searchSubFolders 指示是否在每个路径子文件夹中搜索文件。如果为 <code>false</code>，则忽略路径子文件夹。
 * @param withHeaderInfo 指示是否初始化每个 {@link SuotaFile} 对象的头信息。如果为 <code>false</code>，则忽略 {@link SuotaFile} 头信息初始化。
 *
 * @discussion 返回在给定路径中找到的 {@link SuotaFile} 对象列表，按文件名排序。 {@link SuotaFile} 头信息初始化被忽略。
 *
 * @return {@link SuotaFile} 对象的列表。
 */
+ (NSArray<SuotaFile*>*) listFilesInPath:(NSString*)path extension:(NSString*)extension searchSubFolders:(BOOL)searchSubFolders withHeaderInfo:(BOOL)withHeaderInfo;

/*!
 * @method listFilesInPath:
 *
 * @param path 搜索路径。
 * @return {@link SuotaFile} 对象的列表。
 *
 * @discussion 返回在给定路径中找到的 {@link SuotaFile} 对象列表，按文件名排序。忽略路径子文件夹。忽略 {@link SuotaFile} 头信息初始化。
 *
 * @return {@link SuotaFile} 对象的列表。
 */
+ (NSArray<SuotaFile*>*) listFilesInPath:(NSString*)path;

/*!
 * @method listFilesInPath:withHeaderInfo:
 *
 * @param path 搜索路径。
 * @param withHeaderInfo 指示是否初始化每个 {@link SuotaFile} 对象的头信息。
 *
 * @discussion 返回在给定路径中找到的 {@link SuotaFile} 对象列表，按文件名排序。忽略路径子文件夹。
 *
 * @return {@link SuotaFile} 对象的列表。
 */
+ (NSArray<SuotaFile*>*) listFilesInPath:(NSString*)path withHeaderInfo:(BOOL)withHeaderInfo;

/*!
 * @method listFilesInPath:extension:
 *
 * @param path 搜索路径。
 * @param extension 文件扩展名。如果为 nil，则返回的列表中包含所有文件。
 *
 * @discussion 返回在给定路径中找到的 {@link SuotaFile} 对象列表，按文件名排序。忽略路径子文件夹。忽略 {@link SuotaFile} 头信息初始化。
 *
 * @return {@link SuotaFile} 对象的列表。
 */
+ (NSArray<SuotaFile*>*) listFilesInPath:(NSString*)path extension:(NSString*)extension;

/*!
 * @method listFilesInPath:extension:searchSubFolders:withHeaderInfo:
 *
 * @param path 搜索路径。
 * @param extension 文件扩展名。如果为 nil，则返回的列表中包含所有文件。
 * @param searchSubFolders 指示是否在每个路径子文件夹中搜索文件。如果为 <code>false</code>，则忽略路径子文件夹。
 *
 * @discussion 返回在给定路径中找到的 {@link SuotaFile} 对象列表，按文件名排序。
 *
 * @return {@link SuotaFile} 对象的列表。
 */
+ (NSArray<SuotaFile*>*) listFilesInPath:(NSString*)path extension:(NSString*)extension searchSubFolders:(BOOL)searchSubFolders;

/*!
 * @method listFiles
 *
 * @discussion 返回在默认目录中找到的 {@link SuotaFile} 对象列表。默认目录是应用程序的 Documents 目录。
 *
 * @return {@link SuotaFile} 对象的列表。
 */
+ (NSArray<SuotaFile*>*) listFiles;

/*!
 * @method listFilesWithHeaderInfo
 *
 * @discussion 返回在默认目录中找到的 {@link SuotaFile} 对象列表。默认目录是应用程序的 Documents 目录。同时初始化列表中每个 {@link SuotaFile} 对象的头信息。
 *
 * @return {@link SuotaFile} 对象的列表。
 */
+ (NSArray<SuotaFile*>*) listFilesWithHeaderInfo;

/*!
 * @method fileName
 *
 * @discussion 返回 SUOTA 文件的名称。如果没有指定名称，则返回 <code>"Unknown"</code>。
 *
 * @return SUOTA 文件的名称。
 *
 */
- (NSString*) fileName;

/*!
 * @method hasHeaderInfo
 *
 * @discussion 检查是否有头信息。
 *
 * @return 如果存在头信息，则返回 <code>true</code>，否则返回 <code>false</code>。
 */
- (BOOL) hasHeaderInfo;

/*!
 * @method uploadSize
 *
 * @discussion 获取上传的大小。
 *
 * @return 上传的大小。
 */
- (int) uploadSize;

/*!
 * @method isLastBlockShorter
 *
 * @discussion 检查最后一个块是否较短。
 *
 * @return 如果最后一个块较短，则返回 <code>true</code>，否则返回 <code>false</code>。
 */
- (BOOL) isLastBlockShorter;

/*!
 * @method getBlock:
 *
 * @param index 块的索引。
 *
 * @discussion 获取指定索引的块数据。
 *
 * @return 指定索引的块数据数组。
 */
- (NSArray<NSData*>*) getBlock:(int)index;

/*!
 * @method getChunk:
 *
 * @param index 块的索引。
 *
 * @discussion 获取指定索引的块数据。
 *
 * @return 指定索引的块数据。
 */
- (NSData*) getChunk:(int)index;

/*!
 * @method getBlockSize:
 *
 * @param blockCount 块的数量。
 *
 * @discussion 获取指定块数量的块大小。
 *
 * @return 块的大小。
 */
- (int) getBlockSize:(int)blockCount;

/*!
 * @method getBlockChunks:
 *
 * @param index 块的索引。
 *
 * @discussion 获取指定块的块数量。
 *
 * @return 块的块数量。
 */
- (int) getBlockChunks:(int)index;

/*!
 * @method isLastBlock:
 *
 * @param index 块的索引。
 *
 * @discussion 检查指定索引的块是否为最后一个块。
 *
 * @return 如果指定索引的块是最后一个块，则返回 <code>true</code>，否则返回 <code>false</code>。
 */
- (BOOL) isLastBlock:(int)index;

/*!
 * @method isLastChunk:
 *
 * @param index 块的索引。
 *
 * @discussion 检查指定索引的块是否为最后一个块。
 *
 * @return 如果指定索引的块是最后一个块，则返回 <code>true</code>，否则返回 <code>false</code>。
 */
- (BOOL) isLastChunk:(int)index;

/*!
 * @method isLastChunk:chunk:
 *
 * @param block 块的索引。
 * @param chunk 块中的块索引。
 *
 * @discussion 检查指定块中的块是否为最后一个块。
 *
 * @return 如果指定块中的块是最后一个块，则返回 <code>true</code>，否则返回 <code>false</code>。
 */
- (BOOL) isLastChunk:(int)block chunk:(int)chunk;

/*!
 * @method load
 *
 * @discussion 加载 SUOTA 文件的数据。
 */
- (void) load;

/*!
 * @method isLoaded
 *
 * @discussion 检查 SUOTA 文件是否已加载。
 *
 * @return 如果 SUOTA 文件已加载，则返回 <code>true</code>，否则返回 <code>false</code>。
 */
- (BOOL) isLoaded;

/*!
 * @method isHeaderCrcValid
 *
 * @discussion 检查文件头的 CRC 是否有效。
 *
 * @return 一个 {@link BOOL} 值，指示头 CRC 是否有效。
 */
- (BOOL) isHeaderCrcValid;

/*!
 * @method initBlocks:chunkSize:
 *
 * @param blockSize 块大小。
 * @param chunkSize 块中的块大小。
 *
 * @discussion 初始化块数据和块大小。
 */
- (void) initBlocks:(int)blockSize chunkSize:(int)chunkSize;

/*!
 * @method initBlocks
 *
 * @discussion 初始化块数据和默认块大小。
 */
- (void) initBlocks;

@end
