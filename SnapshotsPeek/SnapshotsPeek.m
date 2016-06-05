#import "SnapshotsPeek.h"
#import "SnapshotSnapGalleryView.h"

#import "XcodeRuntime.h"
#import "NSFileManager+RecursiveFind.h"

#import <objc/runtime.h>

static SnapshotsPeek *sharedPlugin;

@interface SnapshotsPeek()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong, readwrite) NSURL *refenceImagesFolderURL;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation SnapshotsPeek

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        self.bundle = plugin;
        self.queue = dispatch_queue_create("io.orta.snapshots_peek_file_queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)editorContext:(IDEEditorContext *)editorContext didOpenItem:(id)item
{
    NSInteger ourGalleryViewTag = 232323;

    if ([editorContext.editor.mainScrollView viewWithTag:ourGalleryViewTag]) return;
    if (![item respondsToSelector:@selector(name)]) return;

    NSString *filename = [item name];
    if (![self validateFileNameForSupport:filename]) { return; }

    dispatch_async(self.queue, ^{

        NSString *name = [filename stringByDeletingPathExtension];
        NSURL *testFolder = [self folderForReferenceImagesNamed:name];
        if (!testFolder) return;

        NSArray <NSURL *> *referenceImagesForFile = [self urlsForTestImagesInFolder:testFolder];

        dispatch_sync(dispatch_get_main_queue(), ^{

            SnapshotSnapGalleryView *galleryView = [[SnapshotSnapGalleryView alloc] init];
            galleryView.tag = ourGalleryViewTag;
            [galleryView updateWithURLs:referenceImagesForFile];

            NSView *editorScrollView = editorContext.editor.mainScrollView;
            objc_setAssociatedObject(editorScrollView, @selector(editorScrollViewDidScroll:), galleryView , OBJC_ASSOCIATION_RETAIN_NONATOMIC);

            NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
            [notification addObserver:self selector:@selector(editorScrollViewDidScroll:) name:NSScrollViewWillStartLiveScrollNotification object:editorScrollView];

            [editorScrollView.superview addSubview:galleryView];
        });
    });
}

- (void)editorScrollViewDidScroll:(NSNotification *)notification
{
    NSScrollView *scrollView = notification.object;
    SnapshotSnapGalleryView *view = objc_getAssociatedObject(scrollView, @selector(editorScrollViewDidScroll:));

    // Clean up after ourselves to avoid over-retaining
    objc_setAssociatedObject(scrollView, @selector(editorScrollViewDidScroll:), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NSScrollViewWillStartLiveScrollNotification object:scrollView];

    [view fadeAndRemove];
}

// List of filenames that are likely to have associated snapshots

- (BOOL)validateFileNameForSupport:(NSString *)name
{
    NSArray *ok = @[@"h", @"m", @"swift", @"mm"];
    return [ok containsObject:[name pathExtension]];
}

// This represents the current projects root folder

- (NSURL *)workspaceURL
{
    NSDocument *document = [NSApp orderedDocuments].firstObject;
    return [[[document valueForKeyPath:@"_workspace.representingFilePath.fileURL"] URLByDeletingLastPathComponent] filePathURL];
}

// Gets the folder called ReferenceImages, which is the default FBSnapshots foldername

- (NSURL *)refenceImagesFolderURL
{
    if (_refenceImagesFolderURL) { return _refenceImagesFolderURL; }
    _refenceImagesFolderURL = [[self fileManager] or_findFileInFolder:[self workspaceURL] withNamePrefix:@"ReferenceImages"];
    return _refenceImagesFolderURL;
}

// Looks inside ReferenceImages for something with the same name, we don't bother standardizing on
// BlahBlahSpecs or BlahBlahTests so it should look for prefixes

- (NSURL *)folderForReferenceImagesNamed:(NSString *)name
{
    return [[self fileManager] or_findFileInFolder:[self refenceImagesFolderURL] withNamePrefix:name];
}

// Gets the contents of a folder, but with a nicer name

- (NSArray<NSURL *> *)urlsForTestImagesInFolder:(NSURL *)url
{
    return [[self fileManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
}

// DI, incase I want to use Forgeries to test.

- (NSFileManager *)fileManager
{
    return [NSFileManager defaultManager];
}

@end
