//
//  MyHelpViewController.m
//  FamilyTree
//
//  Created by 姚珉 on 16/7/28.
//  Copyright © 2016年 王子豪. All rights reserved.
//

#import "MyHelpViewController.h"
#import "ScrollerView.h"
#import "MyHelpOrAttentionTableViewCell.h"
#import "AddPostViewController.h"
#import "AdgnatioHelpInfoViewController.h"

typedef enum : NSUInteger {
        MyPost,
        MyAttention,
} MyPostOrAttention;

@interface MyHelpViewController ()<UITableViewDataSource,UITableViewDelegate>
/** 滚动图*/
@property (nonatomic, strong) ScrollerView *bannerScrollView;
/** 切换栏白色背景*/
@property (nonatomic, strong) UIView *changeWhiteBackV;
/** 分段控件*/
@property (nonatomic, strong) UISegmentedControl *changeSC;
/** 信息表*/
@property (nonatomic, strong) UITableView *infoTB;
/** 新增发布按钮*/
@property (nonatomic, strong) UIButton *addPostBtn;
/** 我的发布数组*/
@property (nonatomic, strong) NSArray<MyHelpModel *> *myPostArr;
/** 我的关注数组*/
@property (nonatomic, strong) NSArray<MyHelpModel *> *myAttentionArr;
/** 当前选择的状态*/
@property (nonatomic, assign) BOOL isMyPost;
@end

@implementation MyHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isMyPost = YES;
    [self initUI];
    [self getMyPostData];
}



#pragma mark - 视图初始化
-(void)initUI{
    [self.view addSubview:self.bannerScrollView];
    [self.view addSubview:self.changeWhiteBackV];
    self.changeWhiteBackV.sd_layout.leftSpaceToView(self.view,0).rightSpaceToView(self.view,0).topSpaceToView(self.bannerScrollView,0).heightIs(45);
    [self.changeWhiteBackV addSubview:self.changeSC];
    self.changeSC.sd_layout.centerXEqualToView(self.changeWhiteBackV).centerYEqualToView(self.changeWhiteBackV).heightIs(25).widthIs(175);
    [self.view addSubview:self.infoTB];
    self.infoTB.sd_layout.topSpaceToView(self.changeWhiteBackV,0).bottomSpaceToView(self.view,49).leftSpaceToView(self.view,0).rightSpaceToView(self.view,0);
    [self.view addSubview:self.addPostBtn];
    self.addPostBtn.sd_layout.rightSpaceToView(self.self.view,0).bottomSpaceToView(self.view,60).widthIs(50).heightIs(50);
    self.addPostBtn.sd_cornerRadius = @25;
}
#pragma mark - getData
-(void)getMyPostData{
    NSDictionary *logDic = @{@"userId":GetUserId,@"type":@"WDFB"};
    WK(weakself)
    [TCJPHTTPRequestManager POSTWithParameters:logDic requestID:GetUserId requestcode:@"querymyzqlist" success:^(id responseObject, BOOL succe, NSDictionary *jsonDic) {
        MYLog(@"%@",jsonDic);
        if (succe) {
            weakself.myPostArr = [NSArray modelArrayWithClass:[MyHelpModel class] json:jsonDic[@"data"]];
            [weakself.infoTB reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}

-(void)getMYAttentionData{
    NSDictionary *logDic = @{@"userId":GetUserId,@"type":@"WDGZ"};
    WK(weakself)
    [TCJPHTTPRequestManager POSTWithParameters:logDic requestID:GetUserId requestcode:@"querymyzqlist" success:^(id responseObject, BOOL succe, NSDictionary *jsonDic) {
        MYLog(@"%@",jsonDic);
        if (succe) {
            weakself.myAttentionArr = [NSArray modelArrayWithClass:[MyHelpModel class] json:jsonDic[@"data"]];
            [weakself.infoTB reloadData];
        }
    } failure:^(NSError *error) {
        
    }];

}

#pragma mark - 点击方法
-(void)changePostOrAttention:(UISegmentedControl *)seg{
    NSInteger index = seg.selectedSegmentIndex;
    switch (index) {
        case 0:
            MYLog(@"%ld",index);
            self.isMyPost = YES;
            [self.infoTB reloadData];
            break;
        case 1:
            MYLog(@"%ld",index);
            self.isMyPost = NO;
            if (self.myAttentionArr.count == 0) {
                [self getMYAttentionData];
                break;
            }
            [self.infoTB reloadData];
            break;
        default:
            break;
    }
}

-(void)clickAddPostBtn{
    AddPostViewController *addPostVC = [[AddPostViewController alloc]initWithTitle:@"新增发布" image:nil];
    [self.navigationController pushViewController:addPostVC animated:YES];
}


#pragma mark - UITableViewDateSource And UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isMyPost) {
        return self.myPostArr.count;
    }else{
       return self.myAttentionArr.count;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyHelpOrAttentionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyHelpOrAttentionCell"];
    if (!cell) {
        cell = [[MyHelpOrAttentionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyHelpOrAttentionCell"];
    }
    if (self.isMyPost) {
        cell.myHelpModel = self.myPostArr[indexPath.row];
    }else{
        cell.myHelpModel = self.myAttentionArr[indexPath.row];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = self.isMyPost?self.myPostArr[indexPath.row].ZqType:self.myAttentionArr[indexPath.row].ZqType;
    AdgnatioHelpInfoViewController *adgnatioHelpInfoVC = [[AdgnatioHelpInfoViewController alloc]initWithTitle:title image:nil];
    [self.navigationController pushViewController:adgnatioHelpInfoVC animated:YES];
}



#pragma mark - lazyLoad
-(ScrollerView *)bannerScrollView{
    if (!_bannerScrollView) {
        _bannerScrollView = [[ScrollerView alloc] initWithFrame:CGRectMake(0, 64, Screen_width, 175) images:nil];
    }
    return _bannerScrollView;
}

-(UIView *)changeWhiteBackV{
    if (!_changeWhiteBackV) {
        _changeWhiteBackV = [[UIView alloc]init];
        _changeWhiteBackV.backgroundColor = [UIColor whiteColor];
    }
    return _changeWhiteBackV;
}

-(UISegmentedControl *)changeSC{
    if (!_changeSC) {
        _changeSC = [[UISegmentedControl alloc]initWithItems:@[@"我的发布",@"我的关注"]];
        _changeSC.tintColor = LH_RGBCOLOR(75, 88, 91);
        [_changeSC addTarget:self action:@selector(changePostOrAttention:) forControlEvents:UIControlEventValueChanged];
        [_changeSC setSelectedSegmentIndex:0];
    }
    return _changeSC;
}

-(UITableView *)infoTB{
    if (!_infoTB) {
        _infoTB = [[UITableView alloc]init];
        _infoTB.delegate = self;
        _infoTB.dataSource = self;
    }
    return _infoTB;
}

-(UIButton *)addPostBtn{
    if (!_addPostBtn) {
        _addPostBtn  = [[UIButton alloc]init];
        _addPostBtn.backgroundColor = [UIColor grayColor];
        [_addPostBtn setTitle:@"新增发布" forState:UIControlStateNormal];
        [_addPostBtn setImage:MImage(@"wdhz_jiahao") forState:UIControlStateNormal];
        _addPostBtn.imageEdgeInsets = UIEdgeInsetsMake(-20, 12, 0, 0);
        _addPostBtn.titleEdgeInsets = UIEdgeInsetsMake(15, -16, 0, 0);
        _addPostBtn.titleLabel.font = MFont(10);
        [_addPostBtn addTarget:self action:@selector(clickAddPostBtn) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _addPostBtn;
}


@end
