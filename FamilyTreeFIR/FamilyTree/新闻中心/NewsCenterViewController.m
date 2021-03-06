//
//  NewsCenterViewController.m
//  FamilyTree
//
//  Created by 王子豪 on 16/6/7.
//  Copyright © 2016年 王子豪. All rights reserved.
//

#import "NewsCenterViewController.h"
#import "FamilyDTModel.h"
#import "HundredsNamesModel.h"
#import <MJRefresh.h>

@interface NewsCenterViewController ()

@property (nonatomic,strong) UIView *whiteView; /*背景白*/


@property (nonatomic,strong) UISegmentedControl *segmentContl; /*分段控件*/
@property (nonatomic,strong) ScrollerView *scroView; /*滚动新闻图*/

@property (nonatomic,strong) NewsTableView *tableNesView; /*table*/

@property (nonatomic,strong) PortraitAndNameViews *proAndName; /*头像和名字*/


@property (nonatomic,strong) NewsTableView *nameTableNews; /*百家姓新闻*/

/** 我请求的家族动态的页数*/
@property (nonatomic, assign) int jzdtPage;


@end

@implementation NewsCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = LH_RGBCOLOR(236, 236, 236);
    
    [self.view addSubview:self.bacScrollView];
    [self.bacScrollView addSubview:self.whiteView];
    [self.bacScrollView addSubview:self.segmentContl];
    [self.bacScrollView addSubview:self.scroView];
    [self.bacScrollView addSubview:self.tableNesView];
    self.tableNesView.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreJzdt)];
    [self.bacScrollView addSubview:self.proAndName];
    [self.bacScrollView addSubview:self.hundredVies];
    [self.bacScrollView addSubview:self.nameTableNews];
    
    //获取家族动态
    self.jzdtPage = 1;
    [self getFamilyDTData];
    //获取名人传记
    [self getMRZJData];
    //获取百家姓
    [self getBJXData];
    //获取姓氏源流
    [self getXSWHData];
}

#pragma mark - 网络请求数据
-(void)getFamilyDTData{
//    NSDictionary *logDic = @{@"pagenum":@1,@"pagesize":@1999,@"type":@"JZDT",@"geid":@"",@"istop":@""};
    NSDictionary *logDic = @{@"pagenum":@(self.jzdtPage),@"pagesize":@5,@"type":@"JZDT",@"geid":@"",@"istop":@""};
    WK(weakSelf)
    [TCJPHTTPRequestManager POSTWithParameters:logDic requestID:GetUserId requestcode:kRequestCodeGetNewsList success:^(id responseObject, BOOL succe, NSDictionary *jsonDic) {
        MYLog(@"%@",jsonDic[@"data"]);
        if (succe) {
            NSDictionary *dic = [NSDictionary DicWithString:jsonDic[@"data"]];
            NSArray *JZDTArr = [NSArray modelArrayWithClass:[FamilyDTModel class] json:dic[@"datalist"]];
            weakSelf.tableNesView.dataSource = JZDTArr;
            [weakSelf.tableNesView.tableView reloadData];
            
            //MYLog(@"%@",JZDTArr);
        }
    } failure:^(NSError *error) {
        
    }];
    
}

-(void)getMRZJData{
    NSDictionary *logDic = @{@"pagenum":@1,@"pagesize":@1999,@"type":@"MRZJ",@"geid":@"",@"istop":@""};
    WK(weakSelf)
    [TCJPHTTPRequestManager POSTWithParameters:logDic requestID:GetUserId requestcode:kRequestCodeGetNewsList success:^(id responseObject, BOOL succe, NSDictionary *jsonDic) {
        //MYLog(@"%@",jsonDic[@"data"]);
        if (succe) {
            NSDictionary *dic = [NSDictionary DicWithString:jsonDic[@"data"]];
            NSArray *MRZJArr = [NSArray modelArrayWithClass:[FamilyDTModel class] json:dic[@"datalist"]];
            weakSelf.proAndName.MRZJArr = MRZJArr;
            
            //MYLog(@"%@",MRZJArr);
        }
    } failure:^(NSError *error) {
        
    }];
 
}

-(void)getBJXData{
    NSDictionary *logDic = @{@"pagenum":@1,@"pagesize":@1999};
    WK(weakSelf)
    [TCJPHTTPRequestManager POSTWithParameters:logDic requestID:GetUserId requestcode:kRequestCodeGetFamilyNamesList success:^(id responseObject, BOOL succe, NSDictionary *jsonDic) {
        MYLog(@"%@",jsonDic[@"data"]);
        if (succe) {
            NSDictionary *dic = [NSDictionary DicWithString:jsonDic[@"data"]];
            NSArray *hundredsNamesArr = [NSArray modelArrayWithClass:[HundredsNamesModel class] json:dic[@"datalist"]];
            MYLog(@"%@",hundredsNamesArr);
            weakSelf.hundredVies.BJXArr = hundredsNamesArr;
            [weakSelf.hundredVies.collectionView reloadData];
            
        }
    } failure:^(NSError *error) {
        
    }];
}

