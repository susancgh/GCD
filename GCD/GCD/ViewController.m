//
//  ViewController.m
//  GCD
//
//  Created by accenture iMac on 15-5-26.
//  Copyright (c) 2015年 Hardway. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*Serial
    又称为private dispatch queues，同时只执行一个任务。Serial queue通常用于同步访问特定的资源或数据。当你创建多个Serial queue时，虽然它们各自是同步执行的，但Serial queue与Serial queue之间是并发执行的。
    
    Concurrent
    又称为global dispatch queue，可以并发地执行多个任务，但是执行完成的顺序是随机的。
    
    Main dispatch queue
    它是全局可用的serial queue，它是在应用程序主线程上执行任务的。
     */
    
//    一个任务就是一个block，比如，将任务添加到队列中的代码是：
//    1 dispatch_async(queue, block);
    
    dispatch_queue_t privateQueue = dispatch_queue_create("com.example.MyCustomQueue", DISPATCH_QUEUE_SERIAL);
    //5 秒以后提交block  dispatch_after只是延时提交block，并不是延时后立即执行。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), privateQueue, ^{
        NSLog(@"After...");
    });
    
    [self testApply];
    
}

- (void)private
{
    //将任务插入主线程的RunLoop当中去执行，所以显然是个串行队列，我们可以使用它来更新UI
    dispatch_queue_t mainQueue = dispatch_get_main_queue();

    /* 函数的第一个参数是一个标签，这纯是为了debug。Apple建议我们使用倒置域名来命名队列，
     比如“com.dreamingwish.subsystem.task”。这些名字会在崩溃日志中被显示出来，
     也可以被调试器调用，这在调试中会很有用。第二个参数目前还不支持，传入NULL就行了。
     */
    dispatch_queue_t privateQueue = dispatch_queue_create("com.example.MyCustomQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(privateQueue, ^{
        // 耗时的操作
        long long a = 0;
        for (int i = 0; i < 1000000000; i ++) {
            a = a + i;
        }
        NSLog(@"jisuan");
        // 更新界面
        dispatch_async(mainQueue, ^{
            self.label.text = [NSString stringWithFormat:@"%lld", a];
        });
        
    });
}

- (void)gloabel
{
    //将任务插入主线程的RunLoop当中去执行，所以显然是个串行队列，我们可以使用它来更新UI
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // 全局的并行队列，有高、默认、低和后台4个优先级。
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    dispatch_async ,异步添加进任务队列，它不会做任何等待
    dispatch_async(globalQueue, ^{
        // 耗时的操作
        NSURL * url = [NSURL URLWithString:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
        NSData * data = [[NSData alloc]initWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc]initWithData:data];
        NSLog(@"load Image");
        if (data != nil) {
            // 更新界面
            dispatch_async(mainQueue, ^{
                self.imageView.image = image;
            });
        }
    });
    
    dispatch_async(globalQueue, ^{
        // 耗时的操作
        long long a = 0;
        for (long i = 0; i < 1000000000; i ++) {
            a = a + i;
        }
        NSLog(@"jisuan");
        // 更新界面
        dispatch_async(mainQueue, ^{
            self.label.text = [NSString stringWithFormat:@"%lld", a];
        });
    });
    
    //    dispatch_sync(),同步添加操作。他是等待添加进队列里面的操作完成之后再继续执行。
    dispatch_sync(globalQueue, ^{
        // 耗时的操作
        NSURL * url = [NSURL URLWithString:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
        NSData * data = [[NSData alloc]initWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc]initWithData:data];
        if (data != nil) {
            // 更新界面
            dispatch_async(mainQueue, ^{
                self.imageView.image = image;
            });
        }
    });
}

- (void)testGuangqi
{
//    dispatch_suspend，dispatch_resume提供了“挂起、恢复”队列的功能，简单来说，就是可以暂停、恢复队列上的任务。但是这里的“挂起”，并不能保证可以立即停止队列上正在运行的block，
    
    dispatch_queue_t queue = dispatch_queue_create("me.tutuge.test.gcd", DISPATCH_QUEUE_SERIAL);
    //提交第一个block，延时5秒打印。
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:5];
        NSLog(@"After 5 seconds...");
    });
    //提交第二个block，也是延时5秒打印
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:5];
        NSLog(@"After 5 seconds again...");
    });
    //延时一秒
    NSLog(@"sleep 1 second...");
    [NSThread sleepForTimeInterval:1];
    //挂起队列
    NSLog(@"suspend...");
    dispatch_suspend(queue);
    //延时10秒                
    NSLog(@"sleep 10 second...");
    [NSThread sleepForTimeInterval:10];
    //恢复队列            
    NSLog(@"resume...");
    dispatch_resume(queue);
}

- (void)testApply
{
    //创建异步串行队列
    dispatch_queue_t queue = dispatch_queue_create("me.tutuge.test.gcd", DISPATCH_QUEUE_SERIAL);
    
    //运行block3次
    dispatch_apply(3, queue, ^(size_t i) {
        NSLog(@"apply loop: %zu", i);
    });
    //打印信息
    NSLog(@"After apply");
}

@end
