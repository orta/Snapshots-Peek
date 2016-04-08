@import Cocoa;

@interface DVTLayoutView_ML : NSView
@end

@class IDEViewController, IDESourceCodeEditor;

@interface IDESourceCodeEditorContainerView : DVTLayoutView_ML
{
    IDESourceCodeEditor *_editor;
    IDEViewController *_toolbarViewController;
}
@end

@interface DVTViewController : NSViewController
@end

@interface IDEViewController : DVTViewController
@end

@interface IDEEditor : IDEViewController
@end

@interface IDESourceCodeEditor : IDEEditor
- (id)mainScrollView;
@end

@interface IDEEditorContext : IDEViewController

- (int)_openNavigableItem:(id)item documentExtension:(id)documentExtension document:(id)document shouldInstallEditorBlock:(id)block;
- (IDESourceCodeEditor *)editor;

@end
