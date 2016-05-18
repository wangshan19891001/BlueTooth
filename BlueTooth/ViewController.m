//
//  ViewController.m
//  BlueTooth
//
//  Created by 王陕 on 16/5/18.
//  Copyright © 2016年 王陕. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController ()<MCBrowserViewControllerDelegate, MCSessionDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)connection;
- (IBAction)send;
- (IBAction)selectImage;

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCPeerID *dstPeerID;


@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;    // 广播
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;          // 发现

@end

@implementation ViewController

// 懒加载 MCSession
- (MCSession *)session {
    if (!_session) {

        _session = [[MCSession alloc] initWithPeer:_peerID];
    }
    return _session;
}


- (MCNearbyServiceAdvertiser *)advertiser {
    if (!_advertiser) {
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:@{@"message":@"wangshan"} serviceType:@"WS-photo"];
    }
    return _advertiser;
}

- (MCNearbyServiceBrowser *)browser {
    if (!_browser) {
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:@"WS-photo"];
    }
    return _browser;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 广播
    // MultipeerConnectivity 中使用MCAdvertiserAssistant 来表示一个广播, 在创建广播时, 需要指定一个会话MCSession 对象, 将广播服务和会话关联起来
    // 一旦调用了广播的start 方法, 周边的设备就可以发现该广播, 并可以连接到这个服务
    
//    MCAdvertiserAssistant *adv = [[MCAdvertiserAssistant alloc] initWithServiceType:@"WS-photo" discoveryInfo:@{@"message":@"我是消息"} session:self.session];
    
    
    
    
    // 发现
    // MultipeerConnectivity 中提供了MCBrowserViewController 来展示可连接和已连接的设备
    
    
    
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.peerID = [[MCPeerID alloc] initWithDisplayName:uuid];
    
    
    
    self.advertiser.delegate = self;
    [self.advertiser startAdvertisingPeer];
    
    
    
    
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  建立连接
 */
- (IBAction)connection {
    
    
    MCBrowserViewController *browserVC = [[MCBrowserViewController alloc] initWithServiceType:@"WS-photo" session:self.session];
    
    browserVC.delegate = self;
    self.session.delegate = self;
    
    [self presentViewController:browserVC animated:YES completion:nil];
}

/**
 *  发送数据
 */
- (IBAction)send {
    
    
    UIImage *image = self.imageView.image;
    NSData *data = UIImagePNGRepresentation(image);
    
    // 发送数据
    [self.session sendData:data toPeers:[NSArray arrayWithObjects:self.dstPeerID, nil] withMode:MCSessionSendDataReliable error:nil];
}

/**
 *  选择图片
 */
- (IBAction)selectImage {
    
    // 1.创建图片选择控制器
    UIImagePickerController *imagePk = [[UIImagePickerController alloc] init];
    // 2.判断图库是否可用打开
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        // 3.设置打开图库的类型
        imagePk.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        imagePk.delegate = self;
        
        // 4.打开图片选择控制器
        [self presentViewController:imagePk animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    NSLog(@"%@", info);
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    
    NSLog(@"选择设备完成");
    
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    
    NSLog(@"取消搜索");
    
    
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info {
    
//    [self.advertiser stopAdvertisingPeer];
    
//    NSLog(@"正在搜索");
    
//    self.dstPeerID = peerID;
    
    return YES;
}


#pragma mark - MCSessionDelegate
// Remote peer changed state.
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state { // 跟踪会话状态   正在连接  已连接 未连接
    // 监听连接, 一旦连接建立成功, 就可以通过MCSession 的connectedPeers 获得已经连接的设备
    
//    MCSessionStateNotConnected,     // not in the session
//    MCSessionStateConnecting,       // connecting to this peer
//    MCSessionStateConnected         // connected to the session
    
    switch (state) {
        case MCSessionStateNotConnected:
            NSLog(@"未连接");
            break;
        case MCSessionStateConnecting:
            NSLog(@"正在连接");
            break;
        case MCSessionStateConnected:
            NSLog(@"已连接");
            
            
            break;
            
        default:
            break;
    }
    
}

// Received data from remote peer.
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    // 接收数据
    NSLog(@"接收数据完成");
    
    UIImage *image = [UIImage imageWithData:data];
    
    self.imageView.image = image;
}

// Received a byte stream from remote peer.
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
    NSLog(@"接收数据流");

}

// Start receiving a resource from remote peer.
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {

    NSLog(@"开始接收数据");
}

// Finished receiving a resource from remote peer and saved the content
// in a temporary location - the app is responsible for moving the file
// to a permanent location within its sandbox.
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(nullable NSError *)error {

    NSLog(@"接收数据完成");

}

#pragma mark - MCNearbyServiceBrowserDelegate
// Found a nearby advertising peer.
- (void)        browser:(MCNearbyServiceBrowser *)browser
              foundPeer:(MCPeerID *)peerID
      withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info {

    [browser stopBrowsingForPeers];
    
    NSLog(@"邀请加入会话");
    [browser invitePeer:peerID toSession:self.session withContext:nil timeout:60];

}



// A nearby peer has stopped advertising.
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {



}


#pragma mark - MCNearbyServiceAdvertiserDelegate

// Incoming invitation request.  Call the invitationHandler block with YES
// and a valid session to connect the inviting peer to the session.
- (void)            advertiser:(MCNearbyServiceAdvertiser *)advertiser
  didReceiveInvitationFromPeer:(MCPeerID *)peerID
                   withContext:(nullable NSData *)context
             invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler {
    self.dstPeerID = peerID;
    NSLog(@"接受会话建立邀请");
    invitationHandler(YES, self.session); // 接受会话建立
}

//@optional
// Advertising did not start due to an error.
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {


}






@end
