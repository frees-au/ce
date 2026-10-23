#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import <arpa/inet.h>
#import <signal.h>
#import <sys/socket.h>
#import <unistd.h>

@interface FreesAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) NSTextField *statusLabel;
@property(nonatomic, strong) NSProgressIndicator *spinner;
@property(nonatomic, strong) NSTask *supervisor;
@property(nonatomic, strong) NSURL *pidFileURL;
@property(nonatomic, strong) NSURL *logFileURL;
@property(nonatomic) BOOL quitting;
@property(nonatomic) BOOL repliedToTermination;
@end

@implementation FreesAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self installMenu];
    [self buildWindow];
    [NSApp activateIgnoringOtherApps:YES];
    [self startDrupal];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if (!self.supervisor || !self.supervisor.running) {
        [self cleanUpRuntimeFiles];
        return NSTerminateNow;
    }

    if (!self.quitting) {
        self.quitting = YES;
        [self showStatus:@"Stopping Drupal…"];
        [self.supervisor terminate];
            // Saving/exporting the site may take a while. Give the supervisor
            // up to five minutes before forcing its process group to stop.
            [self waitForShutdown:self.supervisor attemptsRemaining:3000];
    }
    return NSTerminateLater;
}

- (void)installMenu {
    NSMenu *mainMenu = [[NSMenu alloc] init];
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    [mainMenu addItem:appMenuItem];

    NSMenu *appMenu = [[NSMenu alloc] init];
    [appMenu addItemWithTitle:@"About frees-au-ce"
                       action:@selector(orderFrontStandardAboutPanel:)
                keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Quit frees-au-ce"
                       action:@selector(terminate:)
                keyEquivalent:@"q"];
    appMenuItem.submenu = appMenu;
    NSApp.mainMenu = mainMenu;
}

- (void)buildWindow {
    self.window = [[NSWindow alloc]
        initWithContentRect:NSMakeRect(0, 0, 1280, 850)
                  styleMask:(NSWindowStyleMaskTitled |
                             NSWindowStyleMaskClosable |
                             NSWindowStyleMaskMiniaturizable |
                             NSWindowStyleMaskResizable)
                    backing:NSBackingStoreBuffered
                      defer:NO];
    self.window.title = @"frees-au-ce";
    self.window.minSize = NSMakeSize(720, 500);
    self.window.delegate = self;
    [self.window center];

    NSView *container = [[NSView alloc] init];
    self.window.contentView = container;

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    self.webView = [[WKWebView alloc] initWithFrame:NSZeroRect configuration:configuration];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.hidden = YES;
    [container addSubview:self.webView];

    self.spinner = [[NSProgressIndicator alloc] init];
    self.spinner.style = NSProgressIndicatorStyleSpinning;
    self.spinner.controlSize = NSControlSizeLarge;
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.spinner startAnimation:nil];
    [container addSubview:self.spinner];

    self.statusLabel = [NSTextField labelWithString:@"Starting Drupal…"];
    self.statusLabel.alignment = NSTextAlignmentCenter;
    self.statusLabel.font = [NSFont systemFontOfSize:15];
    self.statusLabel.textColor = NSColor.secondaryLabelColor;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:self.statusLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.webView.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [self.webView.topAnchor constraintEqualToAnchor:container.topAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
        [self.spinner.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [self.spinner.centerYAnchor constraintEqualToAnchor:container.centerYAnchor constant:-16],
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.spinner.bottomAnchor constant:14],
        [self.statusLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:container.leadingAnchor constant:30],
        [self.statusLabel.trailingAnchor constraintLessThanOrEqualToAnchor:container.trailingAnchor constant:-30],
    ]];

    [self.window makeKeyAndOrderFront:nil];
}

