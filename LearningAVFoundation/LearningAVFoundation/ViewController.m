//
//  ViewController.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/4.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "ViewController.h"
#import "CatalogCell.h"
#import "DetailViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (copy, nonatomic) NSArray<NSString *> *listSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CatalogCell" forIndexPath:indexPath];

    cell.titleLabel.text = self.listSource[indexPath.row];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailViewController *detail = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
    detail.type = indexPath.row;
    
    [self.navigationController pushViewController:detail animated:YES];
    
}

- (NSArray *)listSource {
    return @[
    @"第一章：AVFoundation入门",
    @"第二章：播放和录制音频",
    @"第三章：资源和元数据",
    @"第四章：视频播放",
    @"第五章：AV Kit 用法",
    @"第六章：捕捉媒体",
    @"第七章：高级捕捉功能",
    @"第八章：读取和写入媒体",
    @"第九章：媒体的组合和编辑",
    @"第十章：混合音频",
    @"第十一章：创建视频过渡效果",
    @"第十二章：动画图层内容"
    ];
}


@end