-(void)getXSWHData{
    NSDictionary *logDic = @{@"pagenum":@1,@"pagesize":@1999,@"type":@"XSWH",@"geid":@"",@"istop":@""};
    WK(weakSelf)
    [TCJPHTTPRequestManager POSTWithParameters:logDic requestID:GetUserId requestcode:kRequestCodeGetNewsList success:^(id responseObject, BOOL succe, NSDictionary *jsonDic) {
        MYLog(@"姓氏源流%@",jsonDic[@"data"]);
        if (succe) {
            NSDictionary *dic = [NSDictionary DicWithString:jsonDic[@"data"]];
            NSArray *XSWHArr = [NSArray modelArrayWithClass:[FamilyDTModel class] json:dic[@"datalist"]];
            weakSelf.nameTableNews.dataSource = XSWHArr;
            [weakSelf.nameTableNews.tableView reloadData];

            
            MYLog(@"%@",XSWHArr);
        }
    } failure:^(NSError *error) {
        
    }];

}

-(void)loadMoreJzdt{
    self.jzdtPage++;
    [self getFamilyDTData];
}


#pragma mark - lazyLoad

-(UIScrollView *)bacScrollView{
    if (!_bacScrollView) {
        _bacScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectYH(self.comNavi), Screen_width, Screen_height-64-self.tabBarController.tabBar.bounds.size.height)];
        _bacScrollView.bounces = false;
        _bacScrollView.contentSize = CGSizeMake(Screen_width, CGRectGetMaxY(self.nameTableNews.frame)+55*AdaptationWidth());
    }
    return _bacScrollView;
}
-(UIView *)whiteView{
    if (!_whiteView) {
        _whiteView = [[UIView alloc] initWithFrame:AdaptationFrame(0,0, Screen_width/AdaptationWidth(), 456)];
        _whiteView.backgroundColor = [UIColor whiteColor];
    }
    return _whiteView;
}
-(UISegmentedControl *)segmentContl{
    if (!_segmentContl) {
        _segmentContl = [[UISegmentedControl alloc] initWithItems:@[@"同城公告",@"同城活动",@"家谱新闻"]];
        _segmentContl.frame = AdaptationFrame(26, 24, 667, 53);
        _segmentContl.tintColor = self.comNavi.backView.backgroundColor;
//        _segmentContl.backgroundColor = self.comNavi.backView.backgroundColor;
        [_segmentContl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
        _segmentContl.selectedSegmentIndex = 2;
    }
    return _segmentContl;
}

-(ScrollerView *)scroView{
    if (!_scroView) {
        _scroView = [[ScrollerView alloc] initWithFrame:AdaptationFrame(27, CGRectYH(self.segmentContl)/AdaptationWidth()+28, 667, 333) images:[@[@"news_lunbo.png",@"xuShi_bg"] mutableCopy]];
        
    }
    return _scroView;
}
-(NewsTableView *)tableNesView{
    if (!_tableNesView) {
        _tableNesView = [[NewsTableView alloc] initWithFrame:CGRectMake(0, CGRectYH(self.scroView)+20*AdaptationWidth(), Screen_width, 416*AdaptationWidth())];
    }
    return _tableNesView;
}
-(PortraitAndNameViews *)proAndName{
    if (!_proAndName) {
        _proAndName = [[PortraitAndNameViews alloc] initWithFrame:AdaptationFrame(22, CGRectYH(self.tableNesView)/AdaptationWidth()+20, 670, 230)];
    }
    return _proAndName;
}
-(HundredNamesView *)hundredVies{
    if (!_hundredVies) {
        
        UIView *whiteV = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectYH(self.proAndName)+8*AdaptationWidth(), Screen_width, 312*AdaptationWidth())];
        whiteV.backgroundColor = [UIColor whiteColor];
        [self.bacScrollView addSubview:whiteV];
        
        _hundredVies = [[HundredNamesView alloc] initWithFrame:CGRectMake(0, CGRectYH(self.proAndName), Screen_width, 257*AdaptationWidth())];
        
    }
    return _hundredVies;
}
-(NewsTableView *)nameTableNews{
    if (!_nameTableNews) {
        _nameTableNews = [[NewsTableView alloc] initWithFrame:CGRectMake(0, CGRectYH(self.hundredVies)+80*AdaptationWidth(), Screen_width, 412*AdaptationWidth())];
    }
    return _nameTableNews;
}



@end