- (void)startDrupal {
    NSURL *bundleURL = NSBundle.mainBundle.bundleURL.URLByStandardizingPath;
    NSURL *repositoryURL = [bundleURL URLByDeletingLastPathComponent];
    NSURL *routerURL = [repositoryURL URLByAppendingPathComponent:@"vendor/drush/drush/misc/d8-rs-router.php"];
    NSURL *supervisorURL = [bundleURL URLByAppendingPathComponent:@"Contents/Resources/supervise.sh"];

    if (![NSFileManager.defaultManager fileExistsAtPath:routerURL.path]) {
        [self showFailure:@"Could not find the Drush development-server router next to frees-au-ce.app. Keep the app at the repository root and run Composer install first."];
        return;
    }

    NSInteger port = [self firstAvailablePortFrom:8888 through:8999];
    if (port == NSNotFound) {
        [self showFailure:@"No free local port was found between 8888 and 8999."];
        return;
    }
    [self showStatus:[NSString stringWithFormat:@"Starting Drupal on port %ld…", (long)port]];

    NSURL *runtimeDirectory = [NSFileManager.defaultManager.temporaryDirectory
        URLByAppendingPathComponent:[NSString stringWithFormat:@"frees-au-ce-%d", getpid()]
                         isDirectory:YES];
    NSError *error = nil;
    if (![NSFileManager.defaultManager createDirectoryAtURL:runtimeDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&error]) {
        [self showFailure:[NSString stringWithFormat:@"Could not create the temporary runtime directory: %@", error.localizedDescription]];
        return;
    }

    NSURL *logsDirectory = [[NSFileManager.defaultManager URLsForDirectory:NSLibraryDirectory
                                                                  inDomains:NSUserDomainMask].firstObject
        URLByAppendingPathComponent:@"Logs/frees-au-ce"
                         isDirectory:YES];
    [NSFileManager.defaultManager createDirectoryAtURL:logsDirectory
                           withIntermediateDirectories:YES
                                            attributes:nil
                                                 error:nil];
    self.pidFileURL = [runtimeDirectory URLByAppendingPathComponent:@"server.pid"];
    self.logFileURL = [logsDirectory URLByAppendingPathComponent:@"server.log"];

    NSTask *process = [[NSTask alloc] init];
    process.executableURL = supervisorURL;
    process.arguments = @[
        repositoryURL.path,
        [NSString stringWithFormat:@"%ld", (long)port],
        self.pidFileURL.path,
        self.logFileURL.path,
        [NSString stringWithFormat:@"%d", getpid()],
    ];

    NSMutableDictionary<NSString *, NSString *> *environment = [NSProcessInfo.processInfo.environment mutableCopy];
    NSString *existingPath = environment[@"PATH"] ?: @"";
    environment[@"PATH"] = [NSString stringWithFormat:@"/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:%@", existingPath];
    process.environment = environment;
    process.currentDirectoryURL = repositoryURL;

    __weak typeof(self) weakSelf = self;
    process.terminationHandler = ^(NSTask *finishedProcess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) self = weakSelf;
            if (!self) return;
            if (self.quitting) {
                [self finishTerminationIfNeeded];
            } else if (finishedProcess.terminationStatus != 0) {
                [self showFailure:[NSString stringWithFormat:@"Drupal stopped unexpectedly. Its log is at %@.", self.logFileURL.path]];
            }
        });
    };

    if (![process launchAndReturnError:&error]) {
        [self showFailure:[NSString stringWithFormat:@"Could not start Drupal: %@", error.localizedDescription]];
        return;
    }
    self.supervisor = process;
    [self pollUntilReadyOnPort:port attemptsRemaining:120];
}

- (void)pollUntilReadyOnPort:(NSInteger)port attemptsRemaining:(NSInteger)attempts {
    if (self.quitting) return;
    if (!self.supervisor.running) {
        [self showFailure:[NSString stringWithFormat:@"Drupal exited before it was ready. Check %@.", self.logFileURL.path]];
        return;
    }
    if (attempts <= 0) {
        [self showFailure:[NSString stringWithFormat:@"Drupal did not respond within 30 seconds. Check %@.", self.logFileURL.path]];
        return;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:%ld/", (long)port]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 1;

    __weak typeof(self) weakSelf = self;
    [[NSURLSession.sharedSession dataTaskWithRequest:request
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) self = weakSelf;
            if (!self || self.quitting) return;
            if (response) {
                [self createLoginLinkForPort:port];
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                    [self pollUntilReadyOnPort:port attemptsRemaining:attempts - 1];
                });
            }
        });
    }] resume];
}

- (void)createLoginLinkForPort:(NSInteger)port {
    NSURL *repositoryURL = NSBundle.mainBundle.bundleURL.URLByStandardizingPath.URLByDeletingLastPathComponent;
    NSURL *drushURL = [repositoryURL URLByAppendingPathComponent:@"vendor/bin/drush"];
    NSPipe *outputPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];

    [self showStatus:@"Creating administrator login link…"];

    NSTask *task = [[NSTask alloc] init];
    task.executableURL = drushURL;
    task.arguments = @[
        [NSString stringWithFormat:@"--uri=http://127.0.0.1:%ld", (long)port],
        @"--no-ansi",
        @"user:login",
        @"/admin/content",
        @"--no-browser",
    ];
    task.currentDirectoryURL = repositoryURL;
    task.standardOutput = outputPipe;
    task.standardError = errorPipe;

    NSMutableDictionary<NSString *, NSString *> *environment = [NSProcessInfo.processInfo.environment mutableCopy];
    NSString *existingPath = environment[@"PATH"] ?: @"";
    environment[@"PATH"] = [NSString stringWithFormat:@"/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:%@", existingPath];
    task.environment = environment;

    __weak typeof(self) weakSelf = self;
    task.terminationHandler = ^(NSTask *finishedTask) {
        NSData *outputData = [outputPipe.fileHandleForReading readDataToEndOfFile];
        NSData *errorData = [errorPipe.fileHandleForReading readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] ?: @"";
        NSString *errorOutput = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding] ?: @"";

        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) self = weakSelf;
            if (!self || self.quitting) return;

            if (finishedTask.terminationStatus != 0) {
                [self appendToLog:errorOutput];
                [self showFailure:[NSString stringWithFormat:@"Could not create the Drush login link. Check %@.", self.logFileURL.path]];
                return;
            }

            NSRegularExpression *expression = [NSRegularExpression
                regularExpressionWithPattern:@"https?://\\S+"
                                     options:0
                                       error:nil];
            NSTextCheckingResult *match = [expression firstMatchInString:output
                                                                  options:0
                                                                    range:NSMakeRange(0, output.length)];
            if (!match) {
                [self appendToLog:output];
                [self showFailure:[NSString stringWithFormat:@"Drush did not return a login URL. Check %@.", self.logFileURL.path]];
                return;
            }

            NSString *urlString = [output substringWithRange:match.range];
            NSURL *loginURL = [NSURL URLWithString:urlString];
            if (!loginURL) {
                [self appendToLog:output];
                [self showFailure:[NSString stringWithFormat:@"Drush returned an invalid login URL. Check %@.", self.logFileURL.path]];
                return;
            }
            [self loadSite:loginURL];
        });
    };

    NSError *error = nil;
    if (![task launchAndReturnError:&error]) {
        [self showFailure:[NSString stringWithFormat:@"Could not run Drush to create the login link: %@", error.localizedDescription]];
    }
}

- (void)appendToLog:(NSString *)text {
    if (text.length == 0 || !self.logFileURL) return;
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.logFileURL.path];
    if (!handle) {
        [text writeToURL:self.logFileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return;
    }
    [handle seekToEndOfFile];
    [handle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}

- (void)loadSite:(NSURL *)url {
    [self.spinner stopAnimation:nil];
    self.spinner.hidden = YES;
    self.statusLabel.hidden = YES;
    self.webView.hidden = NO;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.window.title = [NSString stringWithFormat:@"frees-au-ce — %@", url.absoluteString];
}

- (void)showStatus:(NSString *)message {
    self.statusLabel.stringValue = message;
}

- (void)showFailure:(NSString *)message {
    [self.spinner stopAnimation:nil];
    self.spinner.hidden = YES;
    self.statusLabel.hidden = NO;
    self.statusLabel.textColor = NSColor.systemRedColor;
    self.statusLabel.stringValue = message;
}

- (void)waitForShutdown:(NSTask *)process attemptsRemaining:(NSInteger)attempts {
    if (!process.running) {
        [self finishTerminationIfNeeded];
        return;
    }
    if (attempts <= 0) {
        pid_t groupPID = [self readServerGroupPID];
        if (groupPID > 0) kill(-groupPID, SIGKILL);
        kill(process.processIdentifier, SIGKILL);
        [self finishTerminationIfNeeded];
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self waitForShutdown:process attemptsRemaining:attempts - 1];
    });
}

- (void)finishTerminationIfNeeded {
    if (self.repliedToTermination) return;
    self.repliedToTermination = YES;
    [self cleanUpRuntimeFiles];
    [NSApp replyToApplicationShouldTerminate:YES];
}

- (pid_t)readServerGroupPID {
    NSString *contents = [NSString stringWithContentsOfURL:self.pidFileURL
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    return contents ? (pid_t)contents.intValue : 0;
}

- (void)cleanUpRuntimeFiles {
    if (self.pidFileURL) {
        [NSFileManager.defaultManager removeItemAtURL:self.pidFileURL.URLByDeletingLastPathComponent error:nil];
    }
}

- (NSInteger)firstAvailablePortFrom:(NSInteger)first through:(NSInteger)last {
    for (NSInteger port = first; port <= last; port++) {
        if ([self canBindPort:port]) return port;
    }
    return NSNotFound;
}

- (BOOL)canBindPort:(NSInteger)port {
    int descriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (descriptor < 0) return NO;

    int value = 1;
    setsockopt(descriptor, SOL_SOCKET, SO_REUSEADDR, &value, sizeof(value));

    struct sockaddr_in address = {0};
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons((uint16_t)port);
    address.sin_addr.s_addr = inet_addr("127.0.0.1");
    BOOL available = bind(descriptor, (struct sockaddr *)&address, sizeof(address)) == 0;
    close(descriptor);
    return available;
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *application = NSApplication.sharedApplication;
        FreesAppDelegate *delegate = [[FreesAppDelegate alloc] init];
        application.delegate = delegate;
        [application setActivationPolicy:NSApplicationActivationPolicyRegular];
        [application run];
    }
    return 0;
}
